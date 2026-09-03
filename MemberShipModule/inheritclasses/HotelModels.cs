using System;
using System.Collections.Generic;

[Serializable]
public class HotelRoom
{
    public string RoomNumber { get; set; }
    public int Floor { get; set; }
    public string Status { get; set; } // Available, Occupied, Reserved, Maintenance
    public HotelGuest CurrentGuest { get; set; }
}

[Serializable]
public class HotelGuest
{
    public string GuestId { get; set; }
    public string Name { get; set; }
    public string Phone { get; set; }
    public string Email { get; set; }
    public DateTime CheckInDate { get; set; }
    public DateTime ExpectedCheckOut { get; set; }
    public decimal RatePerNight { get; set; }
    public string RoomNumber { get; set; }
}

[Serializable]
public class HotelReservation
{
    public string ReservationId { get; set; }
    public string RoomNumber { get; set; }
    public string GuestName { get; set; }
    public DateTime ReservationDate { get; set; }
    public string Status { get; set; }
}

[Serializable]
public class HotelBookingHistory
{
    public string BookingId { get; set; }
    public string RoomNumber { get; set; }
    public string GuestName { get; set; }
    public DateTime CheckInDate { get; set; }
    public DateTime CheckOutDate { get; set; }
    public decimal TotalAmount { get; set; }
}

