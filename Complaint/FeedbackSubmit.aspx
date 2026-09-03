<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FeedbackSubmit.aspx.cs" Inherits="GymkhanaLibrary.Pages_FeedbackSubmit" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Lahore Gymkhana Club - Member Feedback</title>
    
    <!-- Premium Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400&display=swap" rel="stylesheet">

    <style>
        /* Responsive focus and hover styles that cannot be done inline */
        .form-control:focus {
            background-color: #ffffff !important;
            border-color: #c5a059 !important;
            box-shadow: 0 0 0 3px rgba(197, 160, 89, 0.15) !important;
        }
        
        .stars-container label:hover,
        .stars-container label:hover ~ label,
        .stars-container input:checked ~ label {
            color: #fbbf24 !important;
        }

        .btn-gold:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(197, 160, 89, 0.4) !important;
        }

        .alert-success {
            background-color: #ecfdf5 !important;
            color: #065f46 !important;
            border-color: #a7f3d0 !important;
        }
        .alert-error {
            background-color: #fef2f2 !important;
            color: #991b1b !important;
            border-color: #fca5a5 !important;
        }

        .switch input:checked + .slider,
        .switch input:checked ~ .slider,
        .switch span input:checked ~ .slider {
            background-color: #dc2626 !important; /* Red for complaint */
        }
        .switch input:checked + .slider .slider-circle,
        .switch input:checked ~ .slider .slider-circle,
        .switch span input:checked ~ .slider .slider-circle {
            transform: translateX(24px) !important;
        }

        .option-pill:hover {
            border-color: #c5a059 !important;
            background-color: #fffbeb !important;
        }
        .option-pill input:checked + span,
        .option-pill:has(input:checked) {
            border-color: #c5a059 !important;
            background-color: #fef3c7 !important;
            color: #92400e !important;
            font-weight: 700 !important;
        }

        /* Responsive Mobile Layout Adjustments */
        @media (max-width: 480px) {
            .feedback-card {
                padding: 24px 16px !important;
                border-radius: 12px !important;
            }
            .stars-container label {
                font-size: 32px !important;
                gap: 8px !important;
            }
            h2 {
                font-size: 22px !important;
            }
        }

        @media (max-width: 380px) {
            .feedback-card {
                padding: 20px 12px !important;
            }
            .stars-container label {
                font-size: 28px !important;
                gap: 6px !important;
            }
            h2 {
                font-size: 19px !important;
            }
            .subtitle {
                font-size: 11px !important;
                letter-spacing: 1px !important;
            }
        }
    </style>
