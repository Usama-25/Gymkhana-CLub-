import os

target_file = r'c:\Users\ikram\source\repos\GuestRoomApp\GuestRoomApp\GuestRoomM\SiteGuestroom.master'

new_item = """                            </asp:Repeater>

                            <div class="nav-item nav-dropdown" id="navStayExtension">
                                <div class="nav-link" onclick="toggleNav('navStayExtension')">
                                    <i class="fas fa-clock-rotate-left"></i>
                                    <span class="nav-label">Stay Extension</span>
                                    <i class="fas fa-chevron-right nav-arrow"></i>
                                </div>
                                <div class="dropdown-menu">
                                    <a href="~/GuestRoomM/RoomExtension.aspx" runat="server" class="dropdown-link">Extend Stay</a>
                                </div>
                            </div>
                            
                            <asp:Panel ID="pnlAdminNav" runat="server" Visible="false">"""

old_item = """                            </asp:Repeater>
                            
                            <asp:Panel ID="pnlAdminNav" runat="server" Visible="false">"""

if os.path.exists(target_file):
    with open(target_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if old_item in content:
        new_content = content.replace(old_item, new_item)
        with open(target_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print("Replacement successful")
    else:
        # Try without spaces? Or just different pattern
        print("Old item pattern not found")
        # Let's try a simpler pattern
        old_item_2 = "</asp:Repeater>"
        new_item_2 = old_item_2 + '\n\n                            <div class="nav-item nav-dropdown" id="navStayExtension">\n                                <div class="nav-link" onclick="toggleNav(\'navStayExtension\')">\n                                    <i class="fas fa-clock-rotate-left"></i>\n                                    <span class="nav-label">Stay Extension</span>\n                                    <i class="fas fa-chevron-right nav-arrow"></i>\n                                </div>\n                                <div class="dropdown-menu">\n                                    <a href="~/GuestRoomM/RoomExtension.aspx" runat="server" class="dropdown-link">Extend Stay</a>\n                                </div>\n                            </div>'
        if old_item_2 in content:
             new_content = content.replace(old_item_2, new_item_2, 1) # Only first occurrence
             with open(target_file, 'w', encoding='utf-8') as f:
                 f.write(new_content)
             print("Replacement successful with pattern 2")
else:
    print("File not found")
