<%@ Page Title="Sport Services" Language="C#" MasterPageFile="~/hacims_masterpage_admin.master"
    AutoEventWireup="true" CodeFile="AdminAssignSportServices.aspx.cs"
    Inherits="AdminAssignSportServices" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>


<%--<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

    <div class="form-container" style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 1400px; margin: 0 auto; padding: 25px; background-color: #f8f9fa; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.08);">

      
        <div style="text-align: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 2px solid #4a6fa5;">
            <h1 style="color: #2c3e50; font-size: 32px; font-weight: 600; margin-bottom: 8px; letter-spacing: 0.5px;">
                <i class="fas fa-utensils" style="margin-right: 12px; color: #e74c3c;"></i>Sport  Management
            </h1>
           
        </div>

       
       <div style="background-color: white; padding: 25px; border-radius: 8px; margin-bottom: 30px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
    <h3 style="color: #3498db; font-size: 20px; margin-top: 0; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #eee;">
        <i class="fas fa-filter" style="margin-right: 10px;"></i> Add Sports Services
    </h3>

    <div style="display: flex; gap: 20px; flex-wrap: wrap;">

       
        <div style="flex: 1; min-width: 250px;">
            <asp:Label ID="lblDepartment" runat="server"
                Text="Department:"
                style="display: block; font-weight: 600; color: #2c3e50; margin-bottom: 8px; font-size: 14px;" />
            
            <asp:DropDownList ID="ddlDepartment" runat="server"
                AutoPostBack="true"
               OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged"
                style="width:100%; padding: 0px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 15px; background-color: white;"
                onfocus="this.style.borderColor='#3498db'; this.style.boxShadow='0 0 0 3px rgba(52, 152, 219, 0.2)';"
                onblur="this.style.borderColor='#ddd'; this.style.boxShadow='none';">
            </asp:DropDownList>
        </div>

        
        <div style="flex: 1; min-width: 250px;">
            <asp:Label ID="lblSubDepartment" runat="server"
                Text="Add Services:"
                style="display: block; font-weight: 600; color: #2c3e50; margin-bottom: 8px; font-size: 14px;" />

            <asp:TextBox ID="txtServices" runat="server"
                style="width:100%; padding: 8px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 15px; background-color: white;"
                onfocus="this.style.borderColor='#3498db'; this.style.boxShadow='0 0 0 3px rgba(52, 152, 219, 0.2)';"
                onblur="this.style.borderColor='#ddd'; this.style.boxShadow='none';">
            </asp:TextBox>
        </div>

       
        <div style="flex: 1; min-width: 250px;">
            <asp:Label ID="lblRecipe" runat="server"
                Text="Amount:"
                style="display: block; font-weight: 600; color: #2c3e50; margin-bottom: 8px; font-size: 14px;" />

            <asp:TextBox ID="txtamonut" runat="server"
                style="width:100%; padding: 8px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 15px; background-color: white;"
                onfocus="this.style.borderColor='#3498db'; this.style.boxShadow='0 0 0 3px rgba(52, 152, 219, 0.2)';"
                onblur="this.style.borderColor='#ddd'; this.style.boxShadow='none';">
            </asp:TextBox>
        </div>



         <div style="flex: 1; min-width: 250px;">
            <asp:Label ID="lbl" runat="server"
                
                style="display: block; font-weight: 600; color: #2c3e50; margin-bottom: 8px; font-size: 14px;" />
             
            <asp:Button ID="btnSavePrices" runat="server"
                            Text="Save Prices"
                           OnClick="btnSavePrices_Click"
                            style="background: linear-gradient(135deg, #2ecc71 0%, #27ae60 100%);margin-left: 70px; margin-top: 13px; color: white; border: none; padding: 0px 28px; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(46, 204, 113, 0.2);"
                            onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 6px 10px rgba(46, 204, 113, 0.3)';"
                            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 6px rgba(46, 204, 113, 0.2)';"></asp:Button>
        </div>



    </div>
