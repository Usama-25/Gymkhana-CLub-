<%@ Page Title="Manage Reservations" Language="C#" MasterPageFile="~/Complaint/Site.master"
    AutoEventWireup="true" CodeFile="AdminViewComplaints.aspx.cs"
    Inherits="GuestRoomApp.GuestRoomM.CancelRoomReservation" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Label ID="lblMessage" runat="server" EnableViewState="false" 
        style="font-family: 'Segoe UI', Inter, sans-serif; font-size: 13px; font-weight: 500; padding: 8px 12px; border-radius: 10px; margin-bottom: 16px; display: block;" />

    <div style="background: #ffffff; border-radius: 24px; padding: 20px; border: 1px solid #edf2f7; border-top: 4px solid #f5b042;">
        
        <!-- Filter Row -->
        <div style="display: flex; flex-wrap: wrap; gap: 10px; align-items: flex-end; margin-bottom: 24px;">
            <div style="flex: 1; min-width: 120px;">
                <asp:Label ID="lblFilterMemberNo" runat="server" Text="Member No" AssociatedControlID="txtFilterMemberNo" 
                    style="display: block; color: #5a6874; font-size: 0.7rem; margin-bottom: 4px;" />
                <asp:TextBox ID="txtFilterMemberNo" runat="server" 
                    style="background: #f8fafc; border: 1px solid #dee2e6; border-radius: 12px; padding: 6px 10px; width: 100%; box-sizing: border-box; font-size: 0.85rem;" />
            </div>
            <div style="min-width: 140px;">
                <asp:Label ID="lblFilterDept" runat="server" Text="Department" AssociatedControlID="ddlFilterDept" 
                    style="display: block; color: #5a6874; font-size: 0.7rem; margin-bottom: 4px;" />
                <asp:DropDownList ID="ddlFilterDept" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterDept_SelectedIndexChanged"
                    style="background: #f8fafc; border: 1px solid #dee2e6; border-radius: 12px; padding: 6px 10px; width: 100%; box-sizing: border-box; font-size: 0.85rem;">
                    <asp:ListItem Text="-- All --" Value="" />
                </asp:DropDownList>
            </div>
            <div style="min-width: 140px;">
                <asp:Label ID="lblFilterSubDept" runat="server" Text="Sub-Dept" AssociatedControlID="ddlFilterSubDept" 
                    style="display: block; color: #5a6874; font-size: 0.7rem; margin-bottom: 4px;" />
                <asp:DropDownList ID="ddlFilterSubDept" runat="server"
                    style="background: #f8fafc; border: 1px solid #dee2e6; border-radius: 12px; padding: 6px 10px; width: 100%; box-sizing: border-box; font-size: 0.85rem;">
                    <asp:ListItem Text="-- All --" Value="" />
                </asp:DropDownList>
            </div>
            <div style="min-width: 120px;">
                <asp:Label ID="lblFromDate" runat="server" Text="From" AssociatedControlID="txtFromDate" 
                    style="display: block; color: #5a6874; font-size: 0.7rem; margin-bottom: 4px;" />
                <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" 
                    style="background: #f8fafc; border: 1px solid #dee2e6; border-radius: 12px; padding: 6px 10px; width: 100%; box-sizing: border-box; font-size: 0.85rem;" />
            </div>
            <div style="min-width: 120px;">
                <asp:Label ID="lblToDate" runat="server" Text="To" AssociatedControlID="txtToDate" 
                    style="display: block; color: #5a6874; font-size: 0.7rem; margin-bottom: 4px;" />
                <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" 
                    style="background: #f8fafc; border: 1px solid #dee2e6; border-radius: 12px; padding: 6px 10px; width: 100%; box-sizing: border-box; font-size: 0.85rem;" />
            </div>
            
            <!-- SINGLE FILTER: Feedback / Answer Option -->
            <div style="min-width: 160px;">
                <asp:Label ID="lblFilterFeedback" runat="server" Text="Feedback" AssociatedControlID="ddlFilterFeedback" 
                    style="display: block; color: #5a6874; font-size: 0.7rem; margin-bottom: 4px;" />
                <asp:DropDownList ID="ddlFilterFeedback" runat="server"
                    style="background: #f8fafc; border: 1px solid #dee2e6; border-radius: 12px; padding: 6px 10px; width: 100%; box-sizing: border-box; font-size: 0.85rem;">
                    <asp:ListItem Text="-- All Feedback --" Value="" />
                </asp:DropDownList>
            </div>
            
            <div>
                <asp:Button ID="btnFilter" runat="server" Text="Apply" OnClick="btnFilter_Click" 
                    style="background: #f5b042; border: none; color: white; font-weight: 600; padding: 6px 18px; border-radius: 30px; cursor: pointer; font-size: 0.85rem;" />
            </div>
            <div>
                <asp:Button ID="btnReset" runat="server" Text="Reset" OnClick="btnReset_Click" CausesValidation="false"
                    style="background: #f1f3f5; border: 1px solid #dee2e6; color: #5a6874; font-weight: 500; padding: 6px 18px; border-radius: 30px; cursor: pointer; font-size: 0.85rem;" />
            </div>
        </div>

        <!-- Grid Heading -->
        <h3 style="margin: 0 0 16px 0; font-family: 'Segoe UI', Inter, system-ui; font-weight: 700; font-size: 1.4rem; 
                   background: linear-gradient(135deg, #B45309 0%, #D97706 40%, #F59E0B 100%);
                   background-clip: text; -webkit-background-clip: text; color: transparent; 
                   border-bottom: 2px solid #FDE68A; display: inline-block; padding-bottom: 4px;">
            Member Complaints
        </h3>
        
        <!-- GridView -->
        <div style="overflow-x: auto; border-radius: 16px; border: 1px solid #FDE68A; background: white;">
            <asp:GridView ID="gvComplaints" runat="server" AutoGenerateColumns="False" Width="100%"
                BorderStyle="None" GridLines="None" CellPadding="12" CellSpacing="0"
                Font-Names="'Segoe UI', Inter, system-ui, sans-serif" Font-Size="13px"
                style="border-collapse: separate; border-spacing: 0; width: 100%;"
                OnRowDataBound="gvComplaints_RowDataBound">
                
                <HeaderStyle HorizontalAlign="Left" VerticalAlign="Middle"
                    BackColor="#FEF3C7" ForeColor="#92400E" Font-Bold="true"
                    BorderStyle="None" BorderWidth="0" />
                
                <RowStyle BackColor="#ffffff" ForeColor="#334155" BorderStyle="None" />
                <AlternatingRowStyle BackColor="#FFFBEB" ForeColor="#334155" BorderStyle="None" />
                
                <Columns>
                    <asp:BoundField DataField="SerialNumber" HeaderText="S.No" ReadOnly="true" 
                        ItemStyle-Width="60px" ItemStyle-HorizontalAlign="Center"
                        HeaderStyle-Width="60px" HeaderStyle-HorizontalAlign="Center" />
                    
                    <asp:BoundField DataField="MemberNumber" HeaderText="Member No" 
                        ItemStyle-Width="110px" />
                    
                    <asp:BoundField DataField="MemberName" HeaderText="Member Name" 
                        ItemStyle-Width="160px" />
                    
                    <asp:BoundField DataField="Dept_name" HeaderText="Department" 
                        ItemStyle-Width="140px" />
                    
                    <asp:BoundField DataField="SubDept_Name" HeaderText="Sub-Dept" 
                        ItemStyle-Width="130px" />
                    
                    <asp:BoundField DataField="SubmittedDate" HeaderText="Submitted" 
                        DataFormatString="{0:yyyy-MM-dd HH:mm}" ItemStyle-Width="150px" />
                    
                    <asp:TemplateField HeaderText="Questions &amp; Answers" ItemStyle-Width="400px">
                        <ItemTemplate>
                            <asp:Literal ID="litQA" runat="server" Text='<%# Eval("QA_Concat") %>' Mode="PassThrough" />
                        </ItemTemplate>
                        <ItemStyle VerticalAlign="Top" />
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- Hover + Border Script -->
    <script type="text/javascript">
        document.addEventListener("DOMContentLoaded", function() {
            var grid = document.getElementById("<%= gvComplaints.ClientID %>");
            if (grid) {
                var rows = grid.getElementsByTagName("tr");
                for (var i = 0; i < rows.length; i++) {
                    rows[i].addEventListener("mouseenter", function () {
                        this.style.backgroundColor = "#fef3e8";
                    });
                    rows[i].addEventListener("mouseleave", function () {
                        this.style.backgroundColor = "";
                    });
                }
                var allRows = grid.rows;
                for (var r = 0; r < allRows.length; r++) {
                    var cells = allRows[r].cells;
                    for (var c = 0; c < cells.length; c++) {
                        if (r < allRows.length - 1) {
                            cells[c].style.borderBottom = "1px solid #f0f2f5";
                        } else {
                            cells[c].style.borderBottom = "none";
                        }
                    }
                }
            }
        });
    </script>
</asp:Content>
