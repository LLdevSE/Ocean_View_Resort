<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.oceanview.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String username  = currentUser != null ? currentUser.getUsername() : "Staff";
    String initial   = currentUser != null ? currentUser.getInitial()  : "S";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Profile &mdash; Staff Portal</title>
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />

    <style>
        .profile-container {
            max-width: 800px;
            margin: 0 auto;
        }
        
        .profile-header-card {
            display: flex;
            align-items: center;
            gap: 24px;
            padding: 30px;
            margin-bottom: 30px;
            background: linear-gradient(145deg, rgba(26,143,176,0.1) 0%, rgba(11,30,48,0.5) 100%);
            border: 1px solid var(--border-glass);
            border-radius: var(--radius-lg);
            position: relative;
            overflow: hidden;
        }
        
        .profile-header-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; border-top: 3px solid var(--primary-light);
        }

        .profile-avatar-xl {
            width: 100px;
            height: 100px;
            border-radius: 20px;
            background: linear-gradient(135deg, var(--primary-light), var(--primary-dark));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.8rem;
            font-weight: 700;
            color: #fff;
            box-shadow: 0 10px 25px rgba(26,143,176,0.4);
            flex-shrink: 0;
        }

        .profile-title {
            font-family: var(--font-heading);
            font-size: 1.8rem;
            color: var(--text-white);
            margin-bottom: 5px;
        }

        .profile-role-badge {
            display: inline-block;
            background: rgba(39,174,96,0.2);
            color: #6fcf97;
            border: 1px solid rgba(39,174,96,0.4);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        .profile-id {
            font-family: monospace;
            font-size: 1rem;
            color: var(--primary-light);
            background: rgba(0,0,0,0.2);
            padding: 4px 10px;
            border-radius: 6px;
            margin-top: 10px;
            display: inline-block;
        }

        .settings-card {
            padding: 30px;
        }

        .settings-title {
            font-family: var(--font-heading);
            font-size: 1.3rem;
            color: var(--text-white);
            margin-bottom: 24px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border-glass);
        }

        .readonly-field {
            background: rgba(255,255,255,0.02) !important;
            color: var(--text-muted) !important;
            cursor: not-allowed;
            border-color: rgba(255,255,255,0.08) !important;
        }

        /* Password strength meter */
        .strength-bar {
            height: 4px;
            background: rgba(255,255,255,0.1);
            border-radius: 2px;
            margin-top: 8px;
            overflow: hidden;
        }
        .strength-fill {
            height: 100%;
            border-radius: 2px;
            transition: width 0.3s, background 0.3s;
            width: 0%;
            background: var(--danger);
        }
        .strength-label {
            font-size: 0.75rem;
            margin-top: 4px;
            color: var(--text-muted);
            text-align: right;
        }

        @media (max-width: 768px) {
            .profile-header-card {
                flex-direction: column;
                text-align: center;
                padding: 30px 20px;
            }
        }
        
        .hamburger-btn {
            display: none;
            background: none;
            border: 1px solid var(--border-glass);
            color: var(--text-white);
            border-radius: var(--radius-sm);
            padding: 6px 10px;
            cursor: pointer;
            font-size: 1.1rem;
            align-items: center;
        }

        @media (max-width: 768px) {
            .hamburger-btn { display: flex; }
        }
    </style>
