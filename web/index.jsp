<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CardCompass – Smart Credit Card Spending Tracker</title>
    <%@ include file="common-style.jsp" %>

    <style>
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap');

/* ── Design tokens — exact match with Dashboard.jsp ── */
:root {
    --navy:         #0f172a;
    --navy-2:       #1e293b;
    --blue:         #3b82f6;
    --blue-dark:    #2563eb;
    --green:        #22c55e;
    --green-dk:     #16a34a;
    --amber:        #f59e0b;
    --white:        #ffffff;
    --border:       #e2e8f0;
    --muted:        #64748b;
    --muted-2:      #94a3b8;
}

*, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
html { scroll-behavior: smooth; }
body {
    font-family: 'Outfit', sans-serif;
    background: var(--navy);
    color: var(--white);
    min-height: 100vh;
    -webkit-font-smoothing: antialiased;
    overflow-x: hidden;
}

/* ══════════════════════
   NAVBAR
══════════════════════ */
.navbar {
    position: fixed; top: 0; left: 0; right: 0; z-index: 1000;
    height: 64px;
    background: rgba(15,23,42,.92);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border-bottom: 1px solid rgba(255,255,255,.07);
    display: flex; align-items: center; justify-content: space-between;
    padding: 0 40px;
    box-shadow: 0 2px 24px rgba(0,0,0,.35);
}
.brand { display:flex; align-items:center; gap:11px; text-decoration:none; }
.brand-icon {
    width: 38px; height: 38px;
    background: linear-gradient(135deg, var(--blue), var(--green));
    border-radius: 11px;
    display: flex; align-items:center; justify-content:center;
    font-size: 19px;
    box-shadow: 0 4px 14px rgba(59,130,246,.4);
}
.brand-name { font-size:17px; font-weight:800; color:var(--white); letter-spacing:-0.4px; }

.nav-links { display:flex; align-items:center; gap:10px; }
.btn-login {
    padding: 8px 20px;
    background: transparent;
    color: var(--muted-2);
    border: 1.5px solid rgba(255,255,255,.14);
    border-radius: 9px;
    font-size: 14px; font-weight: 600;
    text-decoration: none;
    transition: all .2s;
}
.btn-login:hover { color:var(--white); border-color:rgba(255,255,255,.3); background:rgba(255,255,255,.07); }
.btn-register {
    padding: 9px 22px;
    background: var(--green);
    color: var(--white);
    border-radius: 9px;
    font-size: 14px; font-weight: 700;
    text-decoration: none;
    transition: all .22s;
    box-shadow: 0 3px 14px rgba(34,197,94,.4);
}
.btn-register:hover { background:var(--green-dk); transform:translateY(-1px); box-shadow:0 6px 22px rgba(34,197,94,.5); }

/* hamburger */
.hamburger { display:none; flex-direction:column; gap:5px; cursor:pointer; padding:4px; }
.hamburger span { width:24px; height:2px; background:var(--muted-2); border-radius:2px; transition:all .3s; }
.mobile-menu {
    display: none;
    position: fixed; top:64px; left:0; right:0; z-index:999;
    background: var(--navy-2);
    border-bottom: 1px solid rgba(255,255,255,.08);
    padding: 20px 24px;
    flex-direction: column; gap:12px;
}
.mobile-menu.open { display:flex; }
.mobile-menu a { display:block; padding:12px 16px; border-radius:9px; text-decoration:none; font-size:15px; font-weight:600; }
.mobile-menu .btn-login { color:var(--white); border-color:rgba(255,255,255,.15); }
.mobile-menu .btn-register { text-align:center; }

/* ══════════════════════
   HERO
══════════════════════ */
.hero {
    min-height: 100vh;
    display: flex; align-items: center; justify-content: center;
    position: relative; overflow: hidden;
    padding: 120px 40px 80px;
}

/* animated glowing orbs */
.orb { position:absolute; border-radius:50%; filter:blur(72px); pointer-events:none; }
.orb-1 { width:560px; height:560px; background:rgba(59,130,246,.16); top:-160px; right:-140px; animation:drift1 10s ease-in-out infinite; }
.orb-2 { width:440px; height:440px; background:rgba(34,197,94,.11); bottom:-120px; left:-100px; animation:drift2 12s ease-in-out infinite; }
.orb-3 { width:280px; height:280px; background:rgba(245,158,11,.08); top:40%; left:38%; animation:drift3 9s ease-in-out infinite; }

