using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Restaurant
{
    public partial class Menu : Page
    {
        private const string SessionOrderKey = "RestaurantOrderSessionKey";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindMenu();
                BindBill();
            }
        }

        private void BindMenu()
        {
            rptMenu.DataSource = GetSampleMenu();
            rptMenu.DataBind();
        }

        private List<MenuItem> GetSampleMenu()
        {
            return new List<MenuItem>
            {
                new MenuItem { Id = 1, Name = "Margherita Pizza", Description = "Classic cheese & tomato", Price = 10.99m },
                new MenuItem { Id = 2, Name = "Spaghetti Bolognese", Description = "House meat sauce", Price = 12.50m },
                new MenuItem { Id = 3, Name = "Caesar Salad", Description = "Romaine, parmesan, croutons", Price = 8.25m },
                new MenuItem { Id = 4, Name = "Tiramisu", Description = "Classic coffee dessert", Price = 6.00m }
            };
        }

        private List<OrderItem> CurrentOrder
        {
            get
            {
                if (Session[SessionOrderKey] == null)
                {
                    Session[SessionOrderKey] = new List<OrderItem>();
                }
                return (List<OrderItem>)Session[SessionOrderKey];
            }
        }

        protected void Menu_Add(object sender, CommandEventArgs e)
        {
            if (e.CommandName != "Add")
                return;

            int menuId;
            if (!int.TryParse((string)e.CommandArgument, out menuId))
                return;

            var menu = GetSampleMenu().FirstOrDefault(m => m.Id == menuId);
            if (menu == null)
                return;

            var existing = CurrentOrder.FirstOrDefault(o => o.MenuItemId == menuId);
            if (existing != null)
            {
                existing.Quantity += 1;
            }
            else
            {
                CurrentOrder.Add(new OrderItem
                {
                    MenuItemId = menu.Id,
                    Name = menu.Name,
                    Price = menu.Price,
                    Quantity = 1,
                    Notes = ""
                });
            }

            lblMessage.Text = "";
            lblError.Text = "";
            BindBill();
        }

        private void BindBill()
        {
            gvBill.DataSource = CurrentOrder;
            gvBill.DataBind();

            decimal total = CurrentOrder.Sum(o => o.LineTotal);
            lblTotal.Text = total.ToString("C");
        }

        protected void gvBill_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvBill.EditIndex = e.NewEditIndex;
            BindBill();
        }

        protected void gvBill_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvBill.EditIndex = -1;
            BindBill();
        }

        protected void gvBill_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int menuId = Convert.ToInt32(gvBill.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvBill.Rows[e.RowIndex];
            TextBox txtQty = (TextBox)row.FindControl("txtQty");
            TextBox txtNotes = (TextBox)row.FindControl("txtNotes");

            int newQty;
            if (txtQty == null || !int.TryParse(txtQty.Text.Trim(), out newQty) || newQty <= 0)
            {
                lblError.Text = "Enter a valid quantity for update.";
                return;
            }

            var item = CurrentOrder.FirstOrDefault(o => o.MenuItemId == menuId);
            if (item != null)
            {
                item.Quantity = newQty;
                if (txtNotes != null)
                {
                    item.Notes = txtNotes.Text.Trim();
                }
            }

            gvBill.EditIndex = -1;
            lblMessage.Text = "";
            lblError.Text = "";
            BindBill();
        }

        protected void gvBill_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int menuId = Convert.ToInt32(gvBill.DataKeys[e.RowIndex].Value);
            var item = CurrentOrder.FirstOrDefault(o => o.MenuItemId == menuId);
            if (item != null)
            {
                CurrentOrder.Remove(item);
            }

            BindBill();
        }

        protected void btnFinalize_Click(object sender, EventArgs e)
        {
            if (!CurrentOrder.Any())
            {
                lblError.Text = "Your order is empty.";
                return;
            }

            List<OrderItem> receiptCopy = CurrentOrder.ToList();
            decimal total = receiptCopy.Sum(i => i.LineTotal);

            gvReceipt.DataSource = receiptCopy;
            gvReceipt.DataBind();
            lblReceiptTotal.Text = total.ToString("C");
            pnlReceipt.Visible = true;

            Session[SessionOrderKey] = new List<OrderItem>();
            BindBill();

            lblMessage.Text = "Bill finalized successfully!";
            lblError.Text = "";
        }

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
            public string Name { get; set; }
            public decimal Price { get; set; }
            public int Quantity { get; set; }
            public string Notes { get; set; }
            public decimal LineTotal { get { return Price * Quantity; } }
        }
    }
}