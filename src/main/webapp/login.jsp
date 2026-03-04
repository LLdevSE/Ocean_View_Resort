<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    // If already logged in, redirect to appropriate dashboard
    HttpSession existingSession = request.getSession(false);
    if (existingSession != null && existingSession.getAttribute("user") != null) {
        String role = (String) existingSession.getAttribute("userRole");
        if ("ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/reservations");
        }
        return;
    }

    String errorMsg   = (String) request.getAttribute("errorMsg");
    String successMsg = (String) request.getAttribute("successMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login &mdash; Ocean View Resort</title>
    <meta name="description" content="Secure staff and admin portal for Ocean View Resort Hotel Reservation System." />

    <!-- Bootstrap 5 -->
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
    <!-- Bootstrap Icons -->
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css" />

    <style>
        /* ---- Login Page Specific ---- */
        .login-page {
            min-height: 100vh;
            display: grid;
            grid-template-columns: 1fr 1fr;
            overflow: hidden;
        }

        /* ---- Left Panel (Branding) ---- */
        .login-left {
            position: relative;
            background: linear-gradient(160deg, #0b1e30 0%, #0a4060 60%, #0b6080 100%);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 60px 50px;
            overflow: hidden;
        }

        .login-left::before {
            content: '';
            position: absolute;
            inset: 0;
            background:
                radial-gradient(circle at 20% 80%, rgba(26, 143, 176, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(10, 107, 138, 0.4) 0%, transparent 50%);
        }

        /* Animated wave circles */
        .wave-circle {
            position: absolute;
            border-radius: 50%;
            border: 1px solid rgba(255, 255, 255, 0.05);
            animation: expandCircle 6s ease-in-out infinite;
        }

        .wave-circle:nth-child(1) { width: 200px; height: 200px; bottom: -50px; left: -50px; animation-delay: 0s; }
        .wave-circle:nth-child(2) { width: 350px; height: 350px; bottom: -100px; left: -100px; animation-delay: 1s; }
        .wave-circle:nth-child(3) { width: 500px; height: 500px; top: -150px; right: -150px; animation-delay: 2s; }

        @keyframes expandCircle {
            0%, 100% { transform: scale(1); opacity: 0.3; }
            50% { transform: scale(1.05); opacity: 0.1; }
        }

        .brand-content {
            position: relative;
            z-index: 2;
            text-align: center;
        }

        .brand-logo-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, var(--primary-light), var(--primary-dark));
            border-radius: 22px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            margin: 0 auto 24px;
            animation: pulse-glow 3s ease-in-out infinite;
            box-shadow: 0 0 40px rgba(26, 143, 176, 0.5);
        }

        .brand-name {
            font-family: var(--font-heading);
            font-size: 2.4rem;
            font-weight: 700;
            color: #fff;
            margin-bottom: 8px;
            line-height: 1.2;
        }

        .brand-name span {
            color: var(--accent);
        }

        .brand-tagline {
            font-size: 0.85rem;
            color: rgba(255,255,255,0.6);
            text-transform: uppercase;
            letter-spacing: 3px;
            margin-bottom: 40px;
        }

        /* Feature list */
        .feature-list {
            list-style: none;
            padding: 0;
            margin: 0;
            text-align: left;
        }

        .feature-list li {
            display: flex;
            align-items: center;
            gap: 12px;
            color: rgba(255,255,255,0.75);
            font-size: 0.88rem;
            margin-bottom: 14px;
        }

        .feature-list .feat-icon {
            width: 32px;
            height: 32px;
            background: rgba(26, 143, 176, 0.2);
            border: 1px solid rgba(26, 143, 176, 0.3);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-light);
            font-size: 1rem;
            flex-shrink: 0;
        }

        /* Floating card visual */
        .hotel-visual {
            position: relative;
            margin-top: 40px;
            width: 280px;
            animation: float 5s ease-in-out infinite;
        }

        .hotel-card-visual {
            background: rgba(255,255,255,0.07);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 16px;
            padding: 20px;
        }

        .visual-row {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 14px;
        }

        .visual-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--accent), #ff8c42);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.85rem;
            font-weight: 700;
            flex-shrink: 0;
        }

        .visual-text .vt-name { font-size: 0.82rem; font-weight: 600; color: #fff; }
        .visual-text .vt-info { font-size: 0.72rem; color: rgba(255,255,255,0.5); }

        .visual-stat-bar {
            height: 6px;
            background: rgba(255,255,255,0.1);
            border-radius: 3px;
            overflow: hidden;
            margin-bottom: 6px;
        }

        .visual-stat-fill {
            height: 100%;
            border-radius: 3px;
            background: linear-gradient(90deg, var(--primary-light), var(--accent));
            animation: barFill 2s ease-in-out infinite alternate;
        }

        @keyframes barFill {
            from { width: 55%; }
            to { width: 80%; }
        }

        .visual-mini-stats {
            display: flex;
            gap: 10px;
            margin-top: 14px;
        }

        .vms-item {
            flex: 1;
            background: rgba(255,255,255,0.06);
            border-radius: 10px;
            padding: 10px;
            text-align: center;
        }

        .vms-item .vms-val {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--accent);
        }

        .vms-item .vms-lbl {
            font-size: 0.65rem;
            color: rgba(255,255,255,0.45);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* ---- Right Panel (Form) ---- */
        .login-right {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 50px;
            background: #0d1b2a;
        }

        .login-form-wrapper {
            width: 100%;
            max-width: 400px;
        }

        .form-header {
            margin-bottom: 36px;
        }

        .form-header .welcome-text {
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: var(--primary-light);
            margin-bottom: 8px;
        }

        .form-header h1 {
            font-family: var(--font-heading);
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-white);
            margin-bottom: 8px;
        }

        .form-header p {
            font-size: 0.88rem;
            color: var(--text-muted);
        }

        .divider {
            height: 1px;
            background: var(--border-glass);
            margin: 28px 0;
            position: relative;
        }

        .divider::after {
            content: 'SECURE ACCESS';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #0d1b2a;
            padding: 0 12px;
            font-size: 0.65rem;
            font-weight: 700;
            letter-spacing: 2px;
            color: var(--text-muted);
        }

        .show-password-toggle {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--text-muted);
            cursor: pointer;
            font-size: 1rem;
            padding: 4px;
            margin-top: 12px;
            transition: color 0.2s;
        }

        .show-password-toggle:hover {
            color: var(--primary-light);
        }

        .login-footer-note {
            text-align: center;
            margin-top: 28px;
            font-size: 0.78rem;
            color: var(--text-muted);
        }

        .login-footer-note i {
            color: var(--primary-light);
            margin-right: 4px;
        }

        /* ---- Responsive ---- */
        @media (max-width: 900px) {
            .login-page {
                grid-template-columns: 1fr;
            }

            .login-left {
                display: none;
            }

            .login-right {
                padding: 40px 24px;
                background: var(--bg-dark);
            }
        }

        /* Loading state */
        .btn-primary-custom.loading {
            pointer-events: none;
            opacity: 0.75;
        }

        .btn-primary-custom .spinner {
            display: none;
            width: 16px;
            height: 16px;
            border: 2px solid rgba(255,255,255,0.4);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin 0.7s linear infinite;
            margin-right: 8px;
        }

        .btn-primary-custom.loading .spinner { display: inline-block; }
        .btn-primary-custom.loading .btn-text { display: none; }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>