@keyframes drift1 { 0%,100%{transform:translate(0,0) scale(1)}   50%{transform:translate(-20px,25px) scale(1.06)} }
@keyframes drift2 { 0%,100%{transform:translate(0,0) scale(1)}   50%{transform:translate(18px,-20px) scale(1.04)} }
@keyframes drift3 { 0%,100%{transform:translate(0,0) scale(1)}   50%{transform:translate(-14px,18px) scale(1.08)} }

/* dot grid */
.hero::before {
    content:'';
    position:absolute; inset:0;
    background-image: radial-gradient(rgba(255,255,255,.055) 1px, transparent 1px);
    background-size: 30px 30px;
    pointer-events:none;
}

/* gradient fade at bottom of hero */
.hero::after {
    content:'';
    position:absolute; bottom:0; left:0; right:0; height:120px;
    background: linear-gradient(to bottom, transparent, var(--navy));
    pointer-events:none;
}

.hero-inner {
    position:relative; z-index:2;
    max-width:820px;
    text-align:center;
    animation: fadeUp .9s ease both;
}
@keyframes fadeUp { from{opacity:0;transform:translateY(32px)} to{opacity:1;transform:translateY(0)} }

.hero-badge {
    display:inline-flex; align-items:center; gap:8px;
    background: rgba(34,197,94,.1);
    border: 1px solid rgba(34,197,94,.28);
    color: var(--green);
    padding: 6px 18px; border-radius:100px;
    font-size: 13px; font-weight: 600;
    margin-bottom: 28px;
    animation: fadeUp .7s ease .1s both;
}
.hero-badge::before { content:'●'; font-size:8px; animation:blink 2s infinite; }
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:.3} }

.hero h1 {
    font-size: clamp(40px, 7vw, 72px);
    font-weight: 900;
    line-height: 1.1;
    letter-spacing: -2px;
    margin-bottom: 24px;
    animation: fadeUp .8s ease .2s both;
}
.hero h1 .accent-blue  { color: var(--blue); }
.hero h1 .accent-green { color: var(--green); }

.hero-sub {
    font-size: clamp(16px, 2vw, 20px);
    color: var(--muted-2);
    line-height: 1.7;
    max-width: 600px;
    margin: 0 auto 40px;
    font-weight: 400;
    animation: fadeUp .8s ease .3s both;
}

.hero-cta {
    display: flex; gap:14px; justify-content:center; flex-wrap:wrap;
    animation: fadeUp .8s ease .4s both;
}
.cta-primary {
    display:inline-flex; align-items:center; gap:8px;
    padding: 15px 32px;
    background: var(--green);
    color: var(--white);
    border-radius: 12px;
    font-size: 16px; font-weight: 700;
    text-decoration: none;
    transition: all .22s;
    box-shadow: 0 4px 20px rgba(34,197,94,.4);
}
.cta-primary:hover { background:var(--green-dk); transform:translateY(-2px); box-shadow:0 8px 28px rgba(34,197,94,.5); }

.cta-secondary {
    display:inline-flex; align-items:center; gap:8px;
    padding: 15px 32px;
    background: rgba(255,255,255,.07);
    color: var(--white);
    border: 1.5px solid rgba(255,255,255,.18);
    border-radius: 12px;
    font-size: 16px; font-weight: 600;
    text-decoration: none;
    transition: all .22s;
}
.cta-secondary:hover { background:rgba(255,255,255,.13); border-color:rgba(255,255,255,.3); transform:translateY(-2px); }

/* ── Stats strip ── */
.stats-strip {
    display: flex; justify-content:center; gap:48px; flex-wrap:wrap;
    margin-top: 60px;
    padding-top: 40px;
    border-top: 1px solid rgba(255,255,255,.08);
    animation: fadeUp .8s ease .5s both;
}
.stat-item { text-align:center; }
.stat-num {
    font-size: 32px; font-weight: 800;
    letter-spacing: -1px;
    background: linear-gradient(135deg, var(--blue), var(--green));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}
.stat-label { font-size:13px; color:var(--muted-2); font-weight:500; margin-top:4px; }