</div>
            

        <div style="background-color: white; padding: 25px; border-radius: 8px; margin-bottom: 30px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
            <h3 style="color: #2ecc71; font-size: 20px; margin-top: 0; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #eee;">
                <i class="fas fa-clipboard-list" style="margin-right: 10px;"></i> Details
            </h3>
            
            <asp:GridView ID="gvRecipeMain" runat="server"
                AutoGenerateColumns="False"
                
                style="width: 100%; border-collapse: separate; border-spacing: 0; border: 1px solid #e1e5e9; border-radius: 8px; overflow: hidden;"
                HeaderStyle-BackColor="#2c3e50"
                HeaderStyle-ForeColor="white"
                HeaderStyle-Font-Bold="true"
                RowStyle-BackColor="white"
                AlternatingRowStyle-BackColor="#f8f9fa"
                CellPadding="10"
                CellSpacing="0">
                
                <HeaderStyle BackColor="#006666" ForeColor="White" Font-Bold="true" Height="45px" />
                <RowStyle BackColor="white" Height="50px" />
                <AlternatingRowStyle BackColor="#f8f9fa" />
                
                <Columns>
                   <asp:BoundField DataField="Dept_Name" HeaderText="Department" />
                    <asp:BoundField DataField="ServiceName" HeaderText="Service Name" />
        <asp:BoundField DataField="Amount" HeaderText="Amount" />

                    
                 
                </Columns>
            </asp:GridView>
        </div>

    
    

    </div>

  
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

</asp:Content>--%>



