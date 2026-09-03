using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class GuestRoomM_Facility : SecurePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindData();
            }
        }

        private void BindData()
        {
        }

        protected void SwitchTab(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            if (btn != null && mvFacility != null)
            {
                int index = Convert.ToInt32(btn.CommandArgument);
                mvFacility.ActiveViewIndex = index;
            }
        }

        protected void gvFacilities_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvFacilities.SelectedRow != null)
            {
                txtFacilityID.Text = gvFacilities.SelectedRow.Cells[1].Text;
                txtFacilityName.Text = gvFacilities.SelectedRow.Cells[2].Text;
                txtCharges.Text = gvFacilities.SelectedRow.Cells[3].Text;
                mvFacility.ActiveViewIndex = 0;
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            txtFacilityID.Text = "";
            txtFacilityName.Text = "";
            txtCharges.Text = "";
            mvFacility.ActiveViewIndex = 0;
        }

        protected void btnModify_Click(object sender, EventArgs e)
        {
            mvFacility.ActiveViewIndex = 0;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            BindData();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            txtFacilityID.Text = "";
            txtFacilityName.Text = "";
            txtCharges.Text = "";
        }
    }
}