/* ══════════════════════
   FEATURES SECTION
══════════════════════ */
.section {
    padding: 100px 40px;
    max-width: 1200px;
    margin: 0 auto;
}
.section-tag {
    display:inline-block;
    background: rgba(59,130,246,.1);
    border: 1px solid rgba(59,130,246,.25);
    color: var(--blue);
    padding: 5px 16px; border-radius:100px;
    font-size: 12.5px; font-weight: 700;
    letter-spacing: .5px; text-transform:uppercase;
    margin-bottom: 16px;
}
.section-title {
    font-size: clamp(28px, 4vw, 44px);
    font-weight: 800; letter-spacing: -1.2px;
    margin-bottom: 14px;
}
.section-sub {
    font-size: 17px; color:var(--muted-2); line-height:1.65;
    max-width: 520px; margin-bottom:56px;
}

/* Feature cards grid */
.features-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: 20px;
}
.feature-card {
    background: var(--navy-2);
    border: 1px solid rgba(255,255,255,.07);
    border-radius: 18px;
    padding: 30px 28px;
    transition: all .28s;
    position: relative;
    overflow: hidden;
}
.feature-card::before {
    content:'';
    position:absolute; top:0; left:0; right:0; height:2px;
    background: var(--card-accent, linear-gradient(90deg, var(--blue), var(--green)));
    opacity:0; transition:opacity .28s;
}
.feature-card:hover { transform:translateY(-5px); border-color:rgba(255,255,255,.14); box-shadow:0 20px 48px rgba(0,0,0,.35); }
.feature-card:hover::before { opacity:1; }

