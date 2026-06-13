<%-- 
    Document   : Dashboard
    Created on : 27 Dec 2025, 8:46:43 pm
    Author     : arjun
--%>
<!--
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Dashboard</title>
        <link rel="stylesheet" href="css/styledashboard.css">
    </head>
    <body>
        <div class="dashboard-header">
    <div class="dashboard-title">Credit Card Spending Manager</div>

    <div class="dashboard-actions">
        <a href="Mycards.jsp">My Cards</a>
        <a href="AddTransactions.jsp">Add Transaction</a>
        <a href="AddCreditCard.jsp">Add Card</a>
        <a href="TransactionHistory.jsp">History</a>
        <a href="ViewReport.jsp">Report</a>
        <a href="MonthlyReport">Send PDF &#128233;</a>
        <a href="index.jsp">Logout</a>
    </div>
</div>

<div class="dashboard-container">
   
</div>






        
        
        
        
        
        
        
    </body>
</html>-->



<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("LoginPage.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard – Card Compass </title>
    <%@ include file="common-style.jsp" %>

    <style>
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&display=swap');
:root{--navy:#0f172a;--navy-2:#1e293b;--blue:#3b82f6;--blue-dark:#2563eb;--green:#22c55e;--green-dk:#16a34a;--red:#ef4444;--amber:#f59e0b;--bg:#f1f5f9;--white:#ffffff;--border:#e2e8f0;--text:#0f172a;--muted:#64748b;--muted-2:#94a3b8;--card-shadow:0 1px 3px rgba(15,23,42,.07),0 4px 16px rgba(15,23,42,.05);--hover-shadow:0 8px 28px rgba(15,23,42,.14);}
*,*::before,*::after{margin:0;padding:0;box-sizing:border-box;}
html,body{width:100%;overflow-x:hidden;}
body{font-family:'Outfit',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;-webkit-font-smoothing:antialiased;}
/* HEADER */
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
.nav-link.btn-logout:hover{background:rgba(239,68,68,.15);color:#fca5a5;}
/* CONTENT */
.page-wrap{max-width:1200px;margin:0 auto;padding:32px 28px;}
/* WELCOME BANNER */
.welcome-banner{background:linear-gradient(135deg,var(--navy) 0%,#0f2044 100%);border-radius:16px;padding:32px 36px;margin-bottom:28px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:20px;position:relative;overflow:hidden;}
.welcome-banner::before{content:'';position:absolute;top:-40px;right:-40px;width:250px;height:250px;background:rgba(59,130,246,.12);border-radius:50%;}
.welcome-banner::after{content:'';position:absolute;bottom:-60px;left:200px;width:200px;height:200px;background:rgba(34,197,94,.08);border-radius:50%;}
.welcome-text h2{font-size:24px;font-weight:800;color:var(--white);margin-bottom:6px;letter-spacing:-0.5px;}
.welcome-text p{font-size:14px;color:rgba(255,255,255,.6);}
.welcome-actions{display:flex;gap:10px;flex-wrap:wrap;position:relative;}
.btn{display:inline-flex;align-items:center;justify-content:center;gap:7px;padding:12px 22px;border-radius:10px;font-size:14px;font-weight:700;font-family:'Outfit',sans-serif;cursor:pointer;border:none;transition:all .22s;text-decoration:none;white-space:nowrap;}
.btn-green{background:var(--green);color:var(--white);box-shadow:0 2px 8px rgba(34,197,94,.3);}
.btn-green:hover{background:var(--green-dk);transform:translateY(-1px);box-shadow:0 6px 18px rgba(34,197,94,.4);}
.btn-ghost-white{background:rgba(255,255,255,.12);color:var(--white);border:1.5px solid rgba(255,255,255,.2);}
.btn-ghost-white:hover{background:rgba(255,255,255,.2);}
/* ═══════════════════════════════
   STAT CARDS — Dark Glass Edition
   ═══════════════════════════════ */
.stat-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.stat-card {
  position: relative;
  border-radius: 20px;
  padding: 28px 26px 22px;
  overflow: hidden;
  cursor: default;
  background: linear-gradient(145deg, #0f172a 0%, #1a2540 100%);
  border: 1px solid rgba(255,255,255,0.07);
  box-shadow:
    0 4px 24px rgba(0,0,0,0.4),
    inset 0 1px 0 rgba(255,255,255,0.06);
  transition: transform 0.3s cubic-bezier(0.34,1.56,0.64,1), box-shadow 0.3s ease;
}

/* Neon glow ring on hover */
.stat-card:hover {
  transform: translateY(-6px) scale(1.02);
  box-shadow:
    0 0 0 1px var(--sc-neon),
    0 8px 40px rgba(0,0,0,0.5),
    0 0 60px -10px var(--sc-glow);
}

/* Diagonal shimmer sweep on hover */
.stat-card::before {
  content: '';
  position: absolute;
  top: 0; left: -100%; width: 60%; height: 100%;
  background: linear-gradient(105deg, transparent 40%, rgba(255,255,255,0.05) 50%, transparent 60%);
  transition: left 0.6s ease;
  z-index: 1;
}
.stat-card:hover::before { left: 160%; }

/* Glowing orb in background */
.stat-card::after {
  content: '';
  position: absolute;
  bottom: -40px; right: -30px;
  width: 130px; height: 130px;
  border-radius: 50%;
  background: radial-gradient(circle, var(--sc-glow) 0%, transparent 65%);
  pointer-events: none;
  transition: transform 0.4s ease, opacity 0.4s ease;
  opacity: 0.6;
}
.stat-card:hover::after { transform: scale(1.5); opacity: 1; }

/* Card colour tokens */
.stat-card.blue  { --sc-neon: rgba(99,102,241,0.6);  --sc-glow: rgba(99,102,241,0.35);  --sc-accent: #818cf8; --sc-mid: #6366f1; --sc-dark: #4338ca; }
.stat-card.green { --sc-neon: rgba(16,185,129,0.6);  --sc-glow: rgba(16,185,129,0.35);  --sc-accent: #34d399; --sc-mid: #10b981; --sc-dark: #059669; }
.stat-card.amber { --sc-neon: rgba(245,158,11,0.6);  --sc-glow: rgba(245,158,11,0.35);  --sc-accent: #fcd34d; --sc-mid: #f59e0b; --sc-dark: #d97706; }
.stat-card.red   { --sc-neon: rgba(239,68,68,0.6);   --sc-glow: rgba(239,68,68,0.35);   --sc-accent: #f87171; --sc-mid: #ef4444; --sc-dark: #dc2626; }

/* Top accent line */
.stat-card-line {
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 2px;
  background: linear-gradient(90deg, transparent 0%, var(--sc-accent) 40%, var(--sc-mid) 60%, transparent 100%);
  border-radius: 20px 20px 0 0;
}

/* Card content sits above pseudo-elements */
.stat-card-inner { position: relative; z-index: 2; }

/* Top row: label + icon */
.stat-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.stat-label {
  font-size: 10.5px;
  font-weight: 700;
  color: rgba(255,255,255,0.45);
  text-transform: uppercase;
  letter-spacing: 1.2px;
}

.stat-icon-wrap {
  width: 44px; height: 44px;
  border-radius: 14px;
  display: flex; align-items: center; justify-content: center;
  font-size: 20px;
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.1);
  box-shadow: 0 0 20px -4px var(--sc-glow);
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}
.stat-card:hover .stat-icon-wrap {
  transform: rotate(-6deg) scale(1.1);
  box-shadow: 0 0 30px -2px var(--sc-glow);
}

/* Big value */
.stat-value {
  font-size: 36px;
  font-weight: 900;
  letter-spacing: -1.5px;
  line-height: 1;
  margin-bottom: 6px;
  background: linear-gradient(135deg, #ffffff 30%, var(--sc-accent));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* Sub-label under value */
.stat-desc {
  font-size: 11.5px;
  color: rgba(255,255,255,0.3);
  margin-bottom: 20px;
  letter-spacing: 0.2px;
}

/* Footer divider + link */
.stat-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 16px;
  border-top: 1px solid rgba(255,255,255,0.07);
}

.stat-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  font-weight: 600;
  color: var(--sc-accent);
  text-decoration: none;
  letter-spacing: 0.2px;
  transition: gap 0.2s ease, opacity 0.2s ease;
}
.stat-link:hover { gap: 10px; opacity: 0.75; }
.stat-link svg { width: 12px; height: 12px; transition: transform 0.2s ease; }
.stat-link:hover svg { transform: translateX(3px); }

/* Tiny live-dot indicator */
.stat-dot {
  width: 7px; height: 7px;
  border-radius: 50%;
  background: var(--sc-accent);
  box-shadow: 0 0 8px 2px var(--sc-glow);
  animation: pulse-dot 2s infinite;
}
@keyframes pulse-dot {
  0%,100% { transform: scale(1); opacity:1; }
  50%      { transform: scale(1.5); opacity:0.5; }
}
/* INFO BOX */
.info-box{background:var(--white);border-radius:14px;padding:18px 22px;border:1px solid var(--border);box-shadow:var(--card-shadow);border-left:4px solid var(--blue);font-size:14px;color:var(--muted);line-height:1.7;}
.info-box strong{color:var(--navy);}
/* QUICK LINKS */
.quick-links{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px;margin-bottom:28px;}
.quick-link-card{background:var(--white);border-radius:14px;padding:20px 18px;border:1px solid var(--border);box-shadow:var(--card-shadow);text-decoration:none;text-align:center;transition:all .22s;display:flex;flex-direction:column;align-items:center;gap:10px;}
.quick-link-card:hover{transform:translateY(-3px);box-shadow:var(--hover-shadow);border-color:var(--blue);}
.quick-link-icon{width:46px;height:46px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:22px;}
.ql-blue{background:rgba(59,130,246,.1);}
.ql-green{background:rgba(34,197,94,.1);}
.ql-amber{background:rgba(245,158,11,.1);}
.ql-red{background:rgba(239,68,68,.1);}
.ql-purple{background:rgba(168,85,247,.1);}
.quick-link-label{font-size:13px;font-weight:600;color:var(--navy);}
@media(max-width:768px){.app-header{padding:0 18px;height:auto;flex-wrap:wrap;gap:10px;padding-top:14px;padding-bottom:14px;}.app-nav{flex-wrap:wrap;justify-content:center;gap:6px;}.nav-link{padding:7px 11px;font-size:12.5px;}.page-wrap{padding:16px 14px;}.stat-cards{grid-template-columns:1fr 1fr;}.welcome-banner{padding:22px 20px;}.welcome-text h2{font-size:19px;}}
@media(max-width:480px){.stat-cards{grid-template-columns:1fr;}.app-brand-name{display:none;}.app-nav{width:100%;}.nav-link{flex:1;text-align:center;}}
    </style>
</head>
<body>

<header class="app-header">
    <a href="Dashboard.jsp" class="app-brand">
        <div class="app-brand-icon">💳</div>
        <span class="app-brand-name">CardCompass</span>
    </a>
    <nav class="app-nav">
        <a href="Dashboard.jsp"          class="nav-link active">Dashboard</a>
        <a href="Mycards.jsp"            class="nav-link">My Cards</a>
        <a href="AddCreditCard.jsp"      class="nav-link">Add Card</a>
        <a href="TransactionHistory.jsp" class="nav-link">History</a>
        <a href="ViewReport.jsp"         class="nav-link">Reports</a>
        <a href="AddTransactions.jsp"    class="nav-link btn-green">+ Add Transaction</a>
        <a href="MonthlyReport"          class="nav-link">Send PDF 📧</a>
        <a href="index.jsp"              class="nav-link btn-logout">Logout</a>
    </nav>
</header>

<div class="page-wrap">

    <div class="welcome-banner">
        <div class="welcome-text">
            <h2>Welcome Back! 👋</h2>
            <p>Here's your credit card spending overview</p>
        </div>
        <div class="welcome-actions">
            <a href="AddTransactions.jsp" class="btn btn-green">+ New Transaction</a>
            <a href="ViewReport.jsp" class="btn btn-ghost-white">View Reports</a>
        </div>
    </div>

    <div class="stat-cards">

        <!-- MY CARDS -->
        <div class="stat-card blue">
          <div class="stat-card-line"></div>
          <div class="stat-card-inner">
            <div class="stat-card-header">
              <span class="stat-label">My Cards</span>
              <div class="stat-icon-wrap">💳</div>
            </div>
            <div class="stat-value">—</div>
            <div class="stat-desc">Active credit cards</div>
            <div class="stat-footer">
              <a href="Mycards.jsp" class="stat-link">
                View all cards
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg>
              </a>
              <span class="stat-dot"></span>
            </div>
          </div>
        </div>

        <!-- TOTAL TRANSACTIONS -->
        <div class="stat-card green">
          <div class="stat-card-line"></div>
          <div class="stat-card-inner">
            <div class="stat-card-header">
              <span class="stat-label">Transactions</span>
              <div class="stat-icon-wrap">📊</div>
            </div>
            <div class="stat-value">—</div>
            <div class="stat-desc">Total recorded entries</div>
            <div class="stat-footer">
              <a href="TransactionHistory.jsp" class="stat-link">
                View history
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg>
              </a>
              <span class="stat-dot"></span>
            </div>
          </div>
        </div>

        <!-- CATEGORY SPENDING -->
        <div class="stat-card amber">
          <div class="stat-card-line"></div>
          <div class="stat-card-inner">
            <div class="stat-card-header">
              <span class="stat-label">Category Spend</span>
              <div class="stat-icon-wrap">🏷️</div>
            </div>
            <div class="stat-value">—</div>
            <div class="stat-desc">Spending by category</div>
            <div class="stat-footer">
              <a href="CatagerywiseSpending.jsp" class="stat-link">
                View breakdown
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg>
              </a>
              <span class="stat-dot"></span>
            </div>
          </div>
        </div>

        <!-- REPORTS -->
        <div class="stat-card red">
          <div class="stat-card-line"></div>
          <div class="stat-card-inner">
            <div class="stat-card-header">
              <span class="stat-label">Reports</span>
              <div class="stat-icon-wrap">📄</div>
            </div>
            <div class="stat-value">—</div>
            <div class="stat-desc">Monthly summaries</div>
            <div class="stat-footer">
              <a href="ViewReport.jsp" class="stat-link">
                View reports
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg>
              </a>
              <span class="stat-dot"></span>
            </div>
          </div>
        </div>

    </div>

    <div class="quick-links">
        <a href="Mycards.jsp" class="quick-link-card">
            <div class="quick-link-icon ql-blue">💳</div>
            <span class="quick-link-label">My Cards</span>
        </a>
        <a href="AddTransactions.jsp" class="quick-link-card">
            <div class="quick-link-icon ql-green">➕</div>
            <span class="quick-link-label">Add Transaction</span>
        </a>
        <a href="TransactionHistory.jsp" class="quick-link-card">
            <div class="quick-link-icon ql-amber">📋</div>
            <span class="quick-link-label">History</span>
        </a>
        <a href="CatagerywiseSpending.jsp" class="quick-link-card">
            <div class="quick-link-icon ql-purple">📊</div>
            <span class="quick-link-label">Category Spend</span>
        </a>
        <a href="CardWiseSpending.jsp" class="quick-link-card">
            <div class="quick-link-icon ql-red">📈</div>
            <span class="quick-link-label">Card Spend</span>
        </a>
        <a href="ViewReport.jsp" class="quick-link-card">
            <div class="quick-link-icon ql-blue">📄</div>
            <span class="quick-link-label">Reports</span>
        </a>
    </div>

    <div class="info-box">
        ℹ️ <strong>Tip:</strong> Use the navigation above to manage cards, log transactions, view spending breakdowns by category or card, or download a monthly PDF report to your email.
    </div>

</div>
</body>
</html>

