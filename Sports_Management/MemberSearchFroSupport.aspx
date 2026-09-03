<%@ Page Title="" Language="C#" MasterPageFile="~/hacims_masterpage_admin.master" 
    AutoEventWireup="true" CodeFile="MemberSearchFroSupport.aspx.cs" Inherits="RefundFee.MemberSearchFroSupport" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
   <%-- <style>
        .search-container { width: 100%; display: flex; justify-content: center; margin-top: 40px; }
        .search-card { background: #ffffff; padding: 30px 40px; border-radius: 15px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); max-width: 700px; width: 100%; }
        .heading { width: 100%; background-color: #3498db; color: white; padding: 10px; margin-bottom: 20px; border-radius: 4px; text-align: center; }
        .fields { width: 100%; display: flex; justify-content: center; align-items: center; gap: 10px; flex-wrap: wrap; }
        .form-group { flex: 1 1 200px; display: flex; flex-direction: column; margin-bottom: 10px; }
        .form-group label { font-weight: 600; margin-bottom: 5px; color: #34495e; }
        .form-group input[type="text"] { width: 100%; padding: 10px 12px; border: 1px solid #ccc; border-radius: 8px; font-size: 14px; }
        .btn12 { display: flex; justify-content: center; align-items: center; margin-top: 15px; }
        .btnSearch { width: 200px; padding: 12px; background: linear-gradient(135deg, #6a11cb, #2575fc); border: none; border-radius: 8px; color: white; font-size: 16px; font-weight: 600; cursor: pointer; }
        .grid-wrapper { margin-top: 30px; overflow-x: auto; }
        .grid-style { width: 100%; border-collapse: collapse; }
        .grid-style th { background: #3498db; color: white; padding: 10px; text-align: center; }
        .grid-style td { padding: 10px; text-align: center; background: #f9f9f9; }
        .grid-style tr:nth-child(even) td { background: #eef2f5; }
        .grid-style tr:hover td { background: #d6eaf8; }

        .grid-wrapper { width: 90%; margin: 40px auto; overflow-x: auto; }
        .grid-style { width: 100%; border-collapse: collapse; font-family: Arial, sans-serif; }
        .grid-style th { background-color: #3498db; color: #fff; padding: 10px; text-align: center; }
        .grid-style td { padding: 10px; text-align: center; background-color: #f9f9f9; }
        .grid-style tr:nth-child(even) td { background-color: #eef2f5; }
        .grid-style tr:hover td { background-color: #d6eaf8; }
        .btnAction { padding: 5px 12px; background: #e74c3c; color: #fff; border: none; border-radius: 5px; cursor: pointer; }
        .btnAction:hover { background: #c0392b; }
    </style>--%>
</asp:Content>

<%--<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

   <asp:ScriptManager ID="ScriptManager1" runat="server" />

<div class="search-container">
    <div class="search-card">
        <div class="heading"><h2>Search Members</h2></div>

       
        <asp:Label ID="lblMessage" runat="server" ForeColor="Red" Font-Bold="true"></asp:Label><br/>

        <div class="fields">
            <div class="form-group">
                <label>Department</label>
                <asp:DropDownList ID="ddlDepartment" runat="server">
                  
                </asp:DropDownList>
            </div>

            <div class="form-group">
                <label>Member No</label>
                <asp:TextBox ID="txtMemberNo" runat="server" ReadOnly="true"></asp:TextBox>
            </div>

            <div class="form-group">
                <label>Card No</label>
                <asp:TextBox ID="txtCardNo" runat="server"></asp:TextBox>
            </div>

            <div class="form-group">
                <label>Name</label>
                <asp:TextBox ID="Name" runat="server"></asp:TextBox>
            </div>

            <div class="form-group">
                <label>RF ID</label>
                <asp:TextBox ID="txtRFID" runat="server"></asp:TextBox>
                
            </div>

            <div class="form-group">
                <label>NIC</label>
                <asp:TextBox ID="txtNIC" runat="server"></asp:TextBox>
            </div>
        </div>

        <div class="btn12">
            <asp:Button ID="btnSave" runat="server" Text="Search" CssClass="btnSearch" OnClick="btnSaveCard_Click" />
        </div>
    </div>
</div>




<asp:GridView ID="GridViewBatchStock" runat="server" AutoGenerateColumns="False">
    <Columns>
        <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
        <asp:BoundField DataField="ApplicantName" HeaderText="Name" />
        <asp:BoundField DataField="NIC" HeaderText="NIC" />
        <asp:BoundField DataField="CardNo" HeaderText="Card No" />
    </Columns>
</asp:GridView>



</asp:Content>--%>





<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    
   
    <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f7fa; min-height: 100vh; padding: 6px;">
        
        
        <div style="margin-bottom: 30px;">
            <h1 style="color: #2c3e50; font-weight: 300; margin-bottom: 5px;">Sport Management System</h1>
           
        </div>
        
        
        <div style="margin-bottom: 20px;">
            <asp:Label ID="lblMessage" runat="server" ForeColor="#e74c3c" Font-Bold="true" 
                style="display: inline-block; padding: 12px 20px; border-radius: 6px; background-color: rgba(231, 76, 60, 0.1); border-left: 4px solid #e74c3c; width: 100%; box-sizing: border-box;"></asp:Label>
        </div>
        
       
        <div style="background-color: white; border-radius: 10px; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05); padding: 12px; margin-bottom: 2px;">
            <div style="margin-bottom: 25px;">
                <h2 style="color: #3498db; font-weight: 500; margin: 0 0 10px 0; font-size: 24px;">Search Members</h2>
                
            </div>
            
           
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 10px; margin-bottom: 30px;">
               
                <div>
                    <label style="display: block; color: #2c3e50; font-weight: 500; margin-bottom: 8px; font-size: 14px;">
                        Department 
                    </label>
                    <asp:DropDownList ID="ddlDepartment" runat="server" 
                        style="width: 100%; padding: 0px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 15px; color: #2c3e50; background-color: #f9f9f9; transition: border-color 0.3s; box-sizing: border-box;">
                    </asp:DropDownList>
                </div>
                
                <div>
                    <label style="display: block; color: #2c3e50; font-weight: 500; margin-bottom: 8px; font-size: 14px;">
                        Member No
                    </label>
                    <asp:TextBox ID="txtMemberNo" runat="server"  
                        style="width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 15px; color: #7f8c8d; background-color: #f0f0f0; box-sizing: border-box;"></asp:TextBox>
                    
                </div>
                
              
                <div>
                    <label style="display: block; color: #2c3e50; font-weight: 500; margin-bottom: 8px; font-size: 14px;">
                        Card No 
                    </label>
                    <asp:TextBox ID="txtCardNo" runat="server" 
                        style="width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 15px; color: #2c3e50; transition: border-color 0.3s; box-sizing: border-box;"></asp:TextBox>
                </div>
                
                <div>
                    <label style="display: block; color: #2c3e50; font-weight: 500; margin-bottom: 8px; font-size: 14px;">
                        Name 
                    </label>
                    <asp:TextBox ID="Name" runat="server" 
                        style="width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 15px; color: #2c3e50; transition: border-color 0.3s; box-sizing: border-box;"></asp:TextBox>
                </div>
                
               
                <div>
                    <label style="display: block; color: #2c3e50; font-weight: 500; margin-bottom: 8px; font-size: 14px;">
                        RFID 
                    </label>
                    <asp:TextBox ID="txtRFID" runat="server" 
                        style="width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 15px; color: #2c3e50; transition: border-color 0.3s; box-sizing: border-box;"></asp:TextBox>
                </div>
                
                <div>
                    <label style="display: block; color: #2c3e50; font-weight: 500; margin-bottom: 8px; font-size: 14px;">
                        NIC 
                    </label>
                    <asp:TextBox ID="txtNIC" runat="server" 
                        style="width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 15px; color: #2c3e50; transition: border-color 0.3s; box-sizing: border-box;"></asp:TextBox>
                </div>
                <div style="text-align: center; margin-top: 20px;">
                <asp:Button ID="btnSave" runat="server" Text="Search Members" CssClass="btnSearch" OnClick="btnSaveCard_Click" 
                    style="background: linear-gradient(135deg, #3498db 0%, #2980b9 100%); color: white; border: none; padding: 0px 40px; font-size: 16px; font-weight: 500; border-radius: 6px; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(52, 152, 219, 0.2); margin: 0 10px;" 
                    onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 6px 12px rgba(52, 152, 219, 0.3)';" 
                    onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 6px rgba(52, 152, 219, 0.2)';" />
              
            
        </div>
            </div>
            
            
            
        
        
        <div style="background-color: white; border-radius: 10px; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05); padding: 2px;">
          
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2 style="color: #2c3e50; font-weight: 500; margin: 0; font-size: 22px;">Search Results</h2>
               
            </div>
            
            
            <div style="overflow: auto; border-radius: 8px; border: 1px solid #eaeaea;">
                <asp:GridView ID="GridViewBatchStock" runat="server" AutoGenerateColumns="False" 
                    style="width: 100%; border-collapse: collapse; min-width: 800px;"
                    HeaderStyle-BackColor="#3498db" 
                    HeaderStyle-ForeColor="White"
                    HeaderStyle-Font-Bold="true"
                    HeaderStyle-Height="50px"
                    HeaderStyle-HorizontalAlign="Center"
                    RowStyle-Height="45px"
                    RowStyle-HorizontalAlign="Center"
                    AlternatingRowStyle-BackColor="#f8f9fa"
                    BorderColor="#e0e0e0"
                    BorderWidth="0"
                    CellPadding="8">
                    
                    <Columns>
                        <asp:TemplateField HeaderText="Sr#" HeaderStyle-Width="60px">
                            <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="MemberID" HeaderText="MemberID">
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:BoundField>
                        <asp:BoundField DataField="MemberNo" HeaderText="Member No">
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:BoundField>
                        <asp:BoundField DataField="ApplicantName" HeaderText="Name">
                            <ItemStyle HorizontalAlign="Left" />
                        </asp:BoundField>
                        <asp:BoundField DataField="NIC" HeaderText="NIC">
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:BoundField>
                        <asp:BoundField DataField="CardNo" HeaderText="Card No">
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:BoundField>

                   <asp:TemplateField HeaderText="Action">
    <ItemTemplate>
        <asp:HyperLink ID="hlView" runat="server"
            Text="View Details"
            CssClass="link-button"
            NavigateUrl='<%# "~/Sports_Management/MemberSearchForSubscription.aspx?MemberID=" 
                + Eval("MemberID") 
                + "&MemberNo=" + Eval("MemberNo") 
                + "&Name=" + Server.UrlEncode(Eval("ApplicantName").ToString()) 
                + "&NIC=" + Eval("NIC") 
                + "&CardNo=" + Eval("CardNo") %>'>
        </asp:HyperLink>
    </ItemTemplate>
</asp:TemplateField>

                    </Columns>
                    
                    <EmptyDataTemplate>
                        <div style="text-align: center; padding: 60px 20px; color: #7f8c8d; min-height: 300px;">
                            <div style="font-size: 80px; color: #ecf0f1; margin-bottom: 20px;">🔍</div>
                            <h3 style="color: #95a5a6; font-weight: 400; margin-bottom: 15px; font-size: 22px;">No Members Found</h3>
                            <p style="font-size: 16px; margin-bottom: 30px; max-width: 500px; margin-left: auto; margin-right: auto;">
                                Your search didn't return any results. Try different search criteria or clear the form to see all members.
                            </p>
                            <button onclick="clearFormAndSearch();" style="background: #3498db; color: white; border: none; padding: 12px 30px; font-size: 16px; border-radius: 6px; cursor: pointer; transition: background 0.3s;" onmouseover="this.style.backgroundColor='#2980b9';" onmouseout="this.style.backgroundColor='#3498db';">Show All Members</button>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
            
          
        
       
        
    </div>
    
    <style type="text/css">
        
        #<%= GridViewBatchStock.ClientID %> th {
            background-color: #3498db !important;
            color: white !important;
            font-weight: 500 !important;
            padding: 15px !important;
            border-bottom: 2px solid #2980b9 !important;
            text-align: center !important;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        
        
        #<%= GridViewBatchStock.ClientID %> tr {
            border-bottom: 1px solid #f0f0f0;
            color: #2c3e50;
            transition: background-color 0.2s;
        }
        
        /* Style alternating rows */
        #<%= GridViewBatchStock.ClientID %> tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        /* Style table cells */
        #<%= GridViewBatchStock.ClientID %> td {
            padding: 15px !important;
            vertical-align: middle !important;
            border-bottom: 1px solid #f0f0f0;
        }
        
        /* Make Member No column bold */
        #<%= GridViewBatchStock.ClientID %> td:first-child {
            font-weight: bold !important;
            color: #2c3e50;
        }
        
        /* Selected row style */
        .selected-row {
            background-color: #e3f2fd !important;
            font-weight: bold !important;
        }
        
        /* Remove default ASP.NET table borders */
        #<%= GridViewBatchStock.ClientID %> {
            border: none !important;
        }
        
        /* Improve the dropdown arrow appearance */
        select {
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            background-image: url('data:image/svg+xml;utf8,<svg fill="%232c3e50" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/></svg>');
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 20px;
            padding-right: 40px !important;
        }
        
        /* Input field focus effects */
        input[type="text"]:focus, select:focus {
            outline: none;
            border-color: #3498db !important;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.2) !important;
        }
        
        /* Button styles */
        .btnSearch:hover {
            transform: translateY(-2px) !important;
            box-shadow: 0 6px 12px rgba(52, 152, 219, 0.3) !important;
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .search-container {
                flex-direction: column;
            }
            
            .search-card, .results-panel {
                min-width: 100% !important;
            }
            
            .fields {
                grid-template-columns: 1fr !important;
            }
            
            #<%= GridViewBatchStock.ClientID %> th,
            #<%= GridViewBatchStock.ClientID %> td {
                padding: 10px 5px !important;
                font-size: 14px;
            }
            
            /* Make results header responsive */
            .results-header {
                flex-direction: column;
                align-items: flex-start !important;
                gap: 10px;
            }
            
            .results-header h2 {
                margin-bottom: 10px;
            }
        }
    </style>
</asp:Content>

