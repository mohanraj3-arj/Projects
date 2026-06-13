<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>

<%
    Integer userIdObj = (Integer) session.getAttribute("userId");
    if (userIdObj == null) { response.sendRedirect("LoginPage.jsp"); return; }
    int userId = userIdObj;
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    double maxTotal = 0.0;
    try {
        con = DBConnection.getConnection();
        String baseSql = "SELECT SUM(t.amount) AS total FROM transactions t JOIN credit_cards c ON t.card_id = c.card_id WHERE c.user_id = ? GROUP BY c.card_id ORDER BY total DESC LIMIT 1";
        ps = con.prepareStatement(baseSql);
        ps.setInt(1, userId); rs = ps.executeQuery();
        if (rs.next()) maxTotal = rs.getDouble("total");
        rs.close(); ps.close();
    } catch(Exception e) {}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Card Wise Spending – CardCompass </title>
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
.page-wrap{max-width:900px;margin:0 auto;padding:32px 28px;}
.page-header{display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:16px;margin-bottom:26px;}
.page-header h1{font-size:26px;font-weight:800;color:var(--navy);letter-spacing:-0.6px;margin-bottom:6px;}
.page-header p{font-size:14px;color:var(--muted);}
/* TABLE */
.table-wrap{background:var(--white);border-radius:14px;border:1px solid var(--border);box-shadow:var(--card-shadow);overflow:hidden;overflow-x:auto;}
table{width:100%;border-collapse:collapse;min-width:500px;}
thead th{background:#f8fafc;padding:13px 18px;text-align:left;font-size:11px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;border-bottom:1.5px solid var(--border);}
.th-right{text-align:right;}
tbody td{padding:16px 18px;font-size:14px;color:var(--text);border-bottom:1px solid #f1f5f9;vertical-align:middle;}
tbody tr:last-child td{border-bottom:none;}
tbody tr:hover{background:#f8fafc;}
/* CARD BADGE */
.card-badge{display:inline-flex;align-items:center;gap:10px;}
.card-mini{width:32px;height:22px;background:linear-gradient(135deg,var(--navy),var(--navy-2));border-radius:5px;flex-shrink:0;position:relative;overflow:hidden;}
.card-mini::before{content:'';position:absolute;top:-6px;right:-6px;width:22px;height:22px;background:rgba(59,130,246,.2);border-radius:50%;}
.card-name{font-weight:700;color:var(--navy);}
.card-number-cell{font-family:'Courier New',monospace;letter-spacing:2px;color:var(--muted);font-size:13.5px;}
.amount-cell{text-align:right;font-weight:800;color:#15803d;font-size:15px;}
/* BAR */
.bar-wrap{display:flex;align-items:center;gap:10px;}
.bar-bg{flex:1;height:8px;background:#f1f5f9;border-radius:20px;overflow:hidden;min-width:100px;}
.bar-fill{height:100%;border-radius:20px;background:linear-gradient(90deg,var(--blue),var(--green));}
/* EMPTY */
.empty-cell{text-align:center;padding:60px 20px !important;color:var(--muted);}
/* ACTIONS */
.page-actions{margin-top:20px;display:flex;gap:10px;flex-wrap:wrap;}
.btn-ghost{padding:11px 20px;background:var(--white);color:var(--text);border:1.5px solid var(--border);border-radius:10px;text-decoration:none;font-size:13.5px;font-weight:600;transition:all .2s;display:inline-flex;align-items:center;gap:6px;}
.btn-ghost:hover{background:var(--bg);border-color:#cbd5e1;}
.btn-primary{padding:11px 20px;background:var(--blue);color:var(--white);border:none;border-radius:10px;text-decoration:none;font-size:13.5px;font-weight:700;transition:all .22s;display:inline-flex;align-items:center;gap:6px;box-shadow:0 2px 8px rgba(59,130,246,.3);}
.btn-primary:hover{background:var(--blue-dark);transform:translateY(-1px);}
@media(max-width:768px){.app-header{padding:0 18px;height:auto;flex-wrap:wrap;gap:10px;padding-top:14px;padding-bottom:14px;}.app-nav{flex-wrap:wrap;justify-content:center;gap:6px;}.nav-link{padding:7px 11px;font-size:12.5px;}.page-wrap{padding:16px 14px;}}
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
        <a href="TransactionHistory.jsp"  class="nav-link">History</a>
        <a href="CatagerywiseSpending.jsp"class="nav-link">Category</a>
        <a href="CardWiseSpending.jsp"    class="nav-link active">By Card</a>
        <a href="ViewReport.jsp"          class="nav-link">Reports</a>
        <a href="AddTransactions.jsp"     class="nav-link btn-green">+ Transaction</a>
        <a href="index.jsp"               class="nav-link btn-logout">Logout</a>
    </nav>
</header>

<div class="page-wrap">
    <div class="page-header">
        <div>
            <h1>Card Wise Spending</h1>
            <p>Total amount spent on each of your credit cards.</p>
        </div>
    </div>

    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Card</th>
                    <th>Card Number</th>
                    <th>Spending Share</th>
                    <th class="th-right">Total Spent</th>
                </tr>
            </thead>
            <tbody>
<%
    try {
        String sql = "SELECT c.card_name, c.card_last4, c.card_id, SUM(t.amount) AS total_amount " +
            "FROM transactions t JOIN credit_cards c ON t.card_id = c.card_id " +
            "WHERE c.user_id = ? GROUP BY c.card_id, c.card_name, c.card_last4 ORDER BY total_amount DESC";
        ps = con.prepareStatement(sql);
        ps.setInt(1, userId); rs = ps.executeQuery();
        boolean hasRows = false;
        while (rs.next()) {
            hasRows = true;
            String cardName = rs.getString("card_name");
            String last4 = rs.getString("card_last4");
            double total = rs.getDouble("total_amount");
            int pct = maxTotal > 0 ? (int)(total / maxTotal * 100) : 100;
%>
                <tr>
                    <td>
                        <div class="card-badge">
                            <div class="card-mini"></div>
                            <span class="card-name"><%= cardName %></span>
                        </div>
                    </td>
                    <td class="card-number-cell">XXXX-XXXX-XXXX-<%= last4 %></td>
                    <td>
                        <div class="bar-wrap">
                            <div class="bar-bg"><div class="bar-fill" style="width:<%= pct %>%;"></div></div>
                            <span style="font-size:12px;color:var(--muted);font-weight:600;min-width:32px;"><%= pct %>%</span>
                        </div>
                    </td>
                    <td class="amount-cell">₹<%= String.format("%.2f", total) %></td>
                </tr>
<%
        }
        if (!hasRows) {
%>
                <tr><td colspan="4" class="empty-cell">
                    <div style="font-size:38px;margin-bottom:12px;">💳</div>
                    <div style="font-size:15px;font-weight:700;color:var(--navy);margin-bottom:6px;">No spending data yet</div>
                    <div style="font-size:13.5px;">Add transactions to see card-wise spending analysis.</div>
                </td></tr>
<%
        }
    } catch (Exception e) {
%>
                <tr><td colspan="4" style="text-align:center;padding:30px;color:var(--red);font-weight:600;">Error: <%= e.getMessage() %></td></tr>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (con != null) con.close(); } catch (Exception e) {}
    }
%>
            </tbody>
        </table>
    </div>

    <div class="page-actions">
        <a href="ViewReport.jsp"          class="btn-ghost">← Back to Reports</a>
        <a href="CatagerywiseSpending.jsp" class="btn-ghost">📂 Category Wise</a>
        <a href="Dashboard.jsp"            class="btn-primary">🏠 Dashboard</a>
    </div>
</div>
</body>
</html>
