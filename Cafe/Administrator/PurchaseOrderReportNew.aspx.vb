Imports System.Data
Imports System.Data.SqlClient

Partial Class Store_Administrator_PurchaseOrderReportNew
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            loadReport()
        End If
    End Sub

    Dim constr As String = ConfigurationManager.ConnectionStrings("STOREConnectionString").ToString

    Protected Sub getsetTaxDiscount()
        Dim con As New SqlConnection(constr)
        con.Open()
        Dim qry As String = "SELECT PO_Tax_Discount.PO_ID, Tax_Discount_HeadDetail.Tax_Name, PO_Tax_Discount.Amount FROM PO_Tax_Discount INNER JOIN Tax_Discount_HeadDetail ON PO_Tax_Discount.Tax_ID = Tax_Discount_HeadDetail.Tax_Id WHERE (PO_Tax_Discount.PO_ID = @PO_ID)"
        Dim command As New SqlCommand(qry, con)
        command.Parameters.AddWithValue("@PO_ID", Request.QueryString("PO_ID"))
        Dim reader As SqlDataReader
        Try
            HiddenField_Tax.Value = 0
            HiddenField_Discount.Value = 0

            reader = command.ExecuteReader()
            While reader.Read
                If reader.Item("Tax_Name").ToString() = "Tax" Then
                    HiddenField_Tax.Value = reader.Item("Amount")

                ElseIf reader.Item("Tax_Name").ToString() = "Discount" Then
                    HiddenField_Discount.Value = reader.Item("Amount")

                End If
            End While

        Catch ex As Exception

        End Try

    End Sub

    Protected Sub loadReport()
        ' ReportViewer is disabled
    End Sub

    Public Sub subReports(sender As Object, e As Object)
        Try
            Dim dt As DataTable = DirectCast(Session("DynamicHeader"), DataTable)
        Catch generatedExceptionName As Exception
        End Try
    End Sub
End Class