</head>
<body style="font-family: 'Outfit', sans-serif; background-color: #f8fafc; color: #1e293b; margin: 0; padding: 0; min-height: 100vh; display: flex; align-items: center; justify-content: center; -webkit-font-smoothing: antialiased; box-sizing: border-box;">
    <form id="form1" runat="server" style="width: 100%; display: flex; justify-content: center; box-sizing: border-box;">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div class="container" style="width: 100%; max-width: 480px; padding: 16px; box-sizing: border-box; margin: 0 auto; display: flex; align-items: center; justify-content: center;">
            <div class="feedback-card" style="background: #ffffff; border-radius: 16px; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.08), 0 8px 10px -6px rgba(0,0,0,0.03); border: 1px solid #e2e8f0; padding: 32px 24px; text-align: center; width: 100%; box-sizing: border-box;">
                
                <img src='<%= ResolveUrl("Images/logo_new.png") %>' alt="Lahore Gymkhana Logo" style="height: 65px; width: auto; object-fit: contain; margin: 0 auto 16px auto; display: block;" />
                
                <asp:Panel ID="pnlForm" runat="server" style="width: 100%; box-sizing: border-box;">
                    <h2 style="font-family: 'Playfair Display', serif; font-size: 24px; font-weight: 700; color: #0f1e36; margin: 0 0 8px 0; line-height: 1.2;"><asp:Literal ID="litDeptName" runat="server" Text="Lahore Gymkhana" /></h2>
                    <div class="subtitle" style="font-size: 13px; color: #c5a059; text-transform: uppercase; letter-spacing: 1.5px; font-weight: 700; margin-bottom: 20px;"><asp:Literal ID="litFeedbackTitle" runat="server" Text="Feedback & Service Review" /></div>
                    
                    <!-- Alert Panel -->
                    <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%; box-sizing: border-box;">
                        <div class='alert-box <%= AlertCssClass %>' style="padding: 12px 16px; border-radius: 8px; font-size: 14px; margin-bottom: 20px; text-align: left; border: 1px solid transparent; box-sizing: border-box;">
                            <span><%= AlertMessage %></span>
                        </div>
                    </asp:Panel>

                    <asp:Literal ID="litInstructions" runat="server" />

                    <!-- Information Section Notice -->
                    <div style="font-size: 12.5px; color: #374151; margin-bottom: 20px; text-align: left; background-color: #fffbeb; border-left: 4px solid #f59e0b; padding: 10px 14px; border-radius: 6px; box-sizing: border-box; line-height: 1.4;">
                        At least one information field below (<strong>Membership Number</strong>, <strong>Member Name</strong>, <strong>Email</strong>, or <strong>Phone Number</strong>) is required to submit.
                    </div>

                    <!-- Form Inputs -->
                    <div class="form-group" style="margin-bottom: 20px; text-align: left; width: 100%; box-sizing: border-box;">
                        <label class="form-label" style="font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Membership Number</label>
                        <asp:TextBox ID="txtMemberNo" runat="server" CssClass="form-control" placeholder="e.g. 10452" style="width: 100%; padding: 12px 16px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 15px; color: #1e293b; outline: none; transition: all 0.2s ease; box-sizing: border-box;" />
                    </div>

                    <!-- Member Name -->
                    <div class="form-group" style="margin-bottom: 20px; text-align: left; width: 100%; box-sizing: border-box;">
                        <label class="form-label" style="font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Member Name</label>
                        <asp:TextBox ID="txtMemberName" runat="server" CssClass="form-control" placeholder="Your full name..." style="width: 100%; padding: 12px 16px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 15px; color: #1e293b; outline: none; transition: all 0.2s ease; box-sizing: border-box;" />
                    </div>

                    <!-- Email Address -->
                    <div class="form-group" style="margin-bottom: 20px; text-align: left; width: 100%; box-sizing: border-box;">
                        <label class="form-label" style="font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="e.g. name@domain.com" style="width: 100%; padding: 12px 16px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 15px; color: #1e293b; outline: none; transition: all 0.2s ease; box-sizing: border-box;" />
                    </div>

                    <!-- Phone Number -->
                    <div class="form-group" style="margin-bottom: 20px; text-align: left; width: 100%; box-sizing: border-box;">
                        <label class="form-label" style="font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Phone Number</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="e.g. +92 300 1234567" style="width: 100%; padding: 12px 16px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 15px; color: #1e293b; outline: none; transition: all 0.2s ease; box-sizing: border-box;" />
                    </div>

                    <!-- Dual Form Toggle: Feedback vs Formal Complaint -->
                    <div class="toggle-container" style="display: none; align-items: center; justify-content: space-between; background-color: #f8fafc; padding: 12px 16px; border-radius: 8px; border: 1px solid #e2e8f0; margin-bottom: 20px; width: 100%; box-sizing: border-box;">
                        <span class="toggle-text" style="font-size: 14px; font-weight: 600; color: #475569;">Submit as formal Complaint?</span>
                       <label class="switch" style="position: relative; display: inline-block; width: 48px; height: 24px; flex-shrink: 0; cursor: not-allowed;">
    <asp:CheckBox ID="chkIsComplaint" runat="server" Checked="true" Enabled="false" AutoPostBack="true" OnCheckedChanged="chkIsComplaint_CheckedChanged" style="opacity: 0; width: 0; height: 0; position: absolute;" />                            <span class="slider" style="position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: <%= chkIsComplaint.Checked ? "#dc2626" : "#cbd5e1" %>; transition: .3s; border-radius: 24px;">
                                <span class="slider-circle" style="position: absolute; height: 18px; width: 18px; left: 3px; bottom: 3px; background-color: white; transition: .3s; border-radius: 50%; <%= chkIsComplaint.Checked ? "transform: translateX(24px);" : "" %>"></span>
                            </span>
                        </label>
                    </div>

                    <!-- Dynamic Multiple Questions Rating Panel (Only visible for Feedback) -->
                    <asp:Panel ID="pnlRating" runat="server" style="width: 100%; box-sizing: border-box;">
                        <asp:Repeater ID="repQuestions" runat="server" OnItemDataBound="repQuestions_ItemDataBound">
                            <ItemTemplate>
                                <div style="margin-bottom: 24px; border-bottom: 1px solid #f1f5f9; padding-bottom: 16px; text-align: left; width: 100%; box-sizing: border-box;">
                                    <label class="form-label" style="font-weight: 600; font-size: 15px; color: #0f1e36; margin-bottom: 8px; display: block; line-height: 1.4;">
                                        <%# Eval("QuestionText") %>
                                    </label>
                                    <input type="hidden" name="question_id" value='<%# Eval("QuestionID") %>' />
                                    <input type="hidden" name='<%# "qtype_" + Eval("QuestionID") %>' value='<%# Eval("QuestionType") != DBNull.Value ? Eval("QuestionType") : "Rating" %>' />

                                    <!-- Type 1: Rating (Stars) -->
                                    <asp:PlaceHolder ID="phRating" runat="server" Visible='<%# Convert.ToString(Eval("QuestionType")) == "Rating" || string.IsNullOrEmpty(Convert.ToString(Eval("QuestionType"))) %>'>
                                        <div class="stars-container" style="display: flex; justify-content: flex-start; gap: 12px; margin: 10px 0; direction: rtl; width: 100%;">
                                            <input type="radio" id='<%# "star5_" + Eval("QuestionID") %>' name='<%# "rating_" + Eval("QuestionID") %>' value="5" style="display: none;" />
                                            <label for='<%# "star5_" + Eval("QuestionID") %>' title="5 stars" style="font-size: 36px; color: #cbd5e1; cursor: pointer; transition: color 0.15s ease;">&#9733;</label>
                                            
                                            <input type="radio" id='<%# "star4_" + Eval("QuestionID") %>' name='<%# "rating_" + Eval("QuestionID") %>' value="4" style="display: none;" />
                                            <label for='<%# "star4_" + Eval("QuestionID") %>' title="4 stars" style="font-size: 36px; color: #cbd5e1; cursor: pointer; transition: color 0.15s ease;">&#9733;</label>
                                            
                                            <input type="radio" id='<%# "star3_" + Eval("QuestionID") %>' name='<%# "rating_" + Eval("QuestionID") %>' value="3" style="display: none;" />
                                            <label for='<%# "star3_" + Eval("QuestionID") %>' title="3 stars" style="font-size: 36px; color: #cbd5e1; cursor: pointer; transition: color 0.15s ease;">&#9733;</label>
                                            
                                            <input type="radio" id='<%# "star2_" + Eval("QuestionID") %>' name='<%# "rating_" + Eval("QuestionID") %>' value="2" style="display: none;" />
                                            <label for='<%# "star2_" + Eval("QuestionID") %>' title="2 stars" style="font-size: 36px; color: #cbd5e1; cursor: pointer; transition: color 0.15s ease;">&#9733;</label>
                                            
                                            <input type="radio" id='<%# "star1_" + Eval("QuestionID") %>' name='<%# "rating_" + Eval("QuestionID") %>' value="1" style="display: none;" />
                                            <label for='<%# "star1_" + Eval("QuestionID") %>' title="1 star" style="font-size: 36px; color: #cbd5e1; cursor: pointer; transition: color 0.15s ease;">&#9733;</label>
                                        </div>
                                    </asp:PlaceHolder>

                                    <!-- Type 2: Multiple Choice / True-False / Yes-No Radio Option Pills -->
                                    <asp:PlaceHolder ID="phOptions" runat="server" Visible='<%# Convert.ToString(Eval("QuestionType")) != "Rating" && !string.IsNullOrEmpty(Convert.ToString(Eval("QuestionType"))) %>'>
                                        <div class="options-container" style="display: flex; flex-wrap: wrap; gap: 10px; margin: 10px 0; width: 100%;">
                                            <asp:Repeater ID="repOptionItems" runat="server">
                                                <ItemTemplate>
                                                    <label class="option-pill" style="display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; background-color: #f8fafc; border: 1.5px solid #cbd5e1; border-radius: 24px; font-size: 14px; font-weight: 500; color: #334155; cursor: pointer; transition: all 0.2s ease;">
                                                        <input type="radio" name='<%# "answer_" + DataBinder.Eval(Container.NamingContainer.NamingContainer, "DataItem.QuestionID") %>' value='<%# Container.DataItem %>' style="accent-color: #c5a059; width: 16px; height: 16px;" />
                                                        <span><%# Container.DataItem %></span>
                                                    </label>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </div>
                                    </asp:PlaceHolder>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </asp:Panel>

                    <!-- Complaint Subject (Only visible for Complaints) -->
                    <asp:Panel ID="pnlSubject" runat="server" Visible="false" CssClass="form-group" style="margin-bottom: 20px; text-align: left; width: 100%; box-sizing: border-box;">
                        <label class="form-label" style="font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Complaint Subject *</label>
                        <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" placeholder="Briefly describe the issue..." style="width: 100%; padding: 12px 16px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 15px; color: #1e293b; outline: none; transition: all 0.2s ease; box-sizing: border-box;" />
                    </asp:Panel>

                    <div class="form-group" style="margin-bottom: 20px; text-align: left; width: 100%; box-sizing: border-box;">
                        <label class="form-label" style="font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">
                            <asp:Literal ID="litCommentsLabel" runat="server" Text="General Comments & Suggestions" />
                        </label>
                        <asp:TextBox ID="txtComments" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Please provide detailed feedback..." style="width: 100%; padding: 12px 16px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 15px; color: #1e293b; outline: none; transition: all 0.2s ease; box-sizing: border-box; resize: vertical;" />
                    </div>

                    <asp:Button ID="btnSubmit" runat="server" Text="Submit Feedback" CssClass="btn-gold" OnClick="btnSubmit_Click" OnClientClick="return disableSubmitButton(this);" style="width: 100%; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; border: none; padding: 14px; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.2s ease; box-shadow: 0 4px 12px rgba(197, 160, 89, 0.3); margin-top: 10px; box-sizing: border-box;" />
                </asp:Panel>

                <script type="text/javascript">
                    function disableSubmitButton(btn) {
                        if (btn.getAttribute('data-submitting') === 'true') {
                            return false;
                        }
                        btn.setAttribute('data-submitting', 'true');
                        setTimeout(function () {
                            btn.disabled = true;
                            btn.value = 'Submitting... Please wait';
                            btn.style.opacity = '0.75';
                            btn.style.cursor = 'not-allowed';
                        }, 0);
                        return true;
                    }
                </script>

                <!-- Success State Panel -->
                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="success-state" style="padding: 20px 0; width: 100%; box-sizing: border-box;">
                    <h2 style="font-family: 'Playfair Display', serif; font-size: 24px; font-weight: 700; color: #0f1e36; margin: 0 0 8px 0; line-height: 1.2;">Thank You!</h2>
                    <p style="color: #64748b; font-size: 15px; margin-top: 10px; margin-bottom: 24px; line-height: 1.6; text-align: center;">
                        <asp:Literal ID="litSuccessMessage" runat="server" Text="Your feedback has been logged successfully. We appreciate your inputs to make Lahore Gymkhana better." />
                    </p>
                    <button type="button" class="btn-gold" onclick="closeWindowTab();" style="width: 100%; max-width: 200px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; border: none; padding: 14px; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.2s ease; box-shadow: 0 4px 12px rgba(197, 160, 89, 0.3); box-sizing: border-box; margin: 0 auto;">Close Window</button>
                    
                    <script type="text/javascript">
                        function closeWindowTab() {
                            try {
                                window.opener = null;
                                window.open('', '_self', '');
                                window.close();
                            } catch (e) { }

                            try {
                                window.close();
                            } catch (e) { }

                            try {
                                self.close();
                            } catch (e) { }

                            setTimeout(function () {
                                try {
                                    window.location.replace("about:blank");
                                } catch (e) {
                                    window.location.href = "about:blank";
                                }
                            }, 250);
                        }
                    </script>
                </asp:Panel>

            </div>
        </div>
    </form>
</body>
</html>
