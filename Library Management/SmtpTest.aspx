<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Net.Mail" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Net.Sockets" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>SMTP Diagnostic – Lahore Gymkhana</title>
    <style>
        body { font-family: Consolas, monospace; background: #0f1e36; color: #e2e8f0; padding: 32px; }
        h2   { color: #c5a059; }
        .box { background: #1c3254; border: 1px solid #2d4a7a; border-radius: 8px; padding: 20px; margin: 16px 0; }
        .ok  { color: #34d399; font-weight: bold; }
        .err { color: #f87171; font-weight: bold; }
        .inf { color: #94a3b8; }
        .warn { color: #f59e0b; }
        input[type=text], input[type=email] {
            background: #0f1e36; border: 1px solid #2d4a7a; color: #e2e8f0;
            padding: 8px 12px; border-radius: 6px; width: 400px; font-family: inherit;
        }
        input[type=submit] {
            background: #c5a059; color: #0f1e36; border: none; padding: 10px 24px;
            border-radius: 6px; font-weight: bold; cursor: pointer; margin-top: 12px;
        }
        pre { white-space: pre-wrap; word-break: break-all; margin: 0; font-size: 12px; }
        .success-box { background: #064e3b; border: 1px solid #34d399; }
        .error-box { background: #7f1d1d; border: 1px solid #f87171; }
        .warn-box { background: #78350f; border: 1px solid #f59e0b; }
        .test-result { margin: 4px 0; padding: 4px 8px; border-radius: 4px; }
        .test-pass { color: #34d399; }
        .test-fail { color: #f87171; }
        .test-warn { color: #f59e0b; }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        td { padding: 6px 12px; border-bottom: 1px solid #2d4a7a; }
        .label { color: #94a3b8; width: 180px; }
        .value { color: #e2e8f0; }
    </style>
</head>
<body>
    <h2>&#9993; SMTP Diagnostic Tool – Lahore Gymkhana Library</h2>
    <p class="inf">This tool will diagnose network connectivity, DNS, and SMTP issues.</p>

    <form runat="server">
        <div class="box">
            <b>Test Configuration:</b><br/><br/>
            <table>
                <tr><td class="label">SMTP Host:</td><td class="value">mail.lahoregymkhana.org.pk</td></tr>
                <tr><td class="label">Username:</td><td class="value">complaint@lahoregymkhana.org.pk</td></tr>
                <tr><td class="label">Test Email To:</td><td class="value"><input type="email" id="txtTo" runat="server" placeholder="your@email.com" style="width:300px;" /></td></tr>
            </table>
            <br/>
            <input type="submit" value="Run Full Diagnostic" runat="server" onserverclick="RunTests" style="background:#c5a059; color:#0f1e36; border:none; padding:10px 32px; border-radius:6px; font-weight:bold; cursor:pointer;" />
        </div>
        <asp:Literal ID="litResults" runat="server" />
    </form>

<script runat="server">

    const string SmtpHost = "mail.lahoregymkhana.org.pk";
    const string SmtpUser = "complaint@lahoregymkhana.org.pk";
    const string SmtpPass = "LhrGymkhana";

    void RunTests(object sender, EventArgs e)
    {
        string toAddr = txtTo.Value.Trim();

        if (string.IsNullOrEmpty(toAddr))
        {
            litResults.Text = "<div class='box error-box'>Please enter recipient email.</div>";
            return;
        }

        StringBuilder sb = new StringBuilder();

        sb.Append("<div class='box'><b>DIAGNOSTIC REPORT</b></div>");

        // DNS Test
        sb.Append("<div class='box'><b>TEST 1: DNS Resolution</b><br/>");

        try
        {
            var ips = Dns.GetHostAddresses(SmtpHost);

            sb.Append("<span class='ok'>✓ SUCCESS - Resolved to: ");

            foreach (var ip in ips)
            {
                sb.Append(ip.ToString() + " ");
            }

            sb.Append("</span>");
        }
        catch (Exception ex)
        {
            sb.Append("<span class='err'>✗ FAILED: " +
                      Server.HtmlEncode(ex.Message) +
                      "</span>");
        }

        sb.Append("</div>");

        // Port Test
        sb.Append("<div class='box'><b>TEST 2: Port Connectivity</b><br/>");

        int[] ports = { 25, 465, 587 };

        foreach (int port in ports)
        {
            if (TestPort(SmtpHost, port))
            {
                sb.Append("<div class='test-pass'>✓ Port "
                          + port +
                          " is OPEN</div>");
            }
            else
            {
                sb.Append("<div class='test-fail'>✗ Port "
                          + port +
                          " is CLOSED</div>");
            }
        }

        sb.Append("</div>");

        // Email Test
        sb.Append("<div class='box'><b>TEST 3: Send Test Email</b><br/>");

        string result = SendTestEmail(toAddr);

        if (result == "OK")
        {
            sb.Append("<div class='test-pass'>✓ Email sent successfully.</div>");
        }
        else
        {
            sb.Append("<div class='test-fail'>✗ Email sending failed:</div>");
            sb.Append("<pre>");
            sb.Append(Server.HtmlEncode(result));
            sb.Append("</pre>");
        }

        sb.Append("</div>");

        litResults.Text = sb.ToString();
    }

    bool TestPort(string host, int port)
    {
        try
        {
            using (TcpClient client = new TcpClient())
            {
                IAsyncResult result = client.BeginConnect(host, port, null, null);

                bool success =
                    result.AsyncWaitHandle.WaitOne(
                        TimeSpan.FromSeconds(5));

                if (!success)
                    return false;

                client.EndConnect(result);

                return true;
            }
        }
        catch
        {
            return false;
        }
    }
    string SendTestEmail(string toAddr)
    {
        try
        {
            // Add this here
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            MailMessage mail = new MailMessage();

            mail.From = new MailAddress(
                "complaint@lahoregymkhana.org.pk",
                "Lahore Gymkhana Library");

            mail.To.Add(toAddr);

            mail.Subject = "SMTP Test";

            mail.Body = "This is a test email.";

            mail.IsBodyHtml = true;

            SmtpClient smtp = new SmtpClient();

            smtp.Host = "mail.lahoregymkhana.org.pk";
            smtp.Port = 587;
            smtp.EnableSsl = true;

            smtp.UseDefaultCredentials = false;

            smtp.Credentials = new NetworkCredential(
                "complaint@lahoregymkhana.org.pk",
                "LhrGymkhana");

            smtp.Timeout = 60000;

            smtp.Send(mail);

            return "OK";
        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }

    //private string SendTestEmail(string toAddr)
    //{
    //    try
    //    {
    //        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

    //        MailMessage mail = new MailMessage();

    //        mail.From = new MailAddress(
    //            "complaint@lahoregymkhana.org.pk",
    //            "Lahore Gymkhana");

    //        mail.To.Add(toAddr);

    //        mail.Subject = "SMTP Test";

    //        mail.Body =
    //            "This is a test email from Lahore Gymkhana.";

    //        mail.IsBodyHtml = true;

    //        SmtpClient smtp = new SmtpClient();

    //        smtp.Host = "mail.lahoregymkhana.org.pk";
    //        smtp.Port = 465;
    //        smtp.EnableSsl = true;

    //        smtp.UseDefaultCredentials = false;

    //        smtp.Credentials =
    //            new NetworkCredential(
    //                "complaint@lahoregymkhana.org.pk",
    //                "LhrGymkahna");

    //        smtp.DeliveryMethod =
    //            SmtpDeliveryMethod.Network;

    //        smtp.Timeout = 120000;

    //        smtp.Send(mail);

    //        return "OK";
    //    }
    //    catch (Exception ex)
    //    {
    //        return ex.ToString();
    //    }
    //}
    private static void SetClientDomain(
    SmtpClient smtp,
    string domain)
    {
        try
        {
            string[] fieldNames =
        {
            "clientDomain",
            "_clientDomain",
            "localHostName",
            "_localHostName",
            "hostName",
            "_hostName"
        };

            foreach (string fieldName in fieldNames)
            {
                var field =
                    typeof(SmtpClient).GetField(
                        fieldName,
                        System.Reflection.BindingFlags.Instance |
                        System.Reflection.BindingFlags.NonPublic |
                        System.Reflection.BindingFlags.IgnoreCase);

                if (field != null)
                {
                    field.SetValue(smtp, domain);
                    return;
                }
            }
        }
        catch
        {
        }
    }

    private void SetHeloName(SmtpClient smtp)
    {
        try
        {
            var field =
                typeof(SmtpClient).GetField(
                    "clientDomain",
                    System.Reflection.BindingFlags.Instance |
                    System.Reflection.BindingFlags.NonPublic);

            if (field != null)
            {
                field.SetValue(
                    smtp,
                    "mail.lahoregymkhana.org.pk");
            }
        }
        catch
        {
        }
    }

</script>
</body>
</html>