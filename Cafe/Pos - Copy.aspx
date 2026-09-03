<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Pos - Copy.aspx.cs" Inherits="Pos" %>

<!DOCTYPE html>
<html>
<head>
    <title>POS</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f2f4f7;
        }

        .container {
            display: flex;
            height: 100vh;
        }

        /* LEFT: PRODUCTS */
        .products-section {
            flex: 3;
            padding: 15px;
            overflow-y: auto;
        }

        .product-box {
            width: 150px;
            background: #fff;
            padding: 10px;
            border-radius: 10px;
            margin: 8px;
            display: inline-block;
            cursor: pointer;
            box-shadow: 0 0 6px rgba(0,0,0,0.1);
            transition: 0.2s;
        }

        .product-box:hover {
            transform: scale(1.05);
        }

        .product-img {
            width: 100%;
            height: 110px;
            object-fit: contain;
        }

        .product-title {
            font-size: 15px;
            font-weight: bold;
            margin-top: 5px;
        }

        .product-price {
            font-size: 14px;
            color: #444;
        }

        /* RIGHT: CART */
        .cart-section {
            flex: 1;
            background: #fff;
            border-left: 2px solid #ddd;
            padding: 15px;
            display: flex;
            flex-direction: column;
        }

        .cart-items {
            flex: 1;
            overflow-y: auto;
            margin-top: 10px;
        }

        .cart-item {
            background: #f7f7f7;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 8px;
        }

        .cart-total {
            font-size: 20px;
            font-weight: bold;
            margin-top: 10px;
            text-align: right;
        }

        .btn-submit {
            width: 100%;
            background: #007bff;
            padding: 12px;
            border: none;
            color: white;
            font-size: 18px;
            border-radius: 6px;
            cursor: pointer;
        }

        /* MEMBER BOX */
        .member-box {
            background: #ffffff;
            padding: 10px;
            border-radius: 8px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }

        /* MOBILE CART ICON */
        .mobile-cart-btn {
            display: none;
            position: fixed;
            bottom: 15px;
            right: 15px;
            background: #007bff;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            color: white;
            font-size: 22px;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            cursor: pointer;
        }

        .cart-count {
            position: absolute;
            top: -3px;
            right: -3px;
            background: red;
            color: white;
            font-size: 14px;
            padding: 3px 6px;
            border-radius: 50%;
        }

        /* MOBILE CART DRAWER */
        .mobile-cart-drawer {
            position: fixed;
            top: 0;
            right: -100%;
            width: 85%;
            height: 100%;
            background: white;
            box-shadow: -2px 0 10px rgba(0,0,0,0.3);
            transition: 0.4s;
            padding: 15px;
            z-index: 99999;
            display: flex;
            flex-direction: column;
        }

        .mobile-cart-close {
            background: red;
            color: white;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 10px;
            border: none;
        }

        @media(max-width: 768px) {
            .cart-section {
                display: none;
            }

            .mobile-cart-btn {
                display: flex;
            }

            .products-section {
                flex: 1;
            }
        }
    </style>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

</head>

<body>

<div class="container">

    <!-- LEFT SIDE -->
    <div class="products-section">

        <input type="text" id="txtSearch" placeholder="Search products..."
               style="width:100%;padding:10px;font-size:18px;border-radius:6px;border:1px solid #ccc;" />

        <div id="productList" style="margin-top:15px;"></div>

    </div>

    <!-- RIGHT SIDE CART (DESKTOP) -->
    <div class="cart-section">

        <div class="member-box">
            <input type="text" id="txtMember" placeholder="Enter Member Card" style="width:100%;padding:10px;" />
            <div id="memberInfo" style="margin-top:10px;font-size:16px;color:#333;"></div>
        </div>

        <div class="cart-items" id="cartItems"></div>

        <div class="cart-total">Total: Rs <span id="totalAmount">0</span></div>

        <button class="btn-submit" onclick="submitBill()">Submit</button>

    </div>

</div>


<!-- MOBILE CART ICON -->
<div class="mobile-cart-btn" onclick="openMobileCart()">
    🛒
    <span class="cart-count" id="mobileCartCount">0</span>
</div>

