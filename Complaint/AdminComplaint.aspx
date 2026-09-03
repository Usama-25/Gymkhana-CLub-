<%@ Page Title="Manage Questions" Language="C#" MasterPageFile="~/Complaint/Site.master" AutoEventWireup="true" CodeFile="AdminComplaint.aspx.cs" Inherits="RefundFee.AdminComplaint" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <asp:Label ID="lblMessage" runat="server" EnableViewState="false" style="font-family: 'Segoe UI', 'Inter', system-ui, sans-serif; font-size: 14px; font-weight: 500; padding: 12px 16px; border-radius: 12px; margin-bottom: 20px; display: block;" />

 
    <div style="background: #ffffff; border: 1px solid #e9ecef; border-radius: 24px; border-top: 4px solid #f5b042; padding: 28px; margin-bottom: 32px; box-shadow: 0 8px 24px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.02);">
        

        <h3 style="margin: 0 0 24px 0; font-family: 'Segoe UI', Inter, system-ui; font-weight: 700; font-size: 1.5rem; 
                   background: linear-gradient(135deg, #B45309 0%, #D97706 40%, #F59E0B 100%);
                   background-clip: text; -webkit-background-clip: text; color: transparent; 
                   border-bottom: 2px solid #FDE68A; display: inline-block; padding-bottom: 6px;">
            <asp:Literal ID="litMode" runat="server" Text="? Add New Question" />
        </h3>
        
        <asp:HiddenField ID="hfQuestionId" runat="server" Value="0" />

        <div style="margin-bottom: 20px;">
            <asp:Label ID="lblDept" runat="server" Text="?? Department" AssociatedControlID="ddlDepartment" style="display: block; color: #5a6874; font-weight: 500; margin-bottom: 6px; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px;" />
            <asp:DropDownList ID="ddlDepartment" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged" DataTextField="Dept_name" DataValueField="Dept_ID" AppendDataBoundItems="true" style="background: #f8fafc; border: 1px solid #dee2e6; border-radius: 14px; padding: 10px 14px; width: 100%; max-width: 320px; font-family: inherit; font-size: 0.95rem; color: #1e293b; outline: none;">
                <asp:ListItem Text="-- Select Department --" Value="" />
            </asp:DropDownList>
            <asp:RequiredFieldValidator ID="rfvDept" runat="server" ControlToValidate="ddlDepartment" ErrorMessage="Please select a department" Display="Dynamic" style="color: #e25c5c; font-size: 0.75rem; margin-top: 4px; display: block;" InitialValue="" />
        </div>

        <div style="margin-bottom: 20px;">
            <asp:Label ID="lblSubDept" runat="server" Text="?? Sub-Department" AssociatedControlID="ddlSubDepartment" style="display: block; color: #5a6874; font-weight: 500; margin-bottom: 6px; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px;" />
            <asp:DropDownList ID="ddlSubDepartment" runat="server" DataTextField="SubDept_Name" DataValueField="SubDept_Id" AppendDataBoundItems="true" style="background: #f8fafc; border: 1px solid #dee2e6; border-radius: 14px; padding: 10px 14px; width: 100%; max-width: 320px; font-family: inherit; font-size: 0.95rem; color: #1e293b;">
                <asp:ListItem Text="-- Select Sub-Department --" Value="" />
            </asp:DropDownList>
            <asp:RequiredFieldValidator ID="rfvSubDept" runat="server" ControlToValidate="ddlSubDepartment" ErrorMessage="Please select a sub-department" Display="Dynamic" style="color: #e25c5c; font-size: 0.75rem; margin-top: 4px; display: block;" InitialValue="" />
        </div>

        <div style="margin-bottom: 20px;">
            <asp:Label ID="lblQuestionText" runat="server" Text="? Question" AssociatedControlID="txtQuestionText" style="display: block; color: #5a6874; font-weight: 500; margin-bottom: 6px; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px;" />
            <asp:TextBox ID="txtQuestionText" runat="server" style="background: #f8fafc; border: 1px solid #dee2e6; border-radius: 14px; padding: 12px 14px; font-family: inherit; font-size: 0.95rem; color: #1e293b; width: 100%; max-width: 600px; box-sizing: border-box;" />
            <asp:RequiredFieldValidator ID="rfvQuestion" runat="server" ControlToValidate="txtQuestionText" ErrorMessage="Question text is required." Display="Dynamic" style="color: #e25c5c; font-size: 0.75rem; margin-top: 4px; display: block;" />
        </div>

        <div style="margin-bottom: 20px;">
            <asp:Label ID="lblType" runat="server" Text="?? Answer Type" AssociatedControlID="ddlQuestionType" style="display: block; color: #5a6874; font-weight: 500; margin-bottom: 6px; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px;" />
            <asp:DropDownList ID="ddlQuestionType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlQuestionType_SelectedIndexChanged" style="background: #f8fafc; border: 1px solid #dee2e6; border-radius: 14px; padding: 10px 14px; width: 100%; max-width: 240px; font-family: inherit; font-size: 0.95rem; color: #1e293b;">
                <asp:ListItem Text="?? Textbox Answer" Value="TEXT" />
                <asp:ListItem Text="?? Multiple Choice" Value="MCQ" />
            </asp:DropDownList>
        </div>

     
        <asp:Panel ID="pnlOptions" runat="server" Visible="false" style="margin-top: 24px; margin-bottom: 8px; padding: 20px; background: #fefdf7; border-radius: 20px; border: 1px solid #fae6c3;">
            <h4 style="color: #cb7b1f; margin-top: 0; margin-bottom: 16px; font-weight: 600; font-size: 1.1rem;">?? Answer Options</h4>
            <asp:GridView ID="gvOptions" runat="server" AutoGenerateColumns="False" Width="100%" BorderWidth="0" CellPadding="10"
                HeaderStyle-BackColor="#faf3e0" HeaderStyle-ForeColor="#7f5e2e" HeaderStyle-Font-Bold="true" HeaderStyle-Font-Names="Segoe UI, Inter" HeaderStyle-Font-Size="Small"
                RowStyle-BackColor="#ffffff" RowStyle-ForeColor="#2c3e2f" AlternatingRowStyle-BackColor="#fefaf5"
                BorderStyle="None" GridLines="None" style="border-radius: 16px; overflow: hidden;">
                <Columns>
                    <asp:TemplateField HeaderText="Option Text">
                        <ItemTemplate>
                            <asp:TextBox ID="txtOptionText" runat="server" Text='<%# Eval("OptionText") %>' Width="280px" style="background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 8px 12px; font-family: inherit;" />
                            <asp:HiddenField ID="hfOptId" runat="server" Value='<%# Eval("Id") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Soft Delete">
                        <ItemTemplate>
                            <asp:CheckBox ID="chkIsDeleted" runat="server" Checked='<%# Convert.ToBoolean(Eval("IsDeleted")) %>' style="accent-color: #e6a017; transform: scale(1.05);" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <div style="margin-top: 16px; display: flex; gap: 10px; align-items: center;">
                <asp:TextBox ID="txtNewOption" runat="server" Width="260px" placeholder="New option text" style="background: #fff; border: 1px solid #e2e8f0; border-radius: 40px; padding: 8px 16px; font-family: inherit; flex: 1;" />
                <asp:Button ID="btnAddOption" runat="server" Text="+ Add Option" OnClick="btnAddOption_Click" 
                    style="background: transparent; border: 1.5px solid #e6a017; color: #b56d0e; font-weight: 600; padding: 8px 18px; border-radius: 40px; cursor: pointer; font-family: inherit;" />
            </div>
        </asp:Panel>

        <div style="margin-top: 32px; display: flex; gap: 14px;">
            <asp:Button ID="btnSave" runat="server" Text="?? Save Question" OnClick="btnSave_Click" 
                style="background: #f5b042; border: none; color: #ffffff; font-weight: 600; padding: 10px 28px; border-radius: 40px; cursor: pointer; font-family: inherit; font-size: 0.9rem; box-shadow: 0 2px 6px rgba(245,176,66,0.2);" />
            <asp:Button ID="btnCancel" runat="server" Text="?? Cancel" OnClick="btnCancel_Click" CausesValidation="false"
                style="background: #f1f3f5; border: 1px solid #dee2e6; color: #5a6874; font-weight: 500; padding: 10px 28px; border-radius: 40px; cursor: pointer; font-family: inherit;" />
        </div>
    </div>

    
    <div style="background: #ffffff; border-radius: 24px; padding: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.02), 0 1px 2px rgba(0,0,0,0.03); border: 1px solid #edf2f7;">
        <h3 style="margin: 0 0 16px 0; font-family: 'Segoe UI', Inter, system-ui; font-weight: 700; font-size: 1.4rem; 
                   background: linear-gradient(135deg, #B45309 0%, #D97706 40%, #F59E0B 100%);
                   background-clip: text; -webkit-background-clip: text; color: transparent; 
                   border-bottom: 2px solid #FDE68A; display: inline-block; padding-bottom: 4px;">
            ?? All Questions
        </h3>
        
        <div style="overflow-x: auto; border-radius: 16px; border: 1px solid #FDE68A; background: white;">
            <asp:GridView ID="gvQuestions" runat="server" AutoGenerateColumns="False" DataKeyNames="Id" OnRowCommand="gvQuestions_RowCommand" Width="100%"
                BorderStyle="None" GridLines="None" CellPadding="12" CellSpacing="0"
                Font-Names="'Segoe UI', Inter, system-ui, sans-serif" Font-Size="13px"
                style="border-collapse: separate; border-spacing: 0; width: 100%;">
                
                <HeaderStyle HorizontalAlign="Left" VerticalAlign="Middle"
                    BackColor="#FEF3C7" ForeColor="#92400E" Font-Bold="true"
                    BorderStyle="None" BorderWidth="0" />
                
                <RowStyle BackColor="#ffffff" ForeColor="#334155" BorderStyle="None" />
                <AlternatingRowStyle BackColor="#FFFBEB" ForeColor="#334155" BorderStyle="None" />
                
                <Columns>
                    
                    <asp:TemplateField HeaderText="S.No" ItemStyle-Width="60px" ItemStyle-HorizontalAlign="Center"
                                       HeaderStyle-Width="60px" HeaderStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:BoundField DataField="Dept_name" HeaderText="Department" />
                    <asp:BoundField DataField="SubDept_Name" HeaderText="Sub-Department" />
                    <asp:BoundField DataField="QuestionText" HeaderText="Question" />
                    <asp:BoundField DataField="QuestionType" HeaderText="Type" ItemStyle-Width="100px" />
                    
                    <asp:TemplateField HeaderText="Actions" ItemStyle-Width="160px">
                        <ItemTemplate>
                            <asp:Button ID="btnEdit" runat="server" Text="?? Edit" CommandName="EditQuestion" CausesValidation="false" CommandArgument='<%# Eval("Id") %>'
                                style="background: #fff; border: 1px solid #e2e8f0; color: #e6a017; font-weight: 500; padding: 5px 14px; border-radius: 30px; cursor: pointer; margin-right: 8px; font-family: inherit;" />
                            <asp:Button ID="btnDelete" runat="server" Text="??? Soft Delete" CommandName="DeleteQuestion" CommandArgument='<%# Eval("Id") %>' OnClientClick="return confirm('Soft delete this question?');"
                                style="background: #fff; border: 1px solid #ffe2e2; color: #e25c5c; font-weight: 500; padding: 5px 14px; border-radius: 30px; cursor: pointer; font-family: inherit;" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

   
    <script type="text/javascript">
        document.addEventListener("DOMContentLoaded", function() {
            var grid = document.getElementById("<%= gvQuestions.ClientID %>");
            if (grid) {
                var rows = grid.getElementsByTagName("tr");
                for (var i = 0; i < rows.length; i++) {
                    
                    if (i === 0) continue;
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