<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

    <div class="form-container" style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 1400px; margin: 0 auto; padding: 25px; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.12);">

        <div class="header-section" style="text-align: center; margin-bottom: 40px; padding: 0px; background: linear-gradient(135deg, #1a2980 0%, #26d0ce 100%); border-radius: 12px; color: white; box-shadow: 0 6px 20px rgba(26, 41, 128, 0.3);">
            <div style="display: flex; align-items: center; justify-content: center; gap: 20px; margin-bottom: 15px;">
                <div style="font-size: 20px; background: rgba(255,255,255,0.15); width: 80px; height: 80px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                    <i class="fas fa-dumbbell" style="color: white;"></i>
                </div>
                <h1 style="color: white; font-size: 25px; font-weight: 700; margin: 0; letter-spacing: 1px; text-shadow: 0 2px 4px rgba(0,0,0,0.2);">
                    Sports Management System
                </h1>
            </div>
            
        </div>

        
        <div style="background: white; padding:5px; border-radius: 12px; margin-bottom: 30px; box-shadow: 0 6px 20px rgba(0,0,0,0.08); border-left: 5px solid #3498db;">
            <div style="display: flex; align-items: center; margin-bottom: 7px; padding-bottom: 7px; border-bottom: 1px solid #eee;">
                <div style="background: #3498db; color: white; width: 42px; height: 42px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 15px; font-size: 18px;">
                    <i class="fas fa-plus-circle"></i>
                </div>
                <h3 style="color: #2c3e50; font-size: 22px; font-weight: 600; margin: 0;">
                    Add New Sports Service
                </h3>
            </div>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 25px;">

                <div class="form-field">
                    <asp:Label ID="lblDepartment" runat="server"
                        Text="Department:"
                        style="display: block; font-weight: 600; color: #2c3e50; margin-bottom: 10px; font-size: 14px; letter-spacing: 0.3px;" />
                    <div style="position: relative;">
                        <div style="position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #3498db; z-index: 1;">
                            <i class="fas fa-building"></i>
                        </div>
                        <asp:DropDownList ID="ddlDepartment" runat="server"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged"
                            style="width:100%; padding: 0px 15px 2px 45px; border: 2px solid #e1e5eb; border-radius: 8px; font-size: 15px; background-color: white; color: #333; transition: all 0.3s;"
                            onfocus="this.style.borderColor='#3498db'; this.style.boxShadow='0 0 0 3px rgba(52, 152, 219, 0.15)';"
                            onblur="this.style.borderColor='#e1e5eb'; this.style.boxShadow='none';">
                        </asp:DropDownList>
                    </div>
                </div>

               
                <div class="form-field">
                    <asp:Label ID="lblSubDepartment" runat="server"
                        Text="Service Name:"
                        style="display: block; font-weight: 600; color: #2c3e50; margin-bottom: 10px; font-size: 14px; letter-spacing: 0.3px;" />
                    <div style="position: relative;">
                        <div style="position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #3498db; z-index: 1;">
                            <i class="fas fa-futbol"></i>
                        </div>
                        <asp:TextBox ID="txtServices" runat="server"
                            placeholder="Enter service name"
                            style="width:100%; padding: 12px 15px 12px 45px; border: 2px solid #e1e5eb; border-radius: 8px; font-size: 15px; background-color: white; color: #333; transition: all 0.3s;"
                            onfocus="this.style.borderColor='#3498db'; this.style.boxShadow='0 0 0 3px rgba(52, 152, 219, 0.15)';"
                            onblur="this.style.borderColor='#e1e5eb'; this.style.boxShadow='none';">
                        </asp:TextBox>
                    </div>
                </div>

               
                <div class="form-field">
                    <asp:Label ID="lblRecipe" runat="server"
                        Text="Amount:"
                        style="display: block; font-weight: 600; color: #2c3e50; margin-bottom: 10px; font-size: 14px; letter-spacing: 0.3px;" />
                    <div style="position: relative;">
                        <div style="position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #3498db; z-index: 1;">
                            <i class="fas fa-dollar-sign"></i>
                        </div>
                        <asp:TextBox ID="txtamonut" runat="server"
                            placeholder="0.00"
                            style="width:100%; padding: 12px 15px 12px 45px; border: 2px solid #e1e5eb; border-radius: 8px; font-size: 15px; background-color: white; color: #333; transition: all 0.3s;"
                            onfocus="this.style.borderColor='#3498db'; this.style.boxShadow='0 0 0 3px rgba(52, 152, 219, 0.15)';"
                            onblur="this.style.borderColor='#e1e5eb'; this.style.boxShadow='none';">
                        </asp:TextBox>
                    </div>
                </div>

                
                <div class="form-field" style="display: flex; align-items: flex-end;">
                    <div style="position: relative; width: 100%;">
                        <asp:Button ID="btnSavePrices" runat="server"
                            Text="Save Service"
                            OnClick="btnSavePrices_Click"
                            style="background: linear-gradient(135deg, #2ecc71 0%, #27ae60 100%); color: white; border: none; padding: 0px 32px 14px 50px; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 12px rgba(46, 204, 113, 0.25); width: 100%;"
                            onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 16px rgba(46, 204, 113, 0.35)';"
                            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(46, 204, 113, 0.25)';">
                        </asp:Button>
                        <div style="position: absolute; left: 32px; top: 50%; transform: translateY(-50%); color: white; z-index: 1; pointer-events: none;">
                            <i class="fas fa-save"></i>
                        </div>
                    </div>
                </div>

            </div>
        </div>

       
        <div style="background: white; padding: 5px; border-radius: 12px; margin-bottom: 30px; box-shadow: 0 6px 20px rgba(0,0,0,0.08); border-left: 5px solid #2ecc71;">
            <div style="display: flex; align-items: center; margin-bottom: 7px; padding-bottom: 7px; border-bottom: 1px solid #eee;">
                <div style="background: #2ecc71; color: white; width: 42px; height: 42px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 15px; font-size: 18px;">
                    <i class="fas fa-list-alt"></i>
                </div>
                <h3 style="color: #2c3e50; font-size: 22px; font-weight: 600; margin: 0;">
                    Sports Services Overview
                </h3>
                <div style="margin-left: auto; background: #f0f9ff; padding: 6px 16px; border-radius: 20px; color: #3498db; font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 8px;">
                    <i class="fas fa-dumbbell"></i>
                    <span>All Services</span>
                </div>
            </div>
            
            <div style="overflow-x: auto; border-radius: 8px; border: 1px solid #e1e5eb;">
                <asp:GridView ID="gvRecipeMain" runat="server"
                    AutoGenerateColumns="False"
                    style="width: 100%; border-collapse: separate; border-spacing: 0; min-width: 900px;"
                    HeaderStyle-BackColor="#1a2980"
                    HeaderStyle-ForeColor="white"
                    HeaderStyle-Font-Bold="true"
                    RowStyle-BackColor="white"
                    AlternatingRowStyle-BackColor="#f8fafc"
                    CellPadding="12"
                    CellSpacing="0">
                    
                    <HeaderStyle 
                        BackColor="#1a2980" 
                        ForeColor="White" 
                        Font-Bold="true" 
                        Height="55px" 
                        Font-Size="15px"
                        CssClass="grid-header" />
                    
                    <RowStyle 
                        BackColor="white" 
                        Height="55px" 
                        CssClass="grid-row" />
                    
                    <AlternatingRowStyle 
                        BackColor="#f8fafc" 
                        CssClass="grid-alt-row" />
                    
                    <Columns>
                        <asp:TemplateField HeaderText="Sr#" HeaderStyle-Width="60px">
                            <ItemTemplate>
                                <div style="background: #f0f9ff; color: #3498db; width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 600; margin: 0 auto;">
                                    <%# Container.DataItemIndex + 1 %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:BoundField DataField="Dept_Name" HeaderText="Department" HeaderStyle-Width="250px">
                            <ItemStyle Font-Bold="true" Font-Size="15px" />
                        </asp:BoundField>
                        
                        <asp:BoundField DataField="ServiceName" HeaderText="Service Name" HeaderStyle-Width="300px">
                            <ItemStyle Font-Size="15px" />
                        </asp:BoundField>
                        
                        <asp:BoundField DataField="Amount" HeaderText="Amount" HeaderStyle-Width="150px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ItemStyle HorizontalAlign="Center" Font-Bold="true" Font-Size="16px" />
                        </asp:BoundField>
                        
                        <asp:TemplateField HeaderText="Actions" Visible="false" HeaderStyle-Width="150px">
                            <ItemTemplate>
                                <div style="display: flex; gap: 8px; justify-content: center;">
                                    <button type="button" class="action-btn edit-btn" style="background: #3498db; color: white; border: none; width: 36px; height: 36px; border-radius: 6px; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.transform='scale(1.1)';" onmouseout="this.style.transform='scale(1)';">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button type="button" class="action-btn delete-btn" style="background: #e74c3c; color: white; border: none; width: 36px; height: 36px; border-radius: 6px; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.transform='scale(1.1)';" onmouseout="this.style.transform='scale(1)';">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            
          
            <div style="display: none; justify-content: space-between; margin-top: 25px; padding-top: 10px; border-top: 1px solid #eee; flex-wrap: wrap; gap: 15px;">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <div style="background: #e8f4fc; color: #3498db; width: 40px; height: 40px; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-layer-group"></i>
                    </div>
                    <div>
                        <div style="font-size: 12px; color: #7f8c8d; font-weight: 600;">Total Services</div>
                        <div style="font-size: 20px; font-weight: 700; color: #2c3e50;">12</div>
                    </div>
                </div>
                
                <div style="display: flex; align-items: center; gap: 10px;">
                    <div style="background: #e8f6f3; color: #27ae60; width: 40px; height: 40px; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-dollar-sign"></i>
                    </div>
                    <div>
                        <div style="font-size: 12px; color: #7f8c8d; font-weight: 600;">Avg. Price</div>
                        <div style="font-size: 20px; font-weight: 700; color: #2c3e50;">$45.50</div>
                    </div>
                </div>
                
                <div style="display: flex; align-items: center; gap: 10px;">
                    <div style="background: #fef5e7; color: #f39c12; width: 40px; height: 40px; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-building"></i>
                    </div>
                    <div>
                        <div style="font-size: 12px; color: #7f8c8d; font-weight: 600;">Departments</div>
                        <div style="font-size: 20px; font-weight: 700; color: #2c3e50;">5</div>
                    </div>
                </div>
            </div>
        </div>
        
        
        <div style="display: none; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-top: 20px;">
            <div style="background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); display: flex; align-items: center; gap: 15px;">
                <div style="background: linear-gradient(135deg, #9b59b6 0%, #8e44ad 100%); color: white; width: 50px; height: 50px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 22px;">
                    <i class="fas fa-trophy"></i>
                </div>
                <div>
                    <div style="font-size: 14px; color: #7f8c8d;">Premium Services</div>
                    <div style="font-size: 22px; font-weight: 700; color: #2c3e50;">8 Available</div>
                </div>
            </div>
            
            <div style="background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); display: flex; align-items: center; gap: 15px;">
                <div style="background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%); color: white; width: 50px; height: 50px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 22px;">
                    <i class="fas fa-users"></i>
                </div>
                <div>
                    <div style="font-size: 14px; color: #7f8c8d;">Team Sports</div>
                    <div style="font-size: 22px; font-weight: 700; color: #2c3e50;">6 Categories</div>
                </div>
            </div>
        </div>

    </div>

   
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
   
    <style>
        .form-field {
            margin-bottom: 5px;
        }
        
        .grid-header th {
            padding: 16px 12px;
            text-align: left;
            border-bottom: 2px solid;
            position: relative;
            color:white
        }
        
        .grid-header th:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 0;
            height: 2px;
            background: #26d0ce;
            transition: width 0.3s;
        }
        
        .grid-header th:hover:after {
            width: 100%;
        }
        
        .grid-row td, .grid-alt-row td {
            padding: 16px 12px;
            border-bottom: 1px solid #eef2f7;
            transition: background-color 0.2s;
        }
        
        .grid-row:hover td {
            background-color: #f0f9ff !important;
        }
        
        .grid-alt-row:hover td {
            background-color: #e8f4fc !important;
        }
        
        .action-btn {
            transition: all 0.2s ease;
        }
        
        @media (max-width: 1200px) {
            .form-container {
                padding: 20px;
            }
        }
        
        @media (max-width: 768px) {
            .header-section h1 {
                font-size: 28px;
            }
            
            .form-field {
                min-width: 100%;
            }
        }
    </style>

</asp:Content>


