using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace MemberShipModule
{
    public class GuestRoomRepository
    {
        private string connectionString
        {
            get
            {
                var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
                return s != null ? s.ConnectionString : "";
            }
        }

        public bool IsMemberActive(string memberNo, out string err)
        {
            err = "";
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string sql = "SELECT Status FROM [MemberShip].[dbo].[Member] WHERE MemberNo = @MemberNo";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                conn.Open();
                object res = cmd.ExecuteScalar();
                if (res != null)
                {
                    string status = res.ToString();
                    if (status.Equals("Active", StringComparison.OrdinalIgnoreCase))
                    {
                        return true;
                    }
                    err = "Member is " + status;
                    return false;
                }
                err = "Member not found";
                return false;
            }
        }

        public int CreateReservation(string roomId, DateTime fromDate, DateTime toDate, string memberNo, string name, string phone, string billingMode, string affiliatedClub)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string sql = @"INSERT INTO [MemberShip].[dbo].[HotelReservation] 
                               (RoomNumber, ReservationDate, ToDate, MemberNo, GuestName, ContactNo, BillingMode, AffiliatedClub, Status) 
                               VALUES (@Room, @FromDate, @ToDate, @MemberNo, @Name, @Phone, @BillingMode, @AffiliatedClub, 'Active');
                               SELECT SCOPE_IDENTITY();";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Room", roomId);
                cmd.Parameters.AddWithValue("@FromDate", fromDate);
                cmd.Parameters.AddWithValue("@ToDate", toDate);
                cmd.Parameters.AddWithValue("@MemberNo", (object)memberNo ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Name", (object)name ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Phone", (object)phone ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@BillingMode", (object)billingMode ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AffiliatedClub", (object)affiliatedClub ?? DBNull.Value);
                conn.Open();
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public void ShiftRoom(string oldRoom, string newRoom, string reason, string user)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // Find current guest id based on CheckInOut for this room
                        string sqlGuest = @"SELECT TOP 1 GuestId FROM [MemberShip].[dbo].[CheckInOut] 
                                            WHERE RoomNo = @OldRoom AND ActionType = 'CheckIn' ORDER BY LogId DESC";
                        SqlCommand cmdGuest = new SqlCommand(sqlGuest, conn, trans);
                        cmdGuest.Parameters.AddWithValue("@OldRoom", oldRoom);
                        object guestObj = cmdGuest.ExecuteScalar();
                        int guestId = guestObj != null ? Convert.ToInt32(guestObj) : 0;

                        if (guestId == 0) throw new Exception("Guest not found in room.");

                        // CheckOut from old room
                        string sqlCheckOut = @"INSERT INTO [MemberShip].[dbo].[CheckInOut] 
                                               (GuestId, RoomNo, ActionType, ActionDate, CreatedBy) 
                                               VALUES (@GuestId, @OldRoom, 'CheckOut', GETDATE(), @User)";
                        SqlCommand cmdOut = new SqlCommand(sqlCheckOut, conn, trans);
                        cmdOut.Parameters.AddWithValue("@GuestId", guestId);
                        cmdOut.Parameters.AddWithValue("@OldRoom", oldRoom);
                        cmdOut.Parameters.AddWithValue("@User", user);
                        cmdOut.ExecuteNonQuery();

                        // CheckIn to new room
                        string sqlCheckIn = @"INSERT INTO [MemberShip].[dbo].[CheckInOut] 
                                              (GuestId, RoomNo, ActionType, ActionDate, CreatedBy, Remarks) 
                                              VALUES (@GuestId, @NewRoom, 'CheckIn', GETDATE(), @User, @Reason)";
                        SqlCommand cmdIn = new SqlCommand(sqlCheckIn, conn, trans);
                        cmdIn.Parameters.AddWithValue("@GuestId", guestId);
                        cmdIn.Parameters.AddWithValue("@NewRoom", newRoom);
                        cmdIn.Parameters.AddWithValue("@User", user);
                        cmdIn.Parameters.AddWithValue("@Reason", "Shift from " + oldRoom + ". Reason: " + reason);
                        cmdIn.ExecuteNonQuery();

                        // Update room status
                        string sqlUpdateOld = "UPDATE [BasicDataInfo].[dbo].[TempGymkhanRoomData] SET Status = 'Available' WHERE BedNo = @OldRoom";
                        SqlCommand cmdUpdOld = new SqlCommand(sqlUpdateOld, conn, trans);
                        cmdUpdOld.Parameters.AddWithValue("@OldRoom", oldRoom);
                        cmdUpdOld.ExecuteNonQuery();

                        string sqlUpdateNew = "UPDATE [BasicDataInfo].[dbo].[TempGymkhanRoomData] SET Status = 'Occupied' WHERE BedNo = @NewRoom";
                        SqlCommand cmdUpdNew = new SqlCommand(sqlUpdateNew, conn, trans);
                        cmdUpdNew.Parameters.AddWithValue("@NewRoom", newRoom);
                        cmdUpdNew.ExecuteNonQuery();

                        trans.Commit();
                    }
                    catch
                    {
                        trans.Rollback();
                        throw;
                    }
                }
            }
        }

        public void CheckInGuest(int resId, string room, string memberNo, string name, string phone, string user)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Create Guest Record
                        string sqlGuest = @"INSERT INTO [MemberShip].[dbo].[HotelGuest] 
                                            (Name, Phone, MemberNo, CreatedBy, CreatedDate) 
                                            VALUES (@Name, @Phone, @MemberNo, @User, GETDATE());
                                            SELECT SCOPE_IDENTITY();";
                        SqlCommand cmdGuest = new SqlCommand(sqlGuest, conn, trans);
                        cmdGuest.Parameters.AddWithValue("@Name", (object)name ?? DBNull.Value);
                        cmdGuest.Parameters.AddWithValue("@Phone", (object)phone ?? DBNull.Value);
                        cmdGuest.Parameters.AddWithValue("@MemberNo", (object)memberNo ?? DBNull.Value);
                        cmdGuest.Parameters.AddWithValue("@User", user);
                        int guestId = Convert.ToInt32(cmdGuest.ExecuteScalar());

                        // 2. Insert CheckInOut Log
                        string sqlCheckIn = @"INSERT INTO [MemberShip].[dbo].[CheckInOut] 
                                              (GuestId, RoomNo, ActionType, ActionDate, CreatedBy) 
                                              VALUES (@GuestId, @RoomNo, 'CheckIn', GETDATE(), @User)";
                        SqlCommand cmdIn = new SqlCommand(sqlCheckIn, conn, trans);
                        cmdIn.Parameters.AddWithValue("@GuestId", guestId);
                        cmdIn.Parameters.AddWithValue("@RoomNo", room);
                        cmdIn.Parameters.AddWithValue("@User", user);
                        cmdIn.ExecuteNonQuery();

                        // 3. Mark Room as Occupied
                        string sqlRoom = "UPDATE [BasicDataInfo].[dbo].[TempGymkhanRoomData] SET Status = 'Occupied' WHERE BedNo = @RoomNo";
                        SqlCommand cmdRoom = new SqlCommand(sqlRoom, conn, trans);
                        cmdRoom.Parameters.AddWithValue("@RoomNo", room);
                        cmdRoom.ExecuteNonQuery();

                        // 4. Mark Reservation as Fulfilled
                        string sqlRes = "UPDATE [MemberShip].[dbo].[HotelReservation] SET Status = 'CheckedIn' WHERE ReservationID = @ResID";
                        SqlCommand cmdRes = new SqlCommand(sqlRes, conn, trans);
                        cmdRes.Parameters.AddWithValue("@ResID", resId);
                        cmdRes.ExecuteNonQuery();

                        trans.Commit();
                    }
                    catch
                    {
                        trans.Rollback();
                        throw;
                    }
                }
            }
        }
    }
}
