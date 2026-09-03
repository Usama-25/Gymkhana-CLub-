<%@ Page Language="C#" Debug="true" AutoEventWireup="true" 
    CodeFile="OnlineAppoinmentBooking.aspx.cs" 
    Inherits="OnlineAppoinmentBooking" %>

<%@ Register Namespace="Infragistics.WebUI.WebSchedule" TagPrefix="igsch" %>
<%@ Register Namespace="Infragistics.WebUI.WebDataInput" TagPrefix="igtxt" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=yes">
    <title>Patient Appointment Booking System</title>
    
    <!-- External Resources -->
    <link href="../css_hacims/class_reset.css" rel="stylesheet" />
    <link href="../css_hacims/class_forms.css" rel="stylesheet" />
    <link href="../SpryAssets/mycollaps.css" rel="stylesheet" />
    
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Scripts -->
    <script src="../SpryAssets/mycollaps.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <script src="../css_hacims/ck.js"></script>

    
    <style>
body {
    font-family: 'Inter', sans-serif;
    background: linear-gradient(135deg,#e6eef6,#d6e2f0);
    padding: 20px;
}


/* MAIN CARD */
.paypal-form {

    width: 100%;
    max-width: 90%;
    margin: auto;

    background: #eaf2fb;
    padding: 15px;

    border-radius: 12px;

}


/* GRID LAYOUT */
.form-grid {

    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px;
    width: 100%;

}


/* FULL WIDTH FIELD */
.form-group.full-width {

    grid-column: span 5;

}


/* FORM GROUP */
.form-group {

    width: 100%;

}


/* LABEL */
.form-label {

    font-size: 14px;
    font-weight: 500;
    margin-bottom: 6px;
    display: block;

}


/* ALL INPUTS FULL WIDTH */
.form-control,
.form-group input,
.form-group select,
.form-group textarea,
.igedit,
.igedit input {

    width: 100% !important;
    max-width: 100% !important;

    height: 38px !important;

    border-radius: 6px !important;
    border: 1px solid #c7ccd1 !important;

    background: #f2f2f2 !important;

    padding: 4px !important;

    font-size: 16px !important;

    box-sizing: border-box;

}


/* PHONE GROUP SAME LINE */
.phone-group {

    display: flex;
    align-items: center;
    gap: 10px;
    width: 100%;

}

.phone-group input:nth-child(1) {
    width: 80px !important;
}





.phone-separator {

    font-size: 18px;
    font-weight: bold;

}


/* DOB AGE GROUP */
.dob-age-group {

    display: flex;
    align-items: center;
    gap: 10px;
    width: 100%;

}

.dob-age-group .dob {
    width: 100% !important;
}

.dob-age-group .age {
    width: 100px !important;
}

.dob-age-group .indicator {
    width: 120px !important;
}


/* BUTTON GROUP */
.button-group input,
.button-group button {

    border: none !important;

    padding: 18px 18px !important;

    font-size: 15px !important;

    border-radius: 8px !important;

    cursor: pointer !important;

    background: linear-gradient(135deg,#38bdf8,#0ea5e9) !important;

    color: white !important;

}


/* MOBILE */
@media (max-width:768px)
{

    .form-grid {
        grid-template-columns: 1fr;
    }

    .form-group.full-width {
        grid-column: span 1;
    }

}

    </style>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
            <Scripts>
                <asp:ScriptReference Path="~/Scripts/appointment.js" />
            </Scripts>
        </asp:ScriptManager>

        <div class="appointment-container">
           <!-- Hidden Search Panel (Hidden by default) -->
            <div class="search-panel" style="display: none;">
                <h3><i class="fas fa-search"></i> Patient Search</h3>
                <asp:Panel ID="Panel2" runat="server" CssClass="form-grid"> 
                    <!-- Search fields would go here -->
                </asp:Panel>
                <div class="button-group1" style="justify-content: center;">
                    <asp:Button ID="Button1" runat="server" CssClass="btn-primary1" Text="Search" />
                    <input type="button" id="Button_clr" class="btn-secondary1" value="Clear" />
                    <asp:Button ID="btnTodayPatients" runat="server" CssClass=" btn-primary1" Text="Today Patients" OnClick="btnTodayPatients_Click" />
                </div>
            </div>

            <!-- Main Content Section -->
            <div class="paypal-form">
                <div class="paypal-header" style = "text-align:center ; font-size:large;   font-weight: bold;  ">
                    <i class="fas fa-user-injured"></i>
                    Patient Appoinment Form 
                </div>

                <!-- MR # Display -->
                <div style="margin-bottom: 24px;">
                    <span class="reg-badge">
                        
                         <asp:Label ID="lblRegNo" runat="server"/>
                    </span>
                </div>

                <!-- Form Grid -->
                <div class="form-grid">
                    <!-- Patient Prefix -->
                    <div class="form-group">
                        <span class="form-label">
                            <i class="fas fa-user-tag"></i>Patient Prefix
                        </span>
                        <div class="radio-group">
<asp:RadioButtonList ID="RadioButtonListPrefix"
    runat="server"
    RepeatDirection="Horizontal">

                                <asp:ListItem Selected="True">Mr.</asp:ListItem>
                                <asp:ListItem>Miss</asp:ListItem>
                                <asp:ListItem>Dr.</asp:ListItem>
                                <asp:ListItem>Prof.</asp:ListItem>
                            </asp:RadioButtonList>
                        </div>
                    </div>

                    <!-- Patient Name -->
                    <div class="form-group full-width">
                        <span class="form-label">
                            <i class="fas fa-user"></i>Patient Name
                            <span class="required-star">*</span>
                        </span>
                        <asp:TextBox ID="TextBoxPFName1" runat="server" CssClass="form-control required" 
                            placeholder="Enter patient full name" TabIndex="1"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" 
                            ControlToValidate="TextBoxPFName1" ErrorMessage="Patient name is required" 
                            Display="Dynamic" CssClass="message-box message-error">
                            <i class="fas fa-exclamation-circle"></i> Patient name is required
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- Middle Name (Hidden) -->
                    <div class="form-group" style="display: none;">
                        <span class="form-label">Middle Name</span>
                        <asp:TextBox ID="TextBoxPMName" runat="server" CssClass="form-control" TabIndex="2"></asp:TextBox>
                    </div>

                    <!-- Last Name (Hidden) -->
                    <div class="form-group" style="display: none;">
                        <span class="form-label">Last Name</span>
                        <asp:TextBox ID="TextBoxPLName" runat="server" CssClass="form-control" TabIndex="3"></asp:TextBox>
                    </div>

                    <!-- Email (Hidden) -->
                    <div class="form-group" style="display: none;">
                        <span class="form-label">Email Address</span>
                        <asp:TextBox ID="TextBox_Emailaddress" runat="server" CssClass="form-control" TabIndex="4" 
                            TextMode="Email" placeholder="email@example.com"></asp:TextBox>
                    </div>

                    <!-- Cell Number -->
                    <div class="form-group full-width">
                        <span class="form-label">
                            <i class="fas fa-mobile-alt"></i>Cell Number
                            <span class="required-star">*</span>
                        </span>
                        <div class="phone-group">

    <asp:TextBox ID="TextBoxCell1"
        runat="server"
        CssClass="form-control"
        MaxLength="4"
        placeholder="0300">
    </asp:TextBox>

    <span class="phone-separator">-</span>

    <asp:TextBox ID="TextBoxCell2"
        runat="server"
        CssClass="form-control"
        MaxLength="7"
        placeholder="1234567">
    </asp:TextBox>
                        </div>
                    </div>

                    <!-- Residence Phone (Hidden) -->
                    <div class="form-group" style="display: none;">
                        <span class="form-label">Res Phone No.</span>
                        <div class="phone-group">
                            <asp:TextBox ID="TextBox_Phone_1" runat="server" CssClass="form-control" MaxLength="4" TabIndex="7"></asp:TextBox>
                            <span class="phone-separator">-</span>
                            <asp:TextBox ID="TextBox_Phone_2" runat="server" CssClass="form-control" MaxLength="2" TabIndex="8"></asp:TextBox>
                            <span class="phone-separator">-</span>
                            <asp:TextBox ID="TextBox_Phone_3" runat="server" CssClass="form-control" MaxLength="7" TabIndex="9"></asp:TextBox>
                        </div>
                    </div>

                    <!-- City -->
                    <div class="form-group">
                        <span class="form-label">
                            <i class="fas fa-city"></i>City
                        </span>
                        <asp:DropDownList ID="DropDownList_City" runat="server" CssClass="form-control" 
                            DataTextField="DistrictName" DataValueField="DistrictCode" 
                            DataSourceID="SqlDataSource_City" TabIndex="10">
                        </asp:DropDownList>
                    </div>

                    <!-- Appointment For (Doctor) -->
                    <div class="form-group">
                        <span class="form-label">
                            <i class="fas fa-user-md"></i>Appointment For
                        </span>
                        <asp:DropDownList ID="DropDownListDoctor_id" runat="server" CssClass="form-control" 
                            TabIndex="11" AutoPostBack="True" 
                            OnSelectedIndexChanged="DropDownListDoctor_id_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>

                    <!-- Appointment Date -->
                    <div class="form-group">
                        <span class="form-label">
                            <i class="fas fa-calendar-alt"></i>Appointment Date
                        </span>
                        <igsch:WebDateChooser
    ID="WebDateChooser_AppointmentDate"
    runat="server"
    CssClass="drop_date form-control"

                            OnValueChanged="WebDateChooser_AppointmentDate_ValueChanged">
                            <CalendarLayout Culture="English (United Kingdom)" />
                        </igsch:WebDateChooser>
                        <asp:Label ID="lblDateError" runat="server" ForeColor="Red"></asp:Label>

                    </div>

                    <!-- Session -->
                    <div class="form-group">
                        <span class="form-label">
                            <i class="fas fa-clock"></i>Session
                            <span class="required-star">*</span>
                        </span>
                        <asp:DropDownList ID="ddlSessions" runat="server" CssClass="form-control" 
                            AutoPostBack="true" OnSelectedIndexChanged="ddlSessions_SelectedIndexChanged">
                        </asp:DropDownList>
                        <asp:Label ID="lblSessionMsg" runat="server" CssClass="message-box message-warning" 
                            Visible="false">
                            <i class="fas fa-exclamation-triangle"></i> 
                            <asp:Literal ID="litSessionMsg" runat="server" />
                        </asp:Label>
                    </div>

                    <!-- Appointment Time -->
                    <div class="form-group">
                        <span class="form-label">
                            <i class="fas fa-hourglass-half"></i>Appointment Time
                            <span class="required-star">*</span>
                        </span>
                        <asp:DropDownList ID="DropDownList_TimeSlot" runat="server" CssClass="form-control" TabIndex="14">
                        </asp:DropDownList>
                        <asp:Label ID="lblTimeSlotMsg" runat="server" CssClass="message-box message-warning" 
                            Visible="false">
                            <i class="fas fa-exclamation-triangle"></i> 
                            <asp:Literal ID="litTimeSlotMsg" runat="server" />
                        </asp:Label>
                    </div>

                    <!-- Services -->
                    <div class="form-group">
                        <span class="form-label">
                            <i class="fas fa-stethoscope"></i>Services
                        </span>
                        <asp:DropDownList ID="DropDownList_Services" runat="server" CssClass="form-control" 
                            DataTextField="S_Name" DataValueField="S_ID" TabIndex="12" AutoPostBack="True"
                            OnSelectedIndexChanged="DropDownList_Services_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>

                    <!-- Appointment Nature -->
                    <div class="form-group">
                        <span class="form-label">
                            <i class="fas fa-clipboard-list"></i>Appointment Nature
                        </span>
                        <asp:DropDownList ID="DropDownList_Purpose" runat="server" CssClass="form-control" TabIndex="15">
                            <asp:ListItem Selected="True">Initial Visit</asp:ListItem>
                            <asp:ListItem>Follow Up</asp:ListItem>
                            <asp:ListItem>Report Checking</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <!-- Appointment Type -->
                    <div class="form-group">
                        <span class="form-label">
                            <i class="fas fa-tag"></i>Appointment Type
                        </span>
                        <asp:DropDownList ID="DropDownList_VisitType" runat="server" CssClass="form-control">
                            <asp:ListItem Selected="True">Normal</asp:ListItem>
                            <asp:ListItem>Add On</asp:ListItem>
                            <asp:ListItem>Waiting</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <!-- Appointment Source -->
                    <div class="form-group">
                        <span class="form-label">
                            <i class="fas fa-phone-alt"></i>Appointment Source
                        </span>
                        <asp:DropDownList ID="DropDownList_VisitSource" runat="server" CssClass="form-control">
                            <asp:ListItem >Internet</asp:ListItem>
                            
                        </asp:DropDownList>
                    </div>

                    <!-- Complaint -->
                    <div class="form-group full-width">
                        <span class="form-label">
                            <i class="fas fa-notes-medical"></i>Chief Complaint
                        </span>
                        <asp:TextBox ID="TextBoxComplaint" runat="server" CssClass="form-control" 
                            TextMode="MultiLine" placeholder="Enter chief complaint" TabIndex="16"></asp:TextBox>
                    </div>

                    <!-- DOB / Age -->
                    <div class="form-group full-width">

    <span class="form-label">
        <i class="fas fa-birthday-cake"></i>Date of Birth / Age
    </span>

    <div class="dob-age-group">

<igtxt:WebDateTimeEdit
    ID="WebDateTimeEdit_DOB"
    runat="server"
    CssClass="form-control dob"
    AutoPostBack="False"
    EnableViewState="True"
    CausesValidation="False"
    EnableClientSideAPI="True"
    EditModeFormat="dd/MM/yyyy">
</igtxt:WebDateTimeEdit>



        <!-- AGE -->
        <asp:TextBox
            ID="textboxage"
            runat="server"
            CssClass="form-control age"
            placeholder="Age"
            onchange="showAgedob()"
            onkeyup="showAgedob()">
        </asp:TextBox>

        <!-- INDICATOR -->
        <asp:DropDownList
            ID="DropDownListBIndicator"
            runat="server"
            CssClass="form-control indicator"
            onchange="showAgedobfocus()">

            <asp:ListItem Selected="True">Years</asp:ListItem>
            <asp:ListItem>Months</asp:ListItem>
            <asp:ListItem>Days</asp:ListItem>
            <asp:ListItem>Hours</asp:ListItem>

        </asp:DropDownList>

    </div>

</div>


                    <!-- Referenced By -->
                    <div class="form-group full-width">
                        <span class="form-label">
                            <i class="fas fa-user-plus"></i>Referenced By
                        </span>
                        <asp:TextBox ID="TextBox_Reference" runat="server" CssClass="form-control" 
                            placeholder="Who referred this patient?" TabIndex="20"></asp:TextBox>
                    </div>

                    <!-- Remarks -->
                    <div class="form-group full-width">
                        <span class="form-label">
                            <i class="fas fa-comment"></i>Remarks
                        </span>
                        <asp:TextBox ID="TextBox_Remarks" runat="server" CssClass="form-control" 
                            TextMode="MultiLine" placeholder="Any additional remarks..." TabIndex="21"></asp:TextBox>
                    </div>
                        <div class="button-group full-width">
        <asp:Button ID="ButtonSave" runat="server"
    CssClass="btn-save"
    Text="Save Appointment"
    OnClick="ButtonSave_Click"
    UseSubmitBehavior="false" />
   <asp:Button ID="ButtonBack" runat="server"
  CssClass="btn-back"
  Text="Clear"
  CausesValidation="False"
  UseSubmitBehavior="false"
  OnClick="ButtonBack_Click" />
    </div>
  
</div>
                </div>

                <!-- Message Display -->
                <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="message-box">
                    <i class="fas fa-info-circle"></i> 
                    <asp:Literal ID="litMsg" runat="server" />
                </asp:Label>

                <!-- Action Buttons -->
            

            <!-- Patient Search Results Grid (Hidden by default) -->
            <div class="content-section" style="display: none;">
                <div class="section-title">
                    <i class="fas fa-search"></i>
                    Search Results
                </div>
                
                <div class="grid-container">
                    <asp:GridView ID="GridViewSearch" runat="server" 
                        AutoGenerateColumns="False" 
                        CssClass="modern-grid"
                        AllowPaging="true" 
                        PageSize="20" 
                        Width="100%" 
                        AllowSorting="true" 
                        OnSorting="GridViewSearch_Sorting"
                        OnPageIndexChanging="GridViewSearch_PageIndexChanging">
                        <RowStyle CssClass="grid-item" />
                        <AlternatingRowStyle CssClass="grid-alt-item" />
                        <HeaderStyle CssClass="grid-header" />
                        <PagerStyle CssClass="grid-pager" />
                        <Columns>
                            <asp:TemplateField HeaderText="Select">
                                <ItemTemplate>
                                    <asp:LinkButton ID="LinkButton1" runat="server" 
                                        OnClick="LinkButton1_Click" 
                                        CssClass="select-link">
                                        <i class="fas fa-check-circle"></i> Select
                                    </asp:LinkButton>
                                    <asp:HiddenField ID="hdfPrefix" runat="server" Value='<%# Eval("Prefix") %>' />
                                    <asp:HiddenField ID="hdfPatientName" runat="server" Value='<%# Eval("PatientName") %>' />
                                    <asp:HiddenField ID="hdfDob" runat="server" Value='<%# Eval("DateOfBirth")%>' />
                                    <asp:HiddenField ID="hdfMobileNo" runat="server" Value='<%# Eval("MobilePhone")%>' />
                                    <asp:HiddenField ID="hdfCNIC" runat="server" Value='<%# Eval("CNIC")%>' />
                                    <asp:HiddenField ID="hdfAge" runat="server" Value='<%# Eval("PatientAge")%>' />
                                    <asp:HiddenField ID="HfAppId" runat="server" Value='<%# Eval("Appoinment_ID")%>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="MR #" SortExpression="RegNo">
                                <ItemTemplate>
                                    <asp:Label ID="Label1" runat="server" Text='<%# Eval("RegNo") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Visit #" SortExpression="VisitNo" Visible="false">
                                <ItemTemplate>
                                    <asp:Label ID="lblVisitNo" runat="server" Text='<%# Eval("VisitNo") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:BoundField DataField="PatientName" HeaderText="Patient Name" SortExpression="PatientName" />
                            <asp:BoundField DataField="Relation" HeaderText="Relation" SortExpression="Relation" />
                            <asp:BoundField DataField="RelationName" HeaderText="Relation Name" SortExpression="RelationName" />
                            <asp:BoundField DataField="PatientAge" HeaderText="Age" SortExpression="PatientAge" />
                            <asp:BoundField DataField="DateOfBirth" HeaderText="Date Of Birth" SortExpression="DateOfBirth" DataFormatString="{0:dd/MM/yyyy}" />
                            <asp:BoundField DataField="RegistrationDate" HeaderText="Registration Date" SortExpression="RegistrationDate" DataFormatString="{0:dd/MM/yyyy}" />
                            <asp:BoundField DataField="MobilePhone" HeaderText="Mobile #" SortExpression="MobilePhone" />
                            <asp:BoundField DataField="CNIC" HeaderText="CNIC" SortExpression="CNIC" />
                            <asp:BoundField DataField="PermanentAddress" HeaderText="Permanent Address" SortExpression="PermanentAddress" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <!-- Hidden Grid for Patient Data -->
            <asp:GridView ID="GridView2" runat="server" AllowPaging="True" AutoGenerateColumns="False"
                DataSourceID="SqlDataSourcePatient" EmptyDataText="No data found" Width="100%" 
                Visible="false" PageSize="50" CssClass="modern-grid">
                <RowStyle CssClass="grid-item" />
                <AlternatingRowStyle CssClass="grid-alt-item" />
                <HeaderStyle CssClass="grid-header" />
                <Columns>
                    <asp:BoundField DataField="Patient" HeaderText="Patient" SortExpression="Patient" />
                    <asp:BoundField DataField="AP_Date" HeaderText="Appointment Date" SortExpression="AP_Date" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:BoundField DataField="Appointment_Time" HeaderText="Appointment Time" SortExpression="Appointment_Time" />
                    <asp:BoundField DataField="Complaint" HeaderText="Complaint" SortExpression="Complaint" />
                    <asp:BoundField DataField="CellNo" HeaderText="Cell No" SortExpression="CellNo" />
                    <asp:BoundField DataField="pt_Phone" HeaderText="Phone No" SortExpression="pt_Phone" />
                    <asp:BoundField DataField="Doctor" HeaderText="Doctor" SortExpression="Doctor" />
                </Columns>
            </asp:GridView>

            <!-- Hidden Fields -->
            <asp:HiddenField ID="HiddenField_DayofWeek" runat="server" />
            <asp:HiddenField ID="HiddenField_AppTime" runat="server" />
            <asp:HiddenField ID="HiddenFieldAppointmentDateTime" runat="server" />
            <asp:HiddenField ID="HiddenField_Reg_no" runat="server" />
            <asp:HiddenField ID="hfPayID" runat="server" />
            <asp:HiddenField ID="hfRegno" runat="server" />
            <asp:HiddenField ID="HfAppointmentId" runat="server" Value="0" />

            <!-- Data Sources -->
            <asp:SqlDataSource ID="SqlDataSourcePatient" runat="server" 
                ConnectionString="<%$ ConnectionStrings:Reg_ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:Reg_ConnectionString.ProviderName %>" 
                SelectCommand="uspCheckAlreadySavedAppointment"
                SelectCommandType="StoredProcedure">
                <SelectParameters>
                    <asp:ControlParameter ControlID="HiddenField_Reg_no" Name="Reg_no" PropertyName="Value" Type="String" />
                    <asp:ControlParameter ControlID="HiddenFieldAppointmentDateTime" Name="date" PropertyName="Value" Type="DateTime" />
                </SelectParameters>
            </asp:SqlDataSource>

            <asp:SqlDataSource ID="SqlDataSource_TimeSlot" runat="server" 
                ConnectionString="<%$ ConnectionStrings:Reg_ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:Reg_ConnectionString.ProviderName %>" 
                SelectCommand="SELECT Admin_Doctor_Time_Slice.For_Day, Doctor_Appointment_Slot.App_No, LEFT (CONVERT (varchar, Doctor_Appointment_Slot.Slot_Time, 108), 5) AS Slot_Time, Doctor_Appointment_Slot.Doctor_App_Slot_Id, Week_Day.Day_Name, Admin_Doctor_Time_Slice.Doctor_ID FROM Admin_Doctor_Time_Slice INNER JOIN Doctor_Appointment_Slot ON Admin_Doctor_Time_Slice.Admin_Doctor_Time_ID = Doctor_Appointment_Slot.Admin_Doctor_Time_ID INNER JOIN Week_Day ON Admin_Doctor_Time_Slice.For_Day = Week_Day.Day_ID WHERE (Week_Day.Day_Name = @Day_Name) AND (Admin_Doctor_Time_Slice.Doctor_ID = @For_Doctor) AND (Doctor_Appointment_Slot.Doctor_App_Slot_Id NOT IN (SELECT DISTINCT Doctor_App_Slot_Id FROM Patient_Appointment WHERE (For_Doctor = @For_Doctor) AND (convert(varchar,Appointmant_DateTime,103) = Convert(varchar,@Appointmant_DateTime,103))))">
                <SelectParameters>
                    <asp:ControlParameter ControlID="HiddenField_DayofWeek" Name="Day_Name" PropertyName="Value" Type="String" />
                    <asp:ControlParameter ControlID="DropDownListDoctor_id" Name="For_Doctor" PropertyName="SelectedValue" Type="String" />
                    <asp:ControlParameter ControlID="HiddenFieldAppointmentDateTime" Name="Appointmant_DateTime" PropertyName="Value" Type="DateTime" />
                </SelectParameters>
            </asp:SqlDataSource>

            <asp:SqlDataSource ID="SqlDataSource_City" runat="server" 
                ConnectionString="<%$ ConnectionStrings:Reg_ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:Reg_ConnectionString.ProviderName %>" 
                SelectCommand="SELECT TehsilName as DistrictName, TehsilCode as DistrictCode FROM Tehsil ORDER BY TehsilName">
            </asp:SqlDataSource>
            
            <asp:SqlDataSource ID="SqlDataSourceDoctor" runat="server" 
                ConnectionString="<%$ ConnectionStrings:Basic_Data_ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:Basic_Data_ConnectionString.ProviderName %>"
                SelectCommand="SELECT ISNULL(EFName, '') + ' ' + ISNULL(EMName, '') + ' ' + ISNULL(ELName, '') AS Name, EmpID FROM Employee ORDER BY ISNULL(EFName, '')">
            </asp:SqlDataSource>
        </div>

        <script type="text/javascript">
            // Document Ready
            $(document).ready(function () {
                initializeForm();
                showAgedobfocus();
            });

            // Initialize Form
            function initializeForm() {
                setupInputMasks();
                initializeTooltips();
            }

            // Setup Input Masks
            function setupInputMasks() {
                $('#txtRegNo').on('input', function () {
                    txtChangeMR();
                });

                $('.numeric-only').on('keydown', function (e) {
                    return allowOnlyNumbers(e);
                });
            }

            // Allow Only Numbers
            function allowOnlyNumbers(e) {
                if (e.shiftKey || e.ctrlKey || e.altKey) {
                    e.preventDefault();
                    return false;
                }

                var key = e.keyCode;
                if (!((key == 8) || (key == 9) || (key == 46) ||
                    (key >= 35 && key <= 40) || (key >= 48 && key <= 57) ||
                    (key >= 96 && key <= 105))) {
                    e.preventDefault();
                    return false;
                }
                return true;
            }

            // Initialize Tooltips
            function initializeTooltips() {
                $('[data-tooltip]').each(function () {
                    $(this).attr('title', $(this).data('tooltip'));
                });
            }

            // MR Number Formatting
            function txtChangeMR() {
                var txt = document.getElementById("txtRegNo");
                if (txt) {
                    if (txt.value.length == 2 || txt.value.length == 5) {
                        txt.value = txt.value + "-";
                    }
                }
            }

       
            // AGE â†’ DOB calculate
            function showAgedob() {

                try {

                    var ageCtrl = document.getElementById('<%= textboxage.ClientID %>');
        var indicatorCtrl = document.getElementById('<%= DropDownListBIndicator.ClientID %>');
        var dobCtrl = igedit_getById('<%= WebDateTimeEdit_DOB.ClientID %>');

                    if (!ageCtrl || ageCtrl.value == "") return;
                    if (document.activeElement !== ageCtrl) return;

                    var age = parseInt(ageCtrl.value);

                    if (isNaN(age) || age < 0) return;

                    var indicator = indicatorCtrl.value;

                    var today = new Date();
                    var dob = new Date(today);

                    if (indicator === "Years")
                        dob.setFullYear(today.getFullYear() - age);

                    else if (indicator === "Months")
                        dob.setMonth(today.getMonth() - age);

                    else if (indicator === "Days")
                        dob.setDate(today.getDate() - age);

                    else if (indicator === "Hours")
                        dob.setHours(today.getHours() - age);


                    // DD/MM/YYYY format
                    var day = ("0" + dob.getDate()).slice(-2);
                    var month = ("0" + (dob.getMonth() + 1)).slice(-2);
                    var year = dob.getFullYear();

                    var formatted = day + "/" + month + "/" + year;

                    dobCtrl.setText(formatted);

                }
                catch (e) {

                    console.log("showAgedob error:", e);

                }

            }


            // Indicator change â†’ recalc DOB
            function changeYear() {

                showAgedob();

            }


            function showAgedobfocus() {

                try {

                    var dobCtrl = igedit_getById('<%= WebDateTimeEdit_DOB.ClientID %>');
        var ageCtrl = document.getElementById('<%= textboxage.ClientID %>');
        var indicatorCtrl = document.getElementById('<%= DropDownListBIndicator.ClientID %>');

                    if (!dobCtrl) return;
                  


                    var dobText = dobCtrl.getText();

                    if (!dobText) {

                        ageCtrl.value = "";
                        return;

                    }

                    var parts = dobText.split('/');

                    if (parts.length !== 3) return;

                    var day = parseInt(parts[0]);
                    var month = parseInt(parts[1]) - 1;
                    var year = parseInt(parts[2]);

                    var dob = new Date(year, month, day);

                    var today = new Date();

                    if (dob > today) {

                        ageCtrl.value = "";
                        return;

                    }

                    var diffMs = today - dob;

                    var years = today.getFullYear() - dob.getFullYear();
                    var months = (years * 12) + (today.getMonth() - dob.getMonth());
                    var days = Math.floor(diffMs / (1000 * 60 * 60 * 24));
                    var hours = Math.floor(diffMs / (1000 * 60 * 60));

                    // adjust accurate year
                    if (today.getMonth() < dob.getMonth() ||
                        (today.getMonth() === dob.getMonth() && today.getDate() < dob.getDate())) {

                        years--;

                    }

                    // adjust accurate month
                    if (today.getDate() < dob.getDate()) {

                        months--;

                    }

                    var indicator = indicatorCtrl.value;

                    if (indicator === "Years")
                        ageCtrl.value = years;

                    else if (indicator === "Months")
                        ageCtrl.value = months;

                    else if (indicator === "Days")
                        ageCtrl.value = days;

                    else if (indicator === "Hours")
                        ageCtrl.value = hours;

                }
                catch (e) {

                    console.log("showAgedobfocus error:", e);

                }

            }

            function reloadParent() {
                window.location.reload();
            }

            // Loading indicator
            function showLoading() {
                var loader = $('<div class="spinner"></div>');
                $('body').append(loader);
            }

            function hideLoading() {
                $('.spinner').remove();
            }

            // Form validation
            function validateForm() {
                var isValid = true;
                $('.required').each(function () {
                    if ($(this).val().trim() == '') {
                        $(this).addClass('error');
                        isValid = false;
                    } else {
                        $(this).removeClass('error');
                    }
                });
                return isValid;
            }

            // Collapsible Panel
            var CollapsiblePanel1;
            if (typeof Spry !== 'undefined') {
                CollapsiblePanel1 = new Spry.Widget.CollapsiblePanel("CollapsiblePanel1",
                    { contentIsOpen: false });
            }

            // OPD Number validation
            $(function () {
                $("#txtOPDNo").attr('maxlength', '6');

                $('#ctl00_ContentPlaceHolder1_txtOPDNo').keydown(function (e) {
                    if (e.shiftKey || e.ctrlKey || e.altKey) {
                        e.preventDefault();
                    } else {
                        var key = e.keyCode;
                        if (!((key == 8) || (key == 9) || (key == 46) ||
                            (key >= 35 && key <= 40) || (key >= 48 && key <= 57) ||
                            (key >= 96 && key <= 105))) {
                            e.preventDefault();
                        }
                    }
                });
            });

            // Window resize handler for responsive adjustments
            $(window).on('resize', function () {
                adjustForMobile();
            });

            function adjustForMobile() {
                if ($(window).width() <= 768) {
                    $('.phone-group').addClass('mobile-view');
                    $('.age-group').addClass('mobile-view');
                } else {
                    $('.phone-group').removeClass('mobile-view');
                    $('.age-group').removeClass('mobile-view');
                }
            }

            // Initial call
            adjustForMobile();
        </script>
    </form>
</body>
</html>


