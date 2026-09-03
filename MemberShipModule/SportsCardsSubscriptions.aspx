<%@ Page Title="Sports Cards Subscriptions" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="SportsCardsSubscriptions.aspx.cs" Inherits="MemberShipModule.SportsCardsSubscriptions" %>

<asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
        .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
        .table th { background: #1A1A2E; color: #C9A84C; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e0d5c5; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
        .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; color: #1A1A2E; vertical-align: middle; }
        .table tr:last-child td { border-bottom: none; }
        .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; }
        .form-control:focus { border-color: #C9A84C; box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15); outline: none; }
        .form-control[readonly] { background-color: #F7F3EE; color: #7a7a7a; }

        .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.6rem 1.2rem; border-radius: 6px; font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; }
        .btn-primary { background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
        .btn-primary:hover { box-shadow: 0 8px 12px rgba(201, 168, 76, 0.3); transform: translateY(-1px); }
        .btn-secondary { background-color: white; color: #1A1A2E; border-color: #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
        .btn-secondary:hover { background-color: #F7F3EE; border-color: #e0d5c5; color: #1A1A2E; }
        .btn-success { background-color: #10b981; color: white; border-color: #10b981; }
        .btn-success:hover { background-color: #059669; }
        .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.875rem; }

        .form-group { margin-bottom: 1rem; }
        .form-group label { font-weight: 600; color: #1A1A2E; font-size: 0.875rem; display: block; margin-bottom: 0.25rem; }
        .grid-layout { display: grid; gap: 1rem; }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="page-wrapper mt-6" style="margin-top: 0.75rem;">
        <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);">

            <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem; padding-bottom: 1rem; border-bottom: 1px solid #e0d5c5;">
                <div>
                    <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">Sports Cards Subscriptions</h1>
                </div>
                <div style="display: flex; gap: 0.5rem;">
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn btn-secondary btn-sm" OnClick="btnSearchMember_Click" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary btn-sm" OnClick="btnClear_Click" />
                </div>
            </div>

            <!-- Top Filter Section -->
            <div style="background: #faf7f2; padding: 1rem; border-radius: 8px; border: 1px solid #e0d5c5; margin-bottom: 1.5rem;">
                <div class="grid-layout" style="grid-template-columns: 100px 200px 100px minmax(200px, 1fr);">
                    <div style="display: flex; align-items: center;">
                        <label style="font-weight: 600; font-size: 0.875rem; color: #1A1A2E;">Member No:</label>
                    </div>
                    <div style="display: flex; gap: 0.5rem;">
                        <asp:TextBox ID="txtMemberNoSearch" runat="server" CssClass="form-control" placeholder="P-10173"></asp:TextBox>
                        <asp:Button ID="btnSearchMember" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearchMember_Click" style="padding: 0.35rem 0.75rem;" />
                    </div>
                    <div></div>
                    <div>
                        <asp:TextBox ID="txtMemberNameHeader" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                </div>
                
                <div class="grid-layout" style="grid-template-columns: 100px 200px 100px minmax(200px, 1fr); margin-top: 1rem;">
                    <div style="display: flex; align-items: center;">
                        <label style="font-weight: 600; font-size: 0.875rem; color: #1A1A2E;">Sports:</label>
                    </div>
                    <div>
                        <asp:Label ID="lblSportsCard" runat="server" Text="SPORTS CARDS" style="font-size: 0.9rem; font-weight: 600; padding: 0.35rem 0; display: inline-block; margin-right: 1rem;"></asp:Label>
                        <asp:TextBox ID="txtSportsCode" runat="server" CssClass="form-control" Text="SPC" ReadOnly="true" style="display: inline-block; width: 60px;"></asp:TextBox>
                    </div>
                    <div style="display: flex; align-items: center; padding-left: 1rem;">
                        <label style="font-weight: 600; font-size: 0.875rem; color: #1A1A2E;">Subs. Type:</label>
                    </div>
                    <div style="display: flex; gap: 0.5rem; align-items: center;">
                        <asp:DropDownList ID="ddlSubsType" runat="server" CssClass="form-control" style="width: 150px;">
                            <asp:ListItem Value="Continuously">Continuously</asp:ListItem>
                        </asp:DropDownList>
                        <label style="font-weight: 600; font-size: 0.875rem; color: #1A1A2E; margin-left: 1rem;">Month:</label>
                        <asp:TextBox ID="txtSubMonth" runat="server" CssClass="form-control" style="width: 150px;" placeholder="Apr - 2026"></asp:TextBox>
                    </div>
                </div>
            </div>

            <!-- Search Results -->
            <div style="margin-bottom: 1.5rem;">
                <h3 style="font-size: 1rem; color: #1A1A2E; margin-bottom: 0.5rem;">Search Results - Total Record: <asp:Label ID="lblTotalRecords" runat="server" Text="0"></asp:Label></h3>
                <div class="table-container" style="overflow-x: auto;">
                    <asp:GridView ID="gvSearchResults" runat="server" AutoGenerateColumns="False" Width="100%" CssClass="table" GridLines="None"
                        DataKeyNames="MemberNo" OnSelectedIndexChanged="gvSearchResults_SelectedIndexChanged">
                        <SelectedRowStyle BackColor="#f5ecd5" ForeColor="#1e40af" Font-Bold="True" />
                        <HeaderStyle BackColor="#faf7f2" ForeColor="#1A1A2E" Font-Bold="True" />
                        <Columns>
                            <asp:ButtonField ButtonType="Link" CommandName="Select" Text="Select" HeaderText="" />
                            <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                            <asp:BoundField DataField="Name" HeaderText="Name" />
                            <asp:BoundField DataField="Status" HeaderText="Status" />
                            <asp:BoundField DataField="Relation" HeaderText="Relation" />
                            <asp:BoundField DataField="Age" HeaderText="Age" />
                            <asp:BoundField DataField="CardNo" HeaderText="Card No" />
                            <asp:BoundField DataField="EffectiveDate" HeaderText="Effective Date" />
                            <asp:BoundField DataField="DiscontinueDate" HeaderText="Discontinue Date" />
                            <asp:BoundField DataField="ChargeType" HeaderText="Charge Type" />
                            <asp:TemplateField HeaderText="Charge">
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkCharge" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Amount" HeaderText="Amount" />
                            <asp:BoundField DataField="Type" HeaderText="Type" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <!-- Subscription Details Form -->
            <div style="background: #faf7f2; padding: 1.5rem; border-radius: 8px; border: 1px solid #e0d5c5; margin-bottom: 1.5rem;">
                <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 1rem; margin-bottom: 1rem;">
                    <div>
                        <label style="font-size: 0.875rem; font-weight: 600; color: #1A1A2E;">Member No:</label>
                        <asp:TextBox ID="txtDetailMemberNo" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                    <div>
                        <label style="font-size: 0.875rem; font-weight: 600; color: #1A1A2E;">&nbsp;</label>
                        <asp:TextBox ID="txtDetailName" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr 2fr; gap: 1rem; margin-bottom: 1rem;">
                    <div>
                        <label style="font-size: 0.875rem; font-weight: 600; color: #1A1A2E;">Relation:</label>
                        <asp:TextBox ID="txtDetailRelation" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                    <div>
                        <label style="font-size: 0.875rem; font-weight: 600; color: #1A1A2E;">Age:</label>
                        <asp:TextBox ID="txtDetailAge" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                    <div></div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 1rem; margin-bottom: 1rem;">
                    <div>
                        <label style="font-size: 0.875rem; font-weight: 600; color: #1A1A2E;">Status:</label>
                        <asp:TextBox ID="txtDetailStatus" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                    <div>
                        <label style="font-size: 0.875rem; font-weight: 600; color: #1A1A2E;">Charge Type:</label>
                        <asp:DropDownList ID="ddlDetailChargeType" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Individual Sports Card">Individual Sports Card</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 1rem; margin-bottom: 1rem;">
                    <div>
                        <label style="font-size: 0.875rem; font-weight: 600; color: #1A1A2E;">Card No:</label>
                        <asp:TextBox ID="txtDetailCardNo" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                    <div></div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr 1.5fr auto auto; gap: 1rem; align-items: end; margin-bottom: 1rem;">
                    <div>
                        <label style="font-size: 0.875rem; font-weight: 600; color: #1A1A2E;">Subscription:</label>
                        <asp:TextBox ID="txtDetailSubscriptionAmount" runat="server" CssClass="form-control" Text="0.00"></asp:TextBox>
                    </div>
                    <div>
                        <label style="font-size: 0.875rem; font-weight: 600; color: #1A1A2E;">Charge:</label>
                        <asp:DropDownList ID="ddlDetailCharge" runat="server" CssClass="form-control">
                            <asp:ListItem Value="YES">YES</asp:ListItem>
                            <asp:ListItem Value="NO">NO</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label style="font-size: 0.875rem; font-weight: 600; color: #1A1A2E;">Effective Date:</label>
                        <asp:TextBox ID="txtDetailEffectiveDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    </div>
                    <div>
                        <asp:Button ID="btnSaveSubscription" runat="server" Text="Save Subscription" CssClass="btn btn-primary" OnClick="btnSaveSubscription_Click" />
                    </div>
                    <div>
                        <asp:Button ID="btnPayByCard" runat="server" Text="Pay By CCard" CssClass="btn btn-secondary" />
                    </div>
                </div>
            </div>

            <!-- History -->
            <div>
                <h3 style="font-size: 1rem; color: #1A1A2E; margin-bottom: 0.5rem;">History</h3>
                <div class="table-container" style="overflow-x: auto; max-height: 300px;">
                    <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False" Width="100%" CssClass="table" GridLines="None">
                        <HeaderStyle BackColor="#1e293b" ForeColor="#faf7f2" Font-Bold="True" />
                        <RowStyle BackColor="White" ForeColor="#1A1A2E" BorderColor="#e0d5c5" BorderStyle="Solid" BorderWidth="1px" />
                        <Columns>
                            <asp:BoundField DataField="TrDate" HeaderText="Tr Date" />
                            <asp:BoundField DataField="TrNo" HeaderText="Tr No" />
                            <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                            <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                            <asp:BoundField DataField="CreditCardNo" HeaderText="Credit Card No" />
                            <asp:BoundField DataField="CardName" HeaderText="Card Name" />
                            <asp:BoundField DataField="CardScheme" HeaderText="Card Scheme" />
                            <asp:BoundField DataField="Department" HeaderText="Department" />
                            <asp:BoundField DataField="ChargeType" HeaderText="Charge Type" />
                            <asp:BoundField DataField="Charge" HeaderText="Charge" />
                            <asp:BoundField DataField="PaymentUpto" HeaderText="Payment Upto" />
                            <asp:BoundField DataField="Amt" HeaderText="Amt" />
                            <asp:BoundField DataField="Month" HeaderText="Month" />
                            <asp:BoundField DataField="TotalAmt" HeaderText="Total Amt" />
                            <asp:BoundField DataField="Discount" HeaderText="Discount" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

        </div>
    </div>
</asp:Content>
