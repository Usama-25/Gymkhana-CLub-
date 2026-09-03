namespace RestaurantWeb.Models
{
    public class MenuItem
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }
    }
    public class OrderItem
    {
        public int MenuItemId { get; set; }
        public string MenuName { get; set; }
        public decimal Price { get; set; }
        public int Quantity { get; set; }
    }
}