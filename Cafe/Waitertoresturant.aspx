<%@ Page Language="C#" AutoEventWireup="true"
    CodeFile="Waitertoresturant.aspx.cs"
    Inherits="Pos" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Waiter to Restaurant</title>
<!-- Add jQuery and jQuery UI for autocomplete -->
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<style>
    /* ----- base reset & gradient background ----- */
    body {
        margin: 0;
        padding: 0;
        font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
        background: linear-gradient(145deg, #0b2a4f 0%, #1b4a6b 100%);
        min-height: 100vh;
        display: flex;
        flex-direction: column;
    }

    /* Main heading at top */
    .main-heading {
        text-align: center;
        padding: 25px 0 15px 0;
        margin: 0;
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(10px);
        border-bottom: 1px solid rgba(255,255,255,0.2);
    }

    .main-heading h1 {
        font-size: 42px;
        font-weight: 700;
        margin: 0;
        background: linear-gradient(135deg, #ffffff, #e0e0ff);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        letter-spacing: 1px;
    }

    .main-heading p {
        color: rgba(255,255,255,0.8);
        margin: 8px 0 0 0;
        font-size: 16px;
        font-weight: 300;
    }

    /* main container: form CARD + GRID side by side */
    .dashboard {
        width: 1400px;  /* Increased width */
        max-width: 90vw;
        margin: 30px auto;
        display: flex;
        flex-direction: row;
        gap: 30px;  /* Increased gap */
        align-items: stretch;
        flex: 1;
    }

    /* left card — FORM */
    .card {
        flex: 1.2;  /* Increased flex */
        background: #ffffff;
        border-radius: 32px;  /* Larger radius */
        padding: 35px 35px;  /* Increased padding */
        box-shadow: 0 40px 60px rgba(0, 20, 40, 0.3);
        border: 1px solid rgba(255,255,255,0.3);
        height: fit-content;
        min-height: 500px;  /* Increased minimum height */
    }

    .card h2 {
        margin: 0 0 25px 0;
        font-size: 26px;
        font-weight: 600;
        color: #1e3a5f;
        border-bottom: 2px solid #eef2f6;
        padding-bottom: 15px;
    }

    /* form rows */
    .form-row {
        display: flex;
        flex-direction: column;
        gap: 22px;  /* Increased gap */
        margin-bottom: 20px;
    }

    .form-group {
        display: flex;
        flex-direction: column;
    }

    .form-group label {
        font-weight: 600;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #2b4f6e;
        margin-bottom: 8px;
    }

    .form-group input,
    .form-group select {
        width: 100%;
        padding: 14px 18px;  /* Increased padding */
        border-radius: 18px;  /* Larger radius */
        border: 1.5px solid #dde7f0;
        font-size: 15px;
        background: #f9fcff;
        transition: 0.2s;
        box-sizing: border-box;
        font-family: 'Inter', sans-serif;
    }

    .form-group input:focus,
    .form-group select:focus {
        border-color: #1f6fb0;
        box-shadow: 0 0 0 4px rgba(31,111,176,0.15);
        outline: none;
        background: #ffffff;
    }

    /* modern button */
    .btn-wrapper {
        margin-top: 35px;  /* Increased margin */
        text-align: left;
    }

    #btnAdd {
        padding: 16px 32px;  /* Increased padding */
        font-size: 17px;
        font-weight: 600;
        border-radius: 40px;
        border: none;
        cursor: pointer;
        background: linear-gradient(115deg, #0d417b, #1f6fb0);
        color: white;
        box-shadow: 0 15px 25px rgba(16, 70, 130, 0.4);
        transition: all 0.2s;
        letter-spacing: 0.3px;
        width: 100%;
        max-width: 250px;  /* Increased width */
    }

    #btnAdd:hover {
        background: linear-gradient(115deg, #0f4b8b, #2a7dc2);
        transform: translateY(-3px);
        box-shadow: 0 20px 30px rgba(16, 70, 130, 0.5);
    }

    /* right grid panel */
    .grid-panel {
        flex: 1.6;  /* Increased flex */
        background: #ffffff;
        border-radius: 32px;
        box-shadow: 0 40px 60px rgba(2, 30, 55, 0.25);
        overflow: hidden;
        display: flex;
        flex-direction: column;
        border: 1px solid rgba(255,255,255,0.4);
        height: 600px;  /* Fixed height */
        max-height: 70vh;  /* Responsive max height */
    }

    /* grid header */
    .grid-header {
        display: grid;
        grid-template-columns: 1.5fr 1.5fr 1.2fr 0.8fr;  /* Adjusted columns */
        background: linear-gradient(105deg, #1b4d6e, #2c6191);
        color: white;
        font-weight: 600;
        padding: 20px 25px;  /* Increased padding */
        font-size: 1rem;
        letter-spacing: 0.3px;
        text-transform: uppercase;
        border-bottom: 2px solid #cbdbe9;
    }

    /* scrollable body */
    .grid-body {
        overflow-y: auto;
        background: #fbfdff;
        flex: 1;
    }

    /* rows */
    .grid-row {
        display: grid;
        grid-template-columns: 1.5fr 1.5fr 1.2fr 0.8fr;  /* Match header */
        padding: 18px 25px;  /* Increased padding */
        border-bottom: 1px solid #e2ecf5;
        font-size: 1rem;
        color: #153e5a;
        background: white;
        transition: background 0.15s;
        align-items: center;
    }

    .grid-row:hover {
        background: #ecf5fc;
    }

    /* custom scroll */
    .grid-body::-webkit-scrollbar {
        width: 10px;  /* Wider scrollbar */
    }
    .grid-body::-webkit-scrollbar-track {
        background: #e3edf5;
    }
    .grid-body::-webkit-scrollbar-thumb {
        background: #2a7dc2;
        border-radius: 10px;
        border: 2px solid #e3edf5;
    }

    /* message label */
    .status-message {
        margin-top: 20px;
        padding: 15px 20px;
        border-radius: 50px;
        font-weight: 500;
        font-size: 1rem;
    }

    /* autocomplete styling */
    .ui-autocomplete {
        z-index: 9999 !important;
        border-radius: 14px;
        font-family: 'Inter', sans-serif;
        border: none;
        box-shadow: 0 15px 30px rgba(0,0,0,0.2);
        max-height: 250px;
        overflow-y: auto;
        font-size: 14px;
    }

    .ui-menu-item {
        padding: 10px 15px;
    }

    /* responsive */
    @media (max-width: 1000px) {
        .dashboard {
            flex-direction: column;
            width: 95%;
        }
        
        .main-heading h1 {
            font-size: 32px;
        }
    }
    
    /* alert styles */
    .top-alert {
        position: fixed;
        top: 30px;
        right: 30px;
        z-index: 10000;
        padding: 18px 30px;
        border-radius: 50px;
        font-weight: 500;
        font-size: 1rem;
        box-shadow: 0 15px 35px rgba(0,0,0,0.3);
        animation: slideIn 0.3s ease;
        max-width: 400px;
    }
    
    .top-alert-success {
        background: linear-gradient(135deg, #84fab0, #8fd3f4);
        color: #155724;
        border-left: 6px solid #28a745;
    }
    
    .top-alert-error {
        background: linear-gradient(135deg, #fbc2c2, #fda5a5);
        color: #721c24;
        border-left: 6px solid #dc3545;
    }
    
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }

    /* Stats/Summary section in card */
    .form-stats {
        background: linear-gradient(135deg, #f6f9fc, #edf2f7);
        border-radius: 20px;
        padding: 15px 20px;
        margin-bottom: 25px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border: 1px solid #dde7f0;
    }

    .stat-item {
        text-align: center;
    }

    .stat-value {
        font-size: 24px;
        font-weight: 700;
        color: #1e3a5f;
        line-height: 1.2;
    }

    .stat-label {
        font-size: 12px;
        color: #5f7d9c;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
</style>
</head>
<body>
    <!-- TOP HEADING -->
    <div class="main-heading">
        <h1>🍽️ Restaurant Employee Management</h1>
        <p>Assign waiters, cashiers, kitchen chiefs and managers to restaurants</p>
    </div>

    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

        <!-- side‑by‑side layout -->
        <div class="dashboard">

            <!-- LEFT: FORM block -->
            <div class="card">
                <h2>📋 New Assignment</h2>
                
                <!-- Optional stats section (you can remove if not needed) -->
                <div class="form-stats">
                    <div class="stat-item">
                        <div class="stat-value">8</div>
                        <div class="stat-label">Restaurants</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">24</div>
                        <div class="stat-label">Employees</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">12</div>
                        <div class="stat-label">Active</div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>🏬 Restaurant / Cafe</label>
                        <asp:DropDownList ID="ddlCafe" runat="server"></asp:DropDownList>
                    </div>

                    <div class="form-group">
                        <label>👤 Employee Name</label>
                        <asp:TextBox ID="txtEmployeeName" runat="server" placeholder="Type employee name..."></asp:TextBox>
                        <asp:HiddenField ID="hfEmployeeID" runat="server" />
                    </div>

                    <div class="form-group">
                        <label>📌 Role / Position</label>
                        <asp:DropDownList ID="ddlRole" runat="server">
                            <asp:ListItem Value="">-- Select Role --</asp:ListItem>
                            <%--<asp:ListItem>Waiter</asp:ListItem>--%>
                            <asp:ListItem>Cashier</asp:ListItem>
                            <asp:ListItem>Kitchen Chief</asp:ListItem>
                            <asp:ListItem>Manager</asp:ListItem>
                            <asp:ListItem>Waiter</asp:ListItem>
                            <%--<asp:ListItem>Bartender</asp:ListItem>--%>
                            <%--<asp:ListItem>Host/Hostess</asp:ListItem>--%>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="btn-wrapper">
                    <asp:Button ID="btnAdd" runat="server" Text="➕ Create Assignment" OnClick="btnAdd_Click" />
                </div>

                <!-- message label for alerts -->
                <asp:Label ID="lblMessage" runat="server" EnableViewState="false"></asp:Label>
            </div>

            <!-- RIGHT: GRID block -->
            <div class="grid-panel">
                <div class="grid-header">
                    <div>Restaurant</div>
                    <div>Employee</div>
                    <div>Role</div>
                    <div>Emp ID</div>
                </div>
                <div class="grid-body">
                    <asp:Repeater ID="rptEmployeeRestaurant" runat="server">
                        <ItemTemplate>
                            <div class="grid-row">
                                <div><%# Eval("RestaurantName") %></div>
                                <div><%# Eval("EmployeeName") %></div>
                                <div><%# Eval("Role") %></div>
                                <div><%# Eval("Emp_ID") %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </form>

    <script type="text/javascript">
        $(function () {
            var employeeTextBox = $("#<%= txtEmployeeName.ClientID %>");
            if (employeeTextBox.length > 0) {
                employeeTextBox.autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: '<%= ResolveUrl("Waitertoresturant.aspx/GetEmployeeList") %>',
                            data: JSON.stringify({ prefix: request.term }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (data) {
                                if (data.d) {
                                    response($.map(data.d, function (item) {
                                        return {
                                            label: item.label,
                                            value: item.label,
                                            id: item.id
                                        };
                                    }));
                                } else {
                                    response([]);
                                }
                            },
                            error: function (xhr, status, error) {
                                console.error("Autocomplete error:", error);
                                response([]);
                            }
                        });
                    },
                    minLength: 1,
                    select: function (event, ui) {
                        $("#<%= hfEmployeeID.ClientID %>").val(ui.item.id);
                    },
                    open: function () {
                        $(this).autocomplete("widget").css("z-index", 9999);
                    }
                });
                }
        });
    </script>
</body>
</html>