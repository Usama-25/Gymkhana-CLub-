using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;

/// <summary>
/// Centralized logic for Guest Room Management
/// </summary>
public class GuestRoomRepository
{
    private string connectionString;

    public GuestRoomRepository()
    {
        connectionString = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
    }

    // --- MEMBER VALIDATION ---
    public bool IsMemberActive(string memberNo, out string errorMessage)
    {
        errorMessage = "";
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            string sql = "SELECT AccountStatus FROM MemberProfile WHERE MemberNo = @MemberNo";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@MemberNo", memberNo);
            conn.Open();
            object result = cmd.ExecuteScalar();
            
            if (result == null)
            {
                errorMessage = "Member not found.";
                return false;
            }

            string status = (result != DBNull.Value) ? result.ToString().Trim() : "";

            if (string.IsNullOrWhiteSpace(status))
            {
                errorMessage = "Member status is missing or undefined. Cannot proceed.";
                return false;
            }

            if (!status.Equals("Active", StringComparison.OrdinalIgnoreCase))
            {
                errorMessage = "Member status is '" + status + "'. Cannot proceed.";
                return false;
            }
            
            // TODO: Check Dues/Outstanding Balance here if logic exists
            return true;
        }
    }

    // --- RESERVATION MANAGEMENT ---
    public int CreateReservation(string roomNo, DateTime checkIn, DateTime checkOut, string memberNo, 
                                 string guestName, string contact, string billingMode, string affiliatedClub)
    {
        // 1. Strict Validation
        string err;
        if (!IsMemberActive(memberNo, out err))
        {
            throw new Exception(err);
        }

        if (checkIn < DateTime.Today)
            throw new Exception("Check-in date cannot be in the past.");

        if (checkOut <= checkIn)
            throw new Exception("Check-out date must be after check-in.");
            
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();
            
            // 2. Availability Check
            string checkSql = @"SELECT COUNT(1) FROM HotelReservation 
                                WHERE RoomNumber = @Room 
                                AND Status IN ('Active', 'CheckedIn')
                                AND (@CheckIn < ISNULL(ReservationToDate, DATEADD(day, 1, ReservationDate)))
                                AND (@CheckOut > ReservationDate)";
            
            SqlCommand checkCmd = new SqlCommand(checkSql, conn);
            checkCmd.Parameters.AddWithValue("@Room", roomNo);
            checkCmd.Parameters.AddWithValue("@CheckIn", checkIn);
            checkCmd.Parameters.AddWithValue("@CheckOut", checkOut);
            
            int count = (int)checkCmd.ExecuteScalar();
            if (count > 0)
                throw new Exception("Room is already booked for these dates.");

            // 3. Create Reservation
            string insertSql = @"INSERT INTO HotelReservation 
                                (RoomNumber, ReservationDate, ReservationToDate, GuestName, ContactNo, MemberNo, 
                                 Status, BillingMode, AffiliatedClub)
                                VALUES 
                                (@Room, @CheckIn, @CheckOut, @Name, @Contact, @MemberNo, 
                                 'Active', @BillingMode, @AffiliatedClub);
                                SELECT SCOPE_IDENTITY();";

            SqlCommand cmd = new SqlCommand(insertSql, conn);
            cmd.Parameters.AddWithValue("@Room", roomNo);
            cmd.Parameters.AddWithValue("@CheckIn", checkIn);
            cmd.Parameters.AddWithValue("@CheckOut", checkOut);
            cmd.Parameters.AddWithValue("@Name", guestName);
            cmd.Parameters.AddWithValue("@Contact", contact);
            cmd.Parameters.AddWithValue("@MemberNo", memberNo);
            cmd.Parameters.AddWithValue("@BillingMode", billingMode);
            cmd.Parameters.AddWithValue("@AffiliatedClub", (object)affiliatedClub ?? DBNull.Value);
            
            return Convert.ToInt32(cmd.ExecuteScalar());
        }
    }

    public void CancelReservation(int reservationId, string reason, string user)
    {
         using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();
            string sql = @"UPDATE HotelReservation 
                           SET Status = 'Cancelled', CancelledDate = GETDATE(), CancelledBy = @User 
                           WHERE ReservationID = @ID";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@ID", reservationId);
            cmd.Parameters.AddWithValue("@User", user);
            cmd.ExecuteNonQuery();
        }
    }

    // --- CHECK-IN LOGIC ---
    public void CheckInGuest(int reservationId, string roomNo, string memberNo, string guestName, 
                             string phone, string user)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();
            SqlTransaction tran = conn.BeginTransaction();
            
            try
            {
                // 1. Verify Reservation Status
                string statusSql = "SELECT Status FROM HotelReservation WHERE ReservationID = @ID";
                SqlCommand statCmd = new SqlCommand(statusSql, conn, tran);
                statCmd.Parameters.AddWithValue("@ID", reservationId);
                object statusObj = statCmd.ExecuteScalar();
                if (statusObj == null || statusObj.ToString() != "Active")
                {
                    throw new Exception("Reservation not found or not Active.");
                }

                // 2. Create Guest Record (linked to Reservation)
                string guestSql = @"INSERT INTO HotelGuest (Name, Phone, MemberNo, ReservationID) 
                                    OUTPUT INSERTED.GuestId 
                                    VALUES (@Name, @Phone, @MemberNo, @ResID)";
                SqlCommand guestCmd = new SqlCommand(guestSql, conn, tran);
                guestCmd.Parameters.AddWithValue("@Name", guestName);
                guestCmd.Parameters.AddWithValue("@Phone", phone);
                guestCmd.Parameters.AddWithValue("@MemberNo", memberNo);
                guestCmd.Parameters.AddWithValue("@ResID", reservationId);
                long guestId = (long)guestCmd.ExecuteScalar();

                // 3. Log Check-In
                string ciSql = @"INSERT INTO CheckInOut (RoomNo, GuestId, ActionType, EventDate, MemberNo, Remarks)
                                 VALUES (@Room, @GuestId, 'CheckIn', GETDATE(), @MemberNo, @Remarks)";
                SqlCommand ciCmd = new SqlCommand(ciSql, conn, tran);
                ciCmd.Parameters.AddWithValue("@Room", roomNo);
                ciCmd.Parameters.AddWithValue("@GuestId", guestId);
                ciCmd.Parameters.AddWithValue("@MemberNo", memberNo);
                ciCmd.Parameters.AddWithValue("@Remarks", "Checked in via Res# " + reservationId);
                ciCmd.ExecuteNonQuery();

                // 4. Update Room Status
                string roomSql = "UPDATE [BasicDataInfo].[dbo].[TempGymkhanRoomData] SET Status = 'Occupied' WHERE BedNo = @Room";
                SqlCommand roomCmd = new SqlCommand(roomSql, conn, tran);
                roomCmd.Parameters.AddWithValue("@Room", roomNo);
                roomCmd.ExecuteNonQuery();

                // 5. Update Reservation Status
                string resUpdSql = "UPDATE HotelReservation SET Status = 'CheckedIn' WHERE ReservationID = @ID";
                SqlCommand resUpdCmd = new SqlCommand(resUpdSql, conn, tran);
                resUpdCmd.Parameters.AddWithValue("@ID", reservationId);
                resUpdCmd.ExecuteNonQuery();

                tran.Commit();
            }
            catch
            {
                try { tran.Rollback(); } catch { } // Ignore rollback errors
                throw;
            }
        }
    }

    // --- ROOM SHIFT ---
    public void ShiftRoom(string oldRoom, string newRoom, string reason, string user)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();
            SqlTransaction tran = conn.BeginTransaction();

            try
            {
                // 1. Get Active CheckIn Info
                long guestId = 0;
                string getLogSql = @"SELECT TOP 1 GuestId FROM [MemberShip].[dbo].[CheckInOut] 
                                     WHERE RoomNo = @Room AND ActionType = 'CheckIn' 
                                     ORDER BY LogId DESC";
                SqlCommand cmdGet = new SqlCommand(getLogSql, conn, tran);
                cmdGet.Parameters.AddWithValue("@Room", oldRoom);
                object result = cmdGet.ExecuteScalar();
                
                if (result == null) throw new Exception("No active check-in found for room " + oldRoom);
                guestId = Convert.ToInt64(result);

                // 2. Update Old Room -> Available
                string updOld = "UPDATE [BasicDataInfo].[dbo].[TempGymkhanRoomData] SET Status = 'Available' WHERE BedNo = @Room";
                SqlCommand cmdOld = new SqlCommand(updOld, conn, tran);
                cmdOld.Parameters.AddWithValue("@Room", oldRoom);
                cmdOld.ExecuteNonQuery();

                // 3. Update New Room -> Occupied
                string updNew = "UPDATE [BasicDataInfo].[dbo].[TempGymkhanRoomData] SET Status = 'Occupied' WHERE BedNo = @Room";
                SqlCommand cmdNew = new SqlCommand(updNew, conn, tran);
                cmdNew.Parameters.AddWithValue("@Room", newRoom);
                cmdNew.ExecuteNonQuery();

                // 4. Update Reservation Room Number (To keep track of current room in Reservation table too)
                string updRes = @"UPDATE [MemberShip].[dbo].[HotelReservation] 
                                  SET RoomNumber = @NewRoom 
                                  WHERE ReservationID = (SELECT TOP 1 ReservationID FROM [MemberShip].[dbo].[HotelGuest] WHERE GuestId = @GuestId)";
                SqlCommand cmdRes = new SqlCommand(updRes, conn, tran);
                cmdRes.Parameters.AddWithValue("@NewRoom", newRoom);
                cmdRes.Parameters.AddWithValue("@GuestId", guestId);
                cmdRes.ExecuteNonQuery();

                // 5. Log Shift using CheckInOut (Close Old, Open New)
                // Close Old
                string sqlOut = @"INSERT INTO [MemberShip].[dbo].[CheckInOut] (RoomNo, GuestId, ActionType, EventDate, MemberNo, Remarks) 
                                  SELECT @Room, @GuestId, 'RoomShift', GETDATE(), MemberNo, 'Shifted to ' + @NewRoom 
                                  FROM [MemberShip].[dbo].[HotelGuest] WHERE GuestId = @GuestId";
                SqlCommand cmdOut = new SqlCommand(sqlOut, conn, tran);
                cmdOut.Parameters.AddWithValue("@Room", oldRoom);
                cmdOut.Parameters.AddWithValue("@NewRoom", newRoom);
                cmdOut.Parameters.AddWithValue("@GuestId", guestId);
                cmdOut.ExecuteNonQuery();

                // Open New
                string sqlIn = @"INSERT INTO [MemberShip].[dbo].[CheckInOut] (RoomNo, GuestId, ActionType, EventDate, MemberNo, Remarks) 
                                 SELECT @Room, @GuestId, 'CheckIn', GETDATE(), MemberNo, 'Shifted from ' + @OldRoom 
                                 FROM [MemberShip].[dbo].[HotelGuest] WHERE GuestId = @GuestId";
                SqlCommand cmdIn = new SqlCommand(sqlIn, conn, tran);
                cmdIn.Parameters.AddWithValue("@Room", newRoom);
                cmdIn.Parameters.AddWithValue("@OldRoom", oldRoom);
                cmdIn.Parameters.AddWithValue("@GuestId", guestId);
                cmdIn.ExecuteNonQuery();

                // 6. Log to RoomShiftLog
                string sqlLog = @"INSERT INTO [MemberShip].[dbo].[RoomShiftLog] (GuestId, OldRoomNo, NewRoomNo, ShiftDate, Reason, ShiftedBy) 
                                  VALUES (@GuestId, @OldRoom, @NewRoom, GETDATE(), @Reason, @User)";
                SqlCommand cmdLog = new SqlCommand(sqlLog, conn, tran);
                cmdLog.Parameters.AddWithValue("@GuestId", guestId);
                cmdLog.Parameters.AddWithValue("@OldRoom", oldRoom);
                cmdLog.Parameters.AddWithValue("@NewRoom", newRoom);
                cmdLog.Parameters.AddWithValue("@Reason", reason);
                cmdLog.Parameters.AddWithValue("@User", user);
                cmdLog.ExecuteNonQuery();

                tran.Commit();
            }
            catch
            {
                try { tran.Rollback(); } catch { } // Ignore rollback errors
                throw;
            }
        }
    }
}