<div class="login-page">

    <!-- ===== LEFT BRANDING PANEL ===== -->
    <div class="login-left">
        <div class="wave-circle"></div>
        <div class="wave-circle"></div>
        <div class="wave-circle"></div>

        <div class="brand-content">
            <!-- Logo -->
            <div class="brand-logo-icon">
                <i class="bi bi-building" style="color:#fff;"></i>
            </div>
            <h2 class="brand-name">Ocean View<br><span>Resort</span></h2>
            <p class="brand-tagline">Hotel Management Portal</p>

            <!-- Feature highlights -->
            <ul class="feature-list">
                <li>
                    <div class="feat-icon"><i class="bi bi-calendar-check"></i></div>
                    Full Reservation Management (CRUD)
                </li>
                <li>
                    <div class="feat-icon"><i class="bi bi-people"></i></div>
                    Role-Based Staff &amp; Admin Control
                </li>
                <li>
                    <div class="feat-icon"><i class="bi bi-receipt"></i></div>
                    Automated Billing &amp; PDF Invoices
                </li>
                <li>
                    <div class="feat-icon"><i class="bi bi-shield-lock"></i></div>
                    Secure Session &amp; Filter-Based RBAC
                </li>
            </ul>

            <!-- Floating visual card -->
            <div class="hotel-visual">
                <div class="hotel-card-visual">
                    <div class="visual-row">
                        <div class="visual-avatar">AK</div>
                        <div class="visual-text">
                            <div class="vt-name">Admin Dashboard</div>
                            <div class="vt-info">Ocean View Resort &bull; Live</div>
                        </div>
                    </div>

                    <div class="visual-stat-bar">
                        <div class="visual-stat-fill"></div>
                    </div>
                    <div style="font-size:0.7rem; color:rgba(255,255,255,0.45); margin-bottom:4px;">Room Occupancy</div>

                    <div class="visual-mini-stats">
                        <div class="vms-item">
                            <div class="vms-val">24</div>
                            <div class="vms-lbl">Rooms</div>
                        </div>
                        <div class="vms-item">
                            <div class="vms-val">18</div>
                            <div class="vms-lbl">Booked</div>
                        </div>
                        <div class="vms-item">
                            <div class="vms-val">6</div>
                            <div class="vms-lbl">Free</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ===== RIGHT FORM PANEL ===== -->
    <div class="login-right">
        <div class="login-form-wrapper">

            <div class="form-header">
                <div class="welcome-text">Welcome Back</div>
                <h1>Sign in to your<br>account</h1>
                <p>Enter your credentials to access the management portal.</p>
            </div>

            <!-- Flash Messages -->
            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
            <div class="alert-custom alert-error" id="alertBox">
                <i class="bi bi-exclamation-circle-fill"></i>
                <%= errorMsg %>
            </div>
            <% } %>
            <% if (successMsg != null && !successMsg.isEmpty()) { %>
            <div class="alert-custom alert-success" id="alertBox">
                <i class="bi bi-check-circle-fill"></i>
                <%= successMsg %>
            </div>
            <% } %>

            <div class="divider"></div>

            <!-- Login Form -->
            <form id="loginForm"
                  action="<%= request.getContextPath() %>/login"
                  method="post"
                  novalidate>

                <!-- Username -->
                <div class="form-group">
                    <label for="username">
                        <i class="bi bi-person" style="margin-right:4px;"></i> Username
                    </label>
                    <div class="position-relative">
                        <i class="bi bi-person-fill input-icon"></i>
                        <input
                            type="text"
                            id="username"
                            name="username"
                            class="form-input"
                            placeholder="e.g. admin"
                            required
                            autocomplete="username"
                            value=""
                        />
                    </div>
                </div>

                <!-- Password -->
                <div class="form-group">
                    <label for="password">
                        <i class="bi bi-lock" style="margin-right:4px;"></i> Password
                    </label>
                    <div class="position-relative">
                        <i class="bi bi-lock-fill input-icon"></i>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            class="form-input"
                            placeholder="Enter your password"
                            required
                            autocomplete="current-password"
                        />
                        <button type="button"
                                class="show-password-toggle"
                                id="togglePassword"
                                aria-label="Toggle password visibility">
                            <i class="bi bi-eye" id="eyeIcon"></i>
                        </button>
                    </div>
                </div>

                <!-- Remember me (UI only for visual completeness) -->
                <div class="d-flex align-items-center justify-content-between mb-4">
                    <div class="form-check" style="margin:0;">
                        <input class="form-check-input" type="checkbox" id="rememberMe"
                               style="background-color: rgba(255,255,255,0.1); border-color: var(--border-glass);" />
                        <label class="form-check-label" for="rememberMe"
                               style="font-size:0.82rem; color: var(--text-muted); cursor:pointer;">
                            Remember me
                        </label>
                    </div>
                </div>

                <!-- Submit -->
                <button type="submit" class="btn-primary-custom" id="loginBtn">
                    <span class="spinner" id="btnSpinner"></span>
                    <span class="btn-text">
                        <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
                    </span>
                </button>

            </form>

            <div class="login-footer-note">
                <i class="bi bi-shield-check"></i>
                All activity is logged and monitored.
                &nbsp;&bull;&nbsp;
                &copy; 2024 Ocean View Resort
            </div>

        </div>
    </div>

