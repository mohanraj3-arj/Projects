<%-- TransactionHistory.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page import="java.util.ArrayList"%>

<%
    Integer userIdObj = (Integer) session.getAttribute("userId");
    if (userIdObj == null) { response.sendRedirect("LoginPage.jsp"); return; }
    int userId = userIdObj;

    class Transaction {
        int transactionId; String categoryName; double amount; String merchantName; java.sql.Date transactionDate;
        Transaction(int tid, String cat, double amt, String merch, java.sql.Date date) {
            this.transactionId=tid; this.categoryName=cat; this.amount=amt; this.merchantName=merch; this.transactionDate=date;
        }
    }
    ArrayList<Transaction> transactions = new ArrayList<>();
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction History – CardCompass </title>
    <%@ include file="common-style.jsp" %>

    <style>
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&display=swap');
:root{--navy:#0f172a;--navy-2:#1e293b;--blue:#3b82f6;--blue-dark:#2563eb;--green:#22c55e;--green-dk:#16a34a;--red:#ef4444;--amber:#f59e0b;--bg:#f1f5f9;--white:#ffffff;--border:#e2e8f0;--text:#0f172a;--muted:#64748b;--muted-2:#94a3b8;--card-shadow:0 1px 3px rgba(15,23,42,.07),0 4px 16px rgba(15,23,42,.05);}
*,*::before,*::after{margin:0;padding:0;box-sizing:border-box;}
html,body{width:100%;overflow-x:hidden;}
body{font-family:'Outfit',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;-webkit-font-smoothing:antialiased;}
.app-header{width:100%;height:64px;background:var(--navy);display:flex;align-items:center;justify-content:space-between;padding:0 32px;position:sticky;top:0;z-index:1000;box-shadow:0 2px 16px rgba(15,23,42,.3);}
.app-brand{display:flex;align-items:center;gap:10px;text-decoration:none;}
.app-brand-icon{width:36px;height:36px;background:linear-gradient(135deg,var(--blue),var(--green));border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:18px;}
.app-brand-name{font-size:16px;font-weight:700;color:var(--white);letter-spacing:-0.3px;}
.app-nav{display:flex;align-items:center;gap:6px;}
.nav-link{padding:8px 14px;border-radius:8px;font-size:13.5px;font-weight:500;text-decoration:none;color:#94a3b8;transition:all .2s;border:1.5px solid transparent;white-space:nowrap;}
.nav-link:hover{color:var(--white);background:rgba(255,255,255,.08);}
.nav-link.active{color:var(--white);background:rgba(59,130,246,.25);border-color:rgba(59,130,246,.4);}
.nav-link.btn-green{background:var(--green);color:var(--white);border-color:var(--green);font-weight:600;}
.nav-link.btn-green:hover{background:var(--green-dk);transform:translateY(-1px);}
.nav-link.btn-logout{color:#f87171;}
.nav-link.btn-logout:hover{background:rgba(239,68,68,.15);}
.page-wrap{max-width:1200px;margin:0 auto;padding:32px 28px;}
.page-header{display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:16px;margin-bottom:28px;}
.page-header h1{font-size:26px;font-weight:800;color:var(--navy);letter-spacing:-0.6px;margin-bottom:6px;}
.page-header p{font-size:14px;color:var(--muted);line-height:1.6;}
/* SUMMARY ROW */
.summary-row{background:var(--white);border-radius:14px;border:1px solid var(--border);padding:18px 24px;margin-bottom:24px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:14px;box-shadow:var(--card-shadow);border-left:4px solid var(--green);}
.summary-row-item{display:flex;flex-direction:column;gap:2px;}
.summary-row-label{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.7px;color:var(--muted);}
.summary-row-value{font-size:20px;font-weight:800;color:var(--navy);}
/* TABLE */
.table-wrap{background:var(--white);border-radius:14px;border:1px solid var(--border);box-shadow:var(--card-shadow);overflow:hidden;}
.table-toolbar{padding:16px 20px;border-bottom:1.5px solid var(--border);display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;}
.table-title{font-size:14px;font-weight:700;color:var(--navy);display:flex;align-items:center;gap:8px;}
.search-input{padding:9px 14px;border:1.5px solid var(--border);border-radius:8px;font-size:13.5px;font-family:'Outfit',sans-serif;background:#f8fafc;color:var(--text);outline:none;width:220px;transition:all .2s;}
.search-input:focus{border-color:var(--blue);background:var(--white);box-shadow:0 0 0 3px rgba(59,130,246,.1);}
table{width:100%;border-collapse:collapse;}
thead th{background:#f8fafc;padding:13px 16px;text-align:left;font-size:11px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;border-bottom:1.5px solid var(--border);}
.th-right{text-align:right;}
tbody td{padding:14px 16px;font-size:14px;color:var(--text);border-bottom:1px solid #f1f5f9;vertical-align:middle;}
tbody tr:last-child td{border-bottom:none;}
tbody tr:hover{background:#f8fafc;}
/* BADGE */
.cat-badge{display:inline-flex;align-items:center;gap:5px;padding:4px 10px;border-radius:20px;font-size:12px;font-weight:600;background:rgba(59,130,246,.1);color:#1e40af;}
.cat-food    {background:rgba(239,68,68,.1);   color:#b91c1c;}
.cat-travel  {background:rgba(59,130,246,.1);  color:#1e40af;}
.cat-shop    {background:rgba(245,158,11,.1);  color:#b45309;}
.cat-health  {background:rgba(34,197,94,.1);   color:#15803d;}
.cat-util    {background:rgba(168,85,247,.1);  color:#6b21a8;}
.cat-ent     {background:rgba(236,72,153,.1);  color:#9d174d;}
.cat-edu     {background:rgba(20,184,166,.1);  color:#0f766e;}
.cat-other   {background:rgba(100,116,139,.1); color:#334155;}
.amount-cell{text-align:right;font-weight:700;color:#15803d;font-size:15px;}
.id-cell{font-weight:700;color:var(--muted-2);font-size:13px;}
.merchant-cell{color:var(--navy);font-weight:500;}
.date-cell{color:var(--muted);font-size:13px;}
/* NO DATA */
.no-data-cell{text-align:center;padding:60px 20px !important;color:var(--muted);}
.no-data-icon{font-size:44px;margin-bottom:12px;}
.btn-add-link{display:inline-flex;align-items:center;gap:7px;padding:12px 22px;background:var(--blue);color:var(--white);text-decoration:none;border-radius:10px;font-size:14px;font-weight:700;margin-top:16px;transition:all .22s;}
.btn-add-link:hover{background:var(--blue-dark);transform:translateY(-1px);}
.btn-success{display:inline-flex;align-items:center;gap:7px;padding:11px 20px;background:var(--green);color:var(--white);text-decoration:none;border-radius:10px;font-size:14px;font-weight:700;transition:all .22s;box-shadow:0 2px 8px rgba(34,197,94,.3);}
.btn-success:hover{background:var(--green-dk);transform:translateY(-1px);}
@media(max-width:768px){.app-header{padding:0 18px;height:auto;flex-wrap:wrap;gap:10px;padding-top:14px;padding-bottom:14px;}.app-nav{flex-wrap:wrap;justify-content:center;gap:6px;}.nav-link{padding:7px 11px;font-size:12.5px;}.page-wrap{padding:16px 14px;}.search-input{width:100%;}}
@media(max-width:480px){.app-brand-name{display:none;}.app-nav{width:100%;}.nav-link{flex:1;text-align:center;}}
    </style>
</head>
<body>

<header class="app-header">
    <a href="Dashboard.jsp" class="app-brand">
        <div class="app-brand-icon">💳</div>
        <span class="app-brand-name">CardCompass </span>
    </a>
    <nav class="app-nav">
        <a href="Dashboard.jsp"           class="nav-link">Dashboard</a>
        <a href="Mycards.jsp"             class="nav-link">My Cards</a>
        <a href="TransactionHistory.jsp"  class="nav-link active">History</a>
        <a href="CatagerywiseSpending.jsp"class="nav-link">Spending</a>
        <a href="ViewReport.jsp"          class="nav-link">Reports</a>
        <a href="AddTransactions.jsp"     class="nav-link btn-green">+ Add Transaction</a>
        <a href="index.jsp"               class="nav-link btn-logout">Logout</a>
    </nav>
</header>

<div class="page-wrap">
    <div class="page-header">
        <div>
            <h1>Transaction History</h1>
            <p>All transactions for your saved cards, newest first.</p>
        </div>
        <a href="AddTransactions.jsp" class="btn-success">+ New Transaction</a>
    </div>

<%
    try {
        con = DBConnection.getConnection();
        String sql =
            "SELECT t.transaction_id, cat.category_name, t.amount, t.merchant_name, t.transaction_date " +
            "FROM transactions t " +
            "JOIN categories cat ON t.category_id = cat.category_id " +
            "JOIN credit_cards cards ON t.card_id = cards.card_id " +
            "WHERE cards.user_id = ? ORDER BY t.transaction_id DESC";
        ps = con.prepareStatement(sql);
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        double totalSpend = 0;
        while (rs.next()) {
            double amt = rs.getDouble("amount");
            totalSpend += amt;
            transactions.add(new Transaction(rs.getInt("transaction_id"), rs.getString("category_name"),
                amt, rs.getString("merchant_name"), rs.getDate("transaction_date")));
        }
        if (transactions.size() > 0) {
%>
    <div class="summary-row">
        <div class="summary-row-item">
            <span class="summary-row-label">Total Transactions</span>
            <span class="summary-row-value"><%= transactions.size() %></span>
        </div>
        <div class="summary-row-item">
            <span class="summary-row-label">Total Spent</span>
            <span class="summary-row-value">₹<%= String.format("%.2f", totalSpend) %></span>
        </div>
        <div class="summary-row-item">
            <span class="summary-row-label">Average Transaction</span>
            <span class="summary-row-value">₹<%= String.format("%.2f", totalSpend / transactions.size()) %></span>
        </div>
    </div>
<% } %>

    <div class="table-wrap">
        <div class="table-toolbar">
            <div class="table-title">📋 All Transactions</div>
            <input type="text" class="search-input" id="searchInput" placeholder="🔍 Search merchant, category..." onkeyup="filterTable()">
        </div>
        <table id="txnTable">
            <thead>
                <tr>
                    <th style="width:60px;">#</th>
                    <th style="width:160px;">Category</th>
                    <th class="th-right" style="width:130px;">Amount</th>
                    <th>Merchant</th>
                    <th style="width:120px;">Date</th>
                </tr>
            </thead>
            <tbody>
<%
        if (transactions.size() > 0) {
            int dn = 1;
            for (Transaction t : transactions) {
                String catClass = "cat-other";
                String cat = t.categoryName.toLowerCase();
                if (cat.contains("food")) catClass = "cat-food";
                else if (cat.contains("travel")) catClass = "cat-travel";
                else if (cat.contains("shop")) catClass = "cat-shop";
                else if (cat.contains("health")) catClass = "cat-health";
                else if (cat.contains("util")) catClass = "cat-util";
                else if (cat.contains("ent")) catClass = "cat-ent";
                else if (cat.contains("edu")) catClass = "cat-edu";
%>
                <tr>
                    <td class="id-cell"><%= dn %></td>
                    <td><span class="cat-badge <%= catClass %>"><%= t.categoryName %></span></td>
                    <td class="amount-cell">₹<%= String.format("%.2f", t.amount) %></td>
                    <td class="merchant-cell"><%= t.merchantName != null ? t.merchantName : "—" %></td>
                    <td class="date-cell"><%= t.transactionDate %></td>
                </tr>
<%
                dn++;
            }
        } else {
%>
                <tr><td colspan="5" class="no-data-cell">
                    <div class="no-data-icon">📭</div>
                    <div style="font-size:16px;font-weight:700;color:var(--navy);margin-bottom:6px;">No Transactions Yet</div>
                    <div style="font-size:14px;color:var(--muted);">Add your first transaction to start tracking spending.</div>
                    <a href="AddTransactions.jsp" class="btn-add-link">+ Add Transaction</a>
                </td></tr>
<%
        }
    } catch (Exception e) {
%>
                <tr><td colspan="5" style="text-align:center;padding:30px;color:var(--red);font-weight:600;">
                    Error loading transactions: <%= e.getMessage() %>
                </td></tr>
<%
    } finally {
        try { if (rs!=null) rs.close(); } catch(Exception e2) {}
        try { if (ps!=null) ps.close(); } catch(Exception e2) {}
        try { if (con!=null) con.close(); } catch(Exception e2) {}
    }
%>
            </tbody>
        </table>
    </div>
</div>

<script>
function filterTable() {
    var q = document.getElementById('searchInput').value.toLowerCase();
    var rows = document.querySelectorAll('#txnTable tbody tr');
    rows.forEach(function(row) {
        row.style.display = row.textContent.toLowerCase().indexOf(q) > -1 ? '' : 'none';
    });
}
</script>
</body>
</html>