<!-- MOBILE CART DRAWER -->
<div class="mobile-cart-drawer" id="mobileCartDrawer">
    <button class="mobile-cart-close" onclick="closeMobileCart()">Close ✖</button>

    <div class="member-box">
        <input type="text" id="txtMemberMobile" placeholder="Enter Member Card" style="width:100%;padding:10px;" />
        <div id="memberInfoMobile" style="margin-top:10px;font-size:16px;color:#333;"></div>
    </div>

    <div class="cart-items" id="cartItemsMobile"></div>

    <div class="cart-total">Total: Rs <span id="totalAmountMobile">0</span></div>

    <button class="btn-submit" onclick="submitBill()">Submit</button>
</div>

<script>

    let cart = [];
    let member = null;

    // ---------------- LOAD PRODUCTS ----------------
    function loadProducts() {
        $.ajax({
            type: "POST",
            url: "Pos.aspx/GetProducts",
            data: JSON.stringify({ search: $("#txtSearch").val() }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (res) {
                let data = res.d;
                let html = "";

                data.forEach(p => {
                    html += `
                        <div class='product-box' onclick='addToCart("${p.id}", "${p.name}", ${p.price})'>
                            <img src='${p.image}' class='product-img' onerror="this.src='resources/images/NoProduct.png'" />
                            <div class='product-title'>${p.name}</div>
                            <div class='product-price'>Rs ${p.price}</div>
                        </div>`;
            });

        $("#productList").html(html);
    }
    });
    }

    $("#txtSearch").on("keyup", loadProducts);
    loadProducts();

    // ---------------- ADD TO CART ----------------
    function addToCart(id, name, price) {

        let item = cart.find(x => x.id === id);

        if (item) {
            item.qty += 1;
        } else {
            cart.push({ id, name, price, qty: 1 });
        }

        updateCart();
    }

    // ---------------- UPDATE CART UI ----------------
    function updateCart() {

        let total = 0;
        let html = "";

        cart.forEach(c => {
            total += c.qty * c.price;

        html += `
            <div class='cart-item'>
                <b>${c.name}</b><br/>
                Rs ${c.price} × ${c.qty}
        </div>`;
    });

    $("#cartItems").html(html);
    $("#cartItemsMobile").html(html);

    $("#totalAmount").text(total);
    $("#totalAmountMobile").text(total);

    $("#mobileCartCount").text(cart.length);
    }

    // ---------------- GET MEMBER ----------------
    $("#txtMember, #txtMemberMobile").on("keyup", function () {
        let val = $(this).val();

        $.ajax({
            type: "POST",
            url: "Pos.aspx/GetMember",
            data: JSON.stringify({ search: val }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (res) {
                member = res.d;

                if (!member) {
                    $("#memberInfo, #memberInfoMobile").html("");
                    return;
                }

                $("#memberInfo").html(`
                    <b>${member.name}</b><br/>
                Mobile: ${member.mobile}<br/>
        Balance: <span style='color:green;font-size:18px;font-weight:bold;'>Rs ${member.balance}</span>
                `);

        $("#memberInfoMobile").html(`
            <b>${member.name}</b><br/>
        Mobile: ${member.mobile}<br/>
    Balance: <span style='color:green;font-size:18px;font-weight:bold;'>Rs ${member.balance}</span>
                `);
    }
    });
    });

    // ---------------- SUBMIT BILL ----------------
    function submitBill() {

        if (!member) {
            alert("Enter valid Member Card");
            return;
        }

        let total = parseFloat($("#totalAmount").text());

        if (total > member.balance) {
            alert("❌ Insufficient Member Balance!");
            return;
        }

        $.ajax({
            type: "POST",
            url: "Pos.aspx/SubmitBill",
            data: JSON.stringify({
                empID: member.empID,
                totalAmount: total
            }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (res) {

                if (!res.d.success) {
                    alert(res.d.message);
                    return;
                }

                alert("Bill submitted successfully!\nRemaining Balance: Rs " + res.d.remaining);

                cart = [];
                updateCart();
            }
        });
    }

    // ---------------- MOBILE CART ----------------
    function openMobileCart() {
        document.getElementById("mobileCartDrawer").style.right = "0";
    }

    function closeMobileCart() {
        document.getElementById("mobileCartDrawer").style.right = "-100%";
    }

</script>

</body>
</html>
