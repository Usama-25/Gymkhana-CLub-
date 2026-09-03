using System;
using System.Web.UI.WebControls;

namespace Infragistics.WebUI.WebSchedule
{
    public class CalendarLayoutInfo
    {
        public string Culture { get; set; }
    }

    public class WebDateChooser : TextBox
    {
        private CalendarLayoutInfo _calendarLayout = new CalendarLayoutInfo();

        public object Value
        {
            get
            {
                if (string.IsNullOrEmpty(this.Text))
                    return null;
                DateTime dt;
                if (DateTime.TryParse(this.Text, out dt))
                    return dt;
                return null;
            }
            set
            {
                if (value is DateTime)
                {
                    this.Text = ((DateTime)value).ToString("yyyy-MM-dd");
                }
                else if (value == null)
                {
                    this.Text = "";
                }
                else
                {
                    this.Text = value.ToString();
                }
            }
        }

        public DateTime MaxValue { get; set; }
        
        public CalendarLayoutInfo CalendarLayout
        {
            get { return _calendarLayout; }
            set { _calendarLayout = value; }
        }
    }

    public class WebDateChooserEventArgs : EventArgs { }
}

namespace Infragistics.WebUI.WebDataInput
{
    public class WebDateTimeEdit : TextBox
    {
        public object Value
        {
            get
            {
                if (string.IsNullOrEmpty(this.Text))
                    return null;
                DateTime dt;
                if (DateTime.TryParse(this.Text, out dt))
                    return dt;
                return null;
            }
            set
            {
                if (value is DateTime)
                {
                    this.Text = ((DateTime)value).ToString("yyyy-MM-dd");
                }
                else if (value == null)
                {
                    this.Text = "";
                }
                else
                {
                    this.Text = value.ToString();
                }
            }
        }

        public DateTime MaxValue { get; set; }
        public bool EnableClientSideAPI { get; set; }
        public string EditModeFormat { get; set; }
    }
}