.feature-card.c1::before { background:linear-gradient(90deg,#3b82f6,#06b6d4); }
.feature-card.c2::before { background:linear-gradient(90deg,#22c55e,#84cc16); }
.feature-card.c3::before { background:linear-gradient(90deg,#f59e0b,#f97316); }
.feature-card.c4::before { background:linear-gradient(90deg,#a855f7,#ec4899); }
.feature-card.c5::before { background:linear-gradient(90deg,#06b6d4,#3b82f6); }
.feature-card.c6::before { background:linear-gradient(90deg,#ef4444,#f97316); }

.feat-icon-wrap {
    width:52px; height:52px; border-radius:14px;
    display:flex; align-items:center; justify-content:center;
    font-size:24px; margin-bottom:18px;
}
.ic1{background:rgba(59,130,246,.15);}  .ic2{background:rgba(34,197,94,.15);}
.ic3{background:rgba(245,158,11,.15);}  .ic4{background:rgba(168,85,247,.15);}
.ic5{background:rgba(6,182,212,.15);}   .ic6{background:rgba(239,68,68,.15);}

.feature-card h3 { font-size:17px; font-weight:700; margin-bottom:10px; letter-spacing:-.3px; }
.feature-card p  { font-size:14px; color:var(--muted-2); line-height:1.65; }

/* ══════════════════════
   HOW IT WORKS
══════════════════════ */
.how-section {
    background: var(--navy-2);
    border-top: 1px solid rgba(255,255,255,.06);
    border-bottom: 1px solid rgba(255,255,255,.06);
    padding: 100px 40px;
}
.how-inner { max-width:1100px; margin:0 auto; }

.steps-grid {
    display:grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap:32px; margin-top:56px;
}
.step {
    display:flex; flex-direction:column; align-items:flex-start; gap:16px;
    padding:28px 24px;
    background:rgba(255,255,255,.03);
    border:1px solid rgba(255,255,255,.07);
    border-radius:16px;
    transition: all .25s;
    position:relative;
}
.step:hover { background:rgba(255,255,255,.06); transform:translateY(-3px); }
.step-num {
    width:40px; height:40px; border-radius:10px;
    background:linear-gradient(135deg,var(--blue),var(--green));
    display:flex; align-items:center; justify-content:center;
    font-size:16px; font-weight:800;
    box-shadow:0 4px 14px rgba(59,130,246,.35);
    flex-shrink:0;
}
.step h3 { font-size:16px; font-weight:700; margin-bottom:6px; }
.step p  { font-size:13.5px; color:var(--muted-2); line-height:1.6; }

/* connector arrow between steps */
.steps-grid .step:not(:last-child)::after {
    content:'→';
    position:absolute; right:-22px; top:50%;
    transform:translateY(-50%);
    color:var(--muted);
    font-size:18px; font-weight:700;
    display:none;
}

/* ══════════════════════
   CTA BANNER
══════════════════════ */
.cta-banner {
    margin: 0 40px 100px;
    background: linear-gradient(135deg, var(--navy-2) 0%, #0f2044 100%);
    border: 1px solid rgba(59,130,246,.2);
    border-radius: 24px;
    padding: 60px 40px;
    text-align:center;
    position:relative; overflow:hidden;
    max-width:1120px; margin-left:auto; margin-right:auto;
}
.cta-banner::before {
    content:'';
    position:absolute; top:-60px; right:-60px;
    width:280px; height:280px;
    background:rgba(59,130,246,.1); border-radius:50%;
    filter:blur(40px);
}
.cta-banner::after {
    content:'';
    position:absolute; bottom:-80px; left:-60px;
    width:240px; height:240px;
    background:rgba(34,197,94,.08); border-radius:50%;
    filter:blur(40px);
}
.cta-banner h2 {
    font-size:clamp(26px,4vw,42px); font-weight:800;
    letter-spacing:-1px; margin-bottom:14px;
    position:relative;
}
.cta-banner p {
    font-size:17px; color:var(--muted-2);
    margin-bottom:36px; line-height:1.65;
    position:relative;
}
.cta-banner .hero-cta { position:relative; }

/* ══════════════════════
   FOOTER
══════════════════════ */
.footer {
    border-top: 1px solid rgba(255,255,255,.07);
    padding: 32px 40px;
    display:flex; align-items:center; justify-content:space-between;
    flex-wrap:wrap; gap:16px;
}
.footer-brand { display:flex; align-items:center; gap:10px; }
.footer-brand-icon {
    width:30px; height:30px;
    background:linear-gradient(135deg,var(--blue),var(--green));
    border-radius:8px;
    display:flex; align-items:center; justify-content:center;
    font-size:14px;
}
.footer-brand-name { font-size:14px; font-weight:700; color:var(--muted-2); }
.footer-links { display:flex; gap:24px; }
.footer-links a { font-size:13px; color:var(--muted); text-decoration:none; transition:color .2s; }
.footer-links a:hover { color:var(--white); }
.footer-copy { font-size:12.5px; color:var(--muted); }

/* ══════════════════════
   SCROLL REVEAL
══════════════════════ */
.reveal { opacity:0; transform:translateY(28px); transition:opacity .7s ease, transform .7s ease; }
.reveal.visible { opacity:1; transform:translateY(0); }
.reveal-d1 { transition-delay:.1s; }
.reveal-d2 { transition-delay:.2s; }
.reveal-d3 { transition-delay:.3s; }
.reveal-d4 { transition-delay:.4s; }
.reveal-d5 { transition-delay:.5s; }
.reveal-d6 { transition-delay:.6s; }

/* ══════════════════════
   RESPONSIVE
══════════════════════ */
@media(max-width:900px){
    .navbar { padding:0 24px; }
    .hero   { padding:110px 24px 70px; }
    .section{ padding:70px 24px; }
    .how-section{ padding:70px 24px; }
    .cta-banner { margin:0 24px 70px; padding:44px 28px; }
    .footer { padding:28px 24px; }
    .stats-strip { gap:32px; }
}

@media(max-width:768px){
    /* show hamburger */
    .hamburger { display:flex; }
    .nav-links  { display:none; }

    .hero h1 { letter-spacing:-1.5px; }
    .hero-cta { flex-direction:column; align-items:center; }
    .cta-primary, .cta-secondary { width:100%; justify-content:center; }
    .stats-strip { gap:24px; }
    .stat-num { font-size:26px; }
    .section-sub { font-size:15px; }
    .steps-grid { gap:20px; }
    .footer { flex-direction:column; align-items:flex-start; gap:20px; }
    .footer-links { flex-wrap:wrap; gap:16px; }
}

@media(max-width:480px){
    .navbar { padding:0 18px; height:58px; }
    .hero   { padding:100px 18px 60px; }
    .section{ padding:56px 18px; }
    .how-section{ padding:56px 18px; }
    .cta-banner { margin:0 18px 56px; padding:36px 22px; }
    .footer { padding:24px 18px; }
    .brand-name { font-size:15px; }
    .features-grid { grid-template-columns:1fr; }
    .steps-grid    { grid-template-columns:1fr; }
}
    </style>
</head>
<body>

<!-- ══ NAVBAR ══════════════════════════════════════════════════════ -->
<nav class="navbar">
    <a href="index.jsp" class="brand">
        <div class="brand-icon">💳</div>
        <span class="brand-name">CardCompass</span>
    </a>

    <!-- Desktop nav -->
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/LoginPage.jsp"    class="btn-login">Login</a>
        <a href="RegisterPage.jsp" class="btn-register">Get Started Free</a>
    </div>

    <!-- Mobile hamburger -->
    <div class="hamburger" onclick="toggleMenu()" id="hamburger">
        <span></span><span></span><span></span>
    </div>
</nav>

<!-- Mobile menu -->
<div class="mobile-menu" id="mobileMenu">
    <a href="${pageContext.request.contextPath}/LoginPage.jsp"   class="btn-login">Login</a>
    <a href="RegisterPage.jsp" class="btn-register">Get Started Free →</a>
</div>

<!-- ══ HERO ══════════════════════════════════════════════════════════ -->
<section class="hero">
    <!-- Background orbs -->
    <div class="orb orb-1"></div>
    <div class="orb orb-2"></div>
    <div class="orb orb-3"></div>

    <div class="hero-inner">
        <div class="hero-badge">✦ Free to use · No credit card required</div>

        <h1>
            Manage Your<br>
            <span class="accent-blue">Credit Cards</span> &
            <span class="accent-green">Spending</span><br>
            All In One Place
        </h1>

        <p class="hero-sub">
            Track transactions, scan bills with OCR, view category-wise spending,
            and get auto-generated monthly PDF reports — all in one smart dashboard.
        </p>

        <div class="hero-cta">
            <a href="RegisterPage.jsp" class="cta-primary">🚀 Get Started Free</a>
            <a href="${pageContext.request.contextPath}/LoginPage.jsp"    class="cta-secondary">Sign In →</a>
        </div>

        <!-- Stats -->
        <div class="stats-strip">
            <div class="stat-item">
                <div class="stat-num">100%</div>
                <div class="stat-label">Free to Use</div>
            </div>
            <div class="stat-item">
                <div class="stat-num">OCR</div>
                <div class="stat-label">Bill Scanning</div>
            </div>
            <div class="stat-item">
                <div class="stat-num">Auto</div>
                <div class="stat-label">Monthly Reports</div>
            </div>
            <div class="stat-item">
                <div class="stat-num">Multi</div>
                <div class="stat-label">Card Support</div>
            </div>
        </div>
    </div>
</section>

<!-- ══ FEATURES ══════════════════════════════════════════════════════ -->
<section class="section">
    <div class="reveal">
        <div class="section-tag">✦ Features</div>
        <h2 class="section-title">Everything you need to<br>control your spending</h2>
        <p class="section-sub">Powerful tools to track, analyze, and report on every rupee you spend.</p>
    </div>

    <div class="features-grid">
        <div class="feature-card c1 reveal reveal-d1">
            <div class="feat-icon-wrap ic1">📷</div>
            <h3>Bill Scanning (OCR)</h3>
            <p>Upload any bill photo — our OCR engine automatically reads the amount, merchant, and date. No manual typing needed.</p>
        </div>
        <div class="feature-card c2 reveal reveal-d2">
            <div class="feat-icon-wrap ic2">📊</div>
            <h3>Spending Analytics</h3>
            <p>View category-wise and card-wise spending breakdowns. Know exactly where your money goes every single month.</p>
        </div>
        <div class="feature-card c3 reveal reveal-d3">
            <div class="feat-icon-wrap ic3">💳</div>
            <h3>Multi-Card Support</h3>
            <p>Add as many credit cards as you own. Track transactions per card with a clean visual card UI.</p>
        </div>
        <div class="feature-card c4 reveal reveal-d4">
            <div class="feat-icon-wrap ic4">📧</div>
            <h3>Auto PDF Reports</h3>
            <p>Get monthly PDF reports emailed automatically on the last day of every month. Download instantly with one click.</p>
        </div>
        <div class="feature-card c5 reveal reveal-d5">
            <div class="feat-icon-wrap ic5">📋</div>
            <h3>Transaction History</h3>
            <p>Full searchable history of every transaction across all your cards, with smart category filters.</p>
        </div>
        <div class="feature-card c6 reveal reveal-d6">
            <div class="feat-icon-wrap ic6">🔒</div>
            <h3>Secure & Private</h3>
            <p>Your financial data stays yours. No third-party sharing. Session-protected access on every page.</p>
        </div>
    </div>
</section>

<!-- ══ HOW IT WORKS ════════════════════════════════════════════════ -->
<section class="how-section">
    <div class="how-inner">
        <div class="reveal">
            <div class="section-tag">✦ How It Works</div>
            <h2 class="section-title">Up and running in minutes</h2>
            <p class="section-sub">Four simple steps to take full control of your credit card spending.</p>
        </div>

        <div class="steps-grid">
            <div class="step reveal reveal-d1">
                <div class="step-num">1</div>
                <div>
                    <h3>Create Your Account</h3>
                    <p>Register in seconds with your name and email. No credit card needed to sign up.</p>
                </div>
            </div>
            <div class="step reveal reveal-d2">
                <div class="step-num">2</div>
                <div>
                    <h3>Add Your Cards</h3>
                    <p>Add your credit cards by name and last 4 digits. Fully supports multiple cards.</p>
                </div>
            </div>
            <div class="step reveal reveal-d3">
                <div class="step-num">3</div>
                <div>
                    <h3>Log Transactions</h3>
                    <p>Add transactions manually or scan a bill photo with our built-in OCR scanner.</p>
                </div>
            </div>
            <div class="step reveal reveal-d4">
                <div class="step-num">4</div>
                <div>
                    <h3>Get Reports</h3>
                    <p>View spending breakdowns instantly. Download or receive monthly PDFs by email automatically.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ══ CTA BANNER ══════════════════════════════════════════════════ -->
<div class="cta-banner reveal" style="margin-top:100px;">
    <h2>Ready to take control of<br>your credit card spending?</h2>
    <p>Join CardManager today — it's completely free.</p>
    <div class="hero-cta">
        <a href="RegisterPage.jsp" class="cta-primary">🚀 Create Free Account</a>
        <a href="${pageContext.request.contextPath}/LoginPage.jsp"   class="cta-secondary">Already have an account?</a>
    </div>
</div>

<!-- ══ FOOTER ══════════════════════════════════════════════════════ -->
<footer class="footer">
    <div class="footer-brand">
        <div class="footer-brand-icon">💳</div>
        <span class="footer-brand-name">CardManager</span>
    </div>
    <div class="footer-links">
        <a href="${pageContext.request.contextPath}/LoginPage.jsp">Login</a>
        <a href="RegisterPage.jsp">Register</a>
        <a href="Dashboard.jsp">Dashboard</a>
    </div>
    <div class="footer-copy">© 2026 CardManager. All rights reserved.</div>
</footer>

<!-- ══ JS: scroll reveal + hamburger ══════════════════════════════ -->
<script>
    // Scroll reveal
    var reveals = document.querySelectorAll('.reveal');
    var observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.12 });
    reveals.forEach(function(el) { observer.observe(el); });

    // Hamburger menu
    function toggleMenu() {
        var menu = document.getElementById('mobileMenu');
        var ham  = document.getElementById('hamburger');
        menu.classList.toggle('open');
        // animate hamburger to X
        var spans = ham.querySelectorAll('span');
        if (menu.classList.contains('open')) {
            spans[0].style.transform = 'translateY(7px) rotate(45deg)';
            spans[1].style.opacity   = '0';
            spans[2].style.transform = 'translateY(-7px) rotate(-45deg)';
        } else {
            spans[0].style.transform = '';
            spans[1].style.opacity   = '1';
            spans[2].style.transform = '';
        }
    }

    // Close mobile menu on outside click
    document.addEventListener('click', function(e) {
        var menu = document.getElementById('mobileMenu');
        var ham  = document.getElementById('hamburger');
        if (menu.classList.contains('open') &&
            !menu.contains(e.target) && !ham.contains(e.target)) {
            toggleMenu();
        }
    });
</script>
</body>
</html>
