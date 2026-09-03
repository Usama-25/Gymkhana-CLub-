<%@ Page Title="Upload Menu Item Image" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="UploadImagePerItem.aspx.cs" Inherits="Pos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script>
        
        function previewImage(input, previewId) {
            var file = input.files[0];
            var reader = new FileReader();
            reader.onload = function (e) {
                var img = document.getElementById(previewId);
                img.src = e.target.result;
                img.style.display = 'block';
            };
            if (file) {
                reader.readAsDataURL(file);
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    
 <div style="margin:50px auto;background:#ffffff;border-radius:12px;box-shadow:0 8px 25px rgba(0,0,0,0.1);font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
    <h3 style="text-align:center;margin-bottom:25px;color:#fff;background-color:#28a745;padding:12px 0;border-radius:12px 12px 0 0;">
        &#128247; Assign Image to Menu Item
    </h3>
</div>



    <!-- Fields in one row -->
    <div style="display:flex;gap:10px;align-items:flex-start;margin-bottom:20px;flex-wrap:wrap;">
        <!-- Menu Item Dropdown -->
        <div style="flex:1;min-width:150px;">
            <asp:Label runat="server" Text="Menu Item" style="display:block;margin-bottom:6px;font-weight:600;color:#555;"></asp:Label>
            <asp:DropDownList ID="ddlMenuItems" runat="server"
                AutoPostBack="true" OnSelectedIndexChanged="ddlMenuItems_SelectedIndexChanged"
                style="width:100%;border:1px solid #007bff;border-radius:6px;font-size:14px;background-color:#fff;color:#333;" >
            </asp:DropDownList>
        </div>

        <!-- Image Path -->
        <div style="flex:1;min-width:150px;">
            <asp:Label runat="server" Text="Image Path (Optional)" style="display:block;margin-bottom:6px;font-weight:600;color:#555;"></asp:Label>
            <asp:TextBox ID="txtImagePath" runat="server"
                style="width:100%;border:1px solid #ccc;border-radius:6px;font-size:14px;background-color:#f9f9f9;" />
        </div>

        <!-- File Upload -->
        <div style="flex:1;min-width:150px;">
            <asp:Label runat="server" Text="Upload Image (Optional)" style="display:block;margin-bottom:6px;font-weight:600;color:#555;"></asp:Label>
            <asp:FileUpload ID="fuImage" runat="server"
                onchange="previewImage(this,'imgPreview')"
                style="width:100%;border:1px solid #ccc;border-radius:6px;font-size:14px;background-color:#f9f9f9;" />
        </div>
    </div>

    <!-- Save Button -->
    <div style="text-align:center;margin-bottom:20px;">
        <asp:Button ID="btnSave" runat="server" Text="Save Image"
            OnClick="btnSave_Click"
            style="background:#007bff;color:#fff;border:none;font-size:16px;border-radius:6px;cursor:pointer;" 
            onmouseover="this.style.background='#0056b3';" 
            onmouseout="this.style.background='#007bff';" />
    </div>

    <!-- Saved Path -->
    <div style="margin-bottom:20px;">
        <asp:Label ID="lblSavedPath" runat="server" style="font-weight:600;color:green;display:block;text-align:center;"></asp:Label>
    </div>

    <!-- Image Preview -->
    <div style="text-align:center;">
        <asp:Image ID="imgPreview" runat="server" Visible="false" 
            style="display:block;margin:10px auto;border-radius:8px;border:1px solid #ddd;box-shadow:0 3px 8px rgba(0,0,0,0.1);" />
    </div>



   
<div style="margin:50px auto;background:#ffffff;border-radius:12px;box-shadow:0 8px 25px rgba(0,0,0,0.1);font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
    <h3 style="text-align:center;margin-bottom:15px;color:#fff;background-color:#6f42c1;line-height:2;border-radius:12px 12px 0 0;">
        &#12819; Menu Items & Images
    </h3>

  <asp:GridView ID="gvMenuImages" runat="server"
    AutoGenerateColumns="False"
    DataKeyNames="Id"
    OnRowEditing="gvMenuImages_RowEditing"
    OnRowCancelingEdit="gvMenuImages_RowCancelingEdit"
    OnRowUpdating="gvMenuImages_RowUpdating"
    OnRowCommand="gvMenuImages_RowCommand"
    style="width:100%;border-collapse:collapse;text-align:left;">

    <Columns>
        
        <asp:TemplateField HeaderText="Menu Item Name">
            <ItemTemplate>
                <span style="border:1px solid #ccc;padding:2px 4px;"><%# Eval("Name") %></span>
            </ItemTemplate>
        </asp:TemplateField>

        
        <asp:TemplateField HeaderText="Image Path">
            <ItemTemplate>
                <span style="border:1px solid #ccc;padding:2px 4px;"><%# Eval("ImagePath") %></span>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtEditImagePath" runat="server" Text='<%# Bind("ImagePath") %>'
                    style="border:1px solid #ccc;width:100%;font-size:14px;" />
            </EditItemTemplate>
        </asp:TemplateField>

        
        <asp:TemplateField HeaderText="Action">
            <ItemTemplate>
                <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" Text="Edit"
                    OnClientClick="return confirm('Are you sure you want to edit this path?');"
                    style="color:#007bff;text-decoration:none;margin-right:5px;" />
                <asp:Button ID="btnDeletePath" runat="server" Text="Delete Path"
                    CommandName="DeletePath" CommandArgument='<%# Eval("Id") %>'
                    OnClientClick="return confirm('Are you sure you want to delete this path?');"
                    style="color:#dc3545;background:none;border:none;cursor:pointer;text-decoration:underline;" />
            </ItemTemplate>
            <EditItemTemplate>
                <asp:LinkButton ID="btnUpdate" runat="server" CommandName="Update" Text="Update"
                    OnClientClick="return confirm('Are you sure you want to save changes?');"
                    style="color:#28a745;text-decoration:none;margin-right:5px;" />
                <asp:LinkButton ID="btnCancel" runat="server" CommandName="Cancel" Text="Cancel"
                    style="color:#6c757d;text-decoration:none;" />
            </EditItemTemplate>
        </asp:TemplateField>
    </Columns>
</asp:GridView>
</div>


</asp:Content>