</head>
<body>
<div class="app-wrapper">

    <!-- ===========================
         SIDEBAR (SHARED)
    =========================== -->
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp">
        <jsp:param name="activePage" value="staff-profile"/>
    </jsp:include>

    <!-- ===========================
         MAIN CONTENT
    =========================== -->
    <main class="main-content">

        <!-- Top Bar -->
        <div class="top-bar">
            <div>
                <button class="hamburger-btn" id="hamburgerBtn" aria-label="Toggle Sidebar">
                    <i class="bi bi-list"></i>
                </button>
            </div>
            <div>
                <div class="page-title">My Profile</div>
                <div class="page-subtitle">Manage your personal information and security</div>
            </div>
            <div></div> <!-- Empty div for flexbox spacing -->
        </div>

        <div class="content-area">
            
            <div class="profile-container">
                <!-- Flash Messages -->
                <c:if test="${not empty flashSuccess}">
                    <div class="alert-custom alert-success mb-4" id="flashMsg">
                        <i class="bi bi-check-circle-fill"></i> ${flashSuccess}
                    </div>
                </c:if>
                <c:if test="${not empty flashError}">
                    <div class="alert-custom alert-error mb-4" id="flashMsg">
                        <i class="bi bi-exclamation-circle-fill"></i> ${flashError}
                    </div>
                </c:if>

                <!-- Profile Header -->
                <div class="profile-header-card">
                    <div class="profile-avatar-xl">
                        ${profileUser.initial}
                    </div>
                    <div>
                        <div class="profile-title">${profileUser.username}</div>
                        <div class="profile-role-badge">Staff Member</div>
                        <div style="margin-top:8px;">
                            <span class="profile-id"><i class="bi bi-fingerprint me-2"></i>${profileUser.staffId}</span>
                        </div>
                    </div>
                </div>

                <!-- Settings Form -->
                <div class="glass-card settings-card">
                    <h3 class="settings-title"><i class="bi bi-gear-fill me-2" style="color:var(--primary-light);"></i>Account Settings</h3>
                    
                    <form action="${pageContext.request.contextPath}/staff/profile" method="post" id="profileForm">
                        <input type="hidden" name="action" value="update" />

                        <div class="row g-4 mb-4">
                            <!-- Username (Readonly) -->
                            <div class="col-md-6 form-group">
                                <label>Username (Cannot be changed)</label>
                                <div style="position:relative;">
                                    <i class="bi bi-person-fill input-icon" style="color:var(--text-muted);"></i>
                                    <input type="text" class="form-input readonly-field" value="${profileUser.username}" readonly />
                                </div>
                            </div>
                            
                            <!-- Staff ID (Readonly) -->
                            <div class="col-md-6 form-group">
                                <label>Staff ID (Auto-assigned)</label>
                                <div style="position:relative;">
                                    <i class="bi bi-hash input-icon" style="color:var(--text-muted);"></i>
                                    <input type="text" class="form-input readonly-field" value="${profileUser.staffId}" readonly />
                                </div>
                            </div>
                        </div>

                        <div class="row g-4 mb-4">
                            <!-- Mobile -->
                            <div class="col-md-6 form-group">
                                <label for="mobileNum">Mobile Number</label>
                                <div style="position:relative;">
                                    <i class="bi bi-telephone-fill input-icon"></i>
                                    <input type="text" id="mobileNum" name="mobileNum" class="form-input" 
                                           value="${profileUser.mobileNum}" placeholder="e.g. 0771234567" />
                                </div>
                            </div>
                            
                            <!-- Address -->
                            <div class="col-md-6 form-group">
                                <label for="address">Address</label>
                                <div style="position:relative;">
                                    <i class="bi bi-geo-alt-fill input-icon"></i>
                                    <input type="text" id="address" name="address" class="form-input" 
                                           value="${profileUser.address}" placeholder="Your current address" />
                                </div>
                            </div>
                        </div>

                        <!-- Change Password Section -->
                        <div class="p-3 mb-4" style="background:rgba(0,0,0,0.2); border-radius:8px; border:1px dashed var(--border-glass);">
                            <h4 style="font-size:1rem; color:var(--text-white); margin-bottom:15px;">
                                <i class="bi bi-shield-lock-fill me-2" style="color:var(--accent);"></i>Security
                            </h4>
                            
                            <div class="form-group mb-0">
                                <label for="password">Change Password <span style="font-weight:400; color:var(--text-muted); font-size:0.8rem;">(Leave blank to keep current)</span></label>
                                <div style="position:relative;">
                                    <i class="bi bi-lock-fill input-icon"></i>
                                    <input type="password" id="password" name="password" class="form-input" 
                                           placeholder="Enter new password" oninput="checkStrength(this.value)" />
                                    <button type="button" id="togglePwd" 
                                            style="position:absolute; right:14px; top:50%; transform:translateY(-50%); 
                                                   background:none; border:none; color:var(--text-muted); cursor:pointer; margin-top:12px;">
                                        <i class="bi bi-eye" id="eyeIcon"></i>
                                    </button>
                                </div>
                                
                                <div class="strength-bar">
                                    <div class="strength-fill" id="strengthFill"></div>
                                </div>
                                <div class="strength-label" id="strengthLabel"></div>
                            </div>
                        </div>

                        <div style="display:flex; justify-content:flex-end;">
                            <button type="submit" class="btn-primary-custom" style="padding:12px 30px; font-size:1rem;">
                                <i class="bi bi-save me-2"></i> Save Profile
                            </button>
                        </div>
                    </form>
                </div>
            </div><!-- /profile-container -->

        </div><!-- /content-area -->
    </main>
</div>


// Password toggle
document.getElementById('togglePwd').addEventListener('click', () => {
    const pwd = document.getElementById('password');
    const ico = document.getElementById('eyeIcon');
    const isVisible = pwd.type === 'text';
    pwd.type = isVisible ? 'password' : 'text';
    ico.className = isVisible ? 'bi bi-eye' : 'bi bi-eye-slash';
});

// Password strength meter
function checkStrength(pwd) {
    const fill  = document.getElementById('strengthFill');
    const label = document.getElementById('strengthLabel');
    let strength = 0;
    
    if (pwd.length >= 6)  strength++;
    if (pwd.length >= 10) strength++;
    if (/[A-Z]/.test(pwd) && /[0-9]/.test(pwd)) strength++;
    if (/[^a-zA-Z0-9]/.test(pwd)) strength++;

    const levels = [
        { pct: '25%', color: '#e74c3c', text: 'Weak' },
        { pct: '50%', color: '#f39c12', text: 'Fair' },
        { pct: '75%', color: '#3498db', text: 'Good' },
        { pct: '100%', color: '#27ae60', text: 'Strong' },
    ];

    const lvl = levels[Math.max(0, strength - 1)] || levels[0];
    
    if (pwd.length === 0) {
        fill.style.width = '0%';
        label.textContent = '';
    } else {
        fill.style.width      = lvl.pct;
        fill.style.background = lvl.color;
        label.textContent     = lvl.text;
        label.style.color     = lvl.color;
    }
}

// Flash Message Auto-dismiss
const flashMsg = document.getElementById('flashMsg');
if (flashMsg) {
    setTimeout(() => {
        flashMsg.style.transition = 'opacity 0.5s';
        flashMsg.style.opacity = '0';
        setTimeout(() => flashMsg.remove(), 500);
    }, 4000);
}


</body>
</html>