</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // -----------------------------------------------
    // Toggle password visibility
    // -----------------------------------------------
    const toggleBtn  = document.getElementById('togglePassword');
    const passInput  = document.getElementById('password');
    const eyeIcon    = document.getElementById('eyeIcon');

    toggleBtn.addEventListener('click', () => {
        const isVisible = passInput.type === 'text';
        passInput.type  = isVisible ? 'password' : 'text';
        eyeIcon.className = isVisible ? 'bi bi-eye' : 'bi bi-eye-slash';
    });

    // -----------------------------------------------
    // Form submission with loading state
    // -----------------------------------------------
    const loginForm = document.getElementById('loginForm');
    const loginBtn  = document.getElementById('loginBtn');

    loginForm.addEventListener('submit', (e) => {
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value.trim();

        if (!username || !password) {
            e.preventDefault();
            showInlineError('Please fill in both username and password.');
            return;
        }

        // Show loading state
        loginBtn.classList.add('loading');
    });

    // -----------------------------------------------
    // Inline client-side error
    // -----------------------------------------------
    function showInlineError(message) {
        let existing = document.getElementById('clientAlert');
        if (existing) existing.remove();

        const div = document.createElement('div');
        div.id = 'clientAlert';
        div.className = 'alert-custom alert-error';
        div.innerHTML = `<i class="bi bi-exclamation-circle-fill"></i> ${message}`;
        loginForm.insertBefore(div, loginForm.firstChild);
    }

    // -----------------------------------------------
    // Auto-dismiss flash alerts after 5 seconds
    // -----------------------------------------------
    const alertBox = document.getElementById('alertBox');
    if (alertBox) {
        setTimeout(() => {
            alertBox.style.transition = 'opacity 0.5s';
            alertBox.style.opacity = '0';
            setTimeout(() => alertBox.remove(), 500);
        }, 5000);
    }

    // -----------------------------------------------
    // Input focus enhancement
    // -----------------------------------------------
    document.querySelectorAll('.form-input').forEach(input => {
        input.addEventListener('focus', () => {
            input.closest('.form-group').querySelector('.input-icon').style.color = 'var(--accent)';
        });
        input.addEventListener('blur', () => {
            input.closest('.form-group').querySelector('.input-icon').style.color = 'var(--primary-light)';
        });
    });
</script>

</body>
</html>
