<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.oceanview.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String username  = currentUser != null ? currentUser.getUsername() : "Admin";
    String initial   = currentUser != null ? currentUser.getInitial()  : "A";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Staff Management &mdash; Ocean View Resort</title>
    <meta name="description" content="Manage staff members for Ocean View Resort." />

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />

    <style>
        /* ---- Staff Card Grid ---- */
        .staff-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .staff-card {
            padding: 24px;
            border-radius: var(--radius-md);
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }

        .staff-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            background: linear-gradient(90deg, var(--primary-light), var(--accent));
        }

        .staff-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 40px rgba(0,0,0,0.4);
        }

        .staff-card-header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 18px;
        }

        .staff-avatar-lg {
            width: 54px;
            height: 54px;
            border-radius: 14px;
            background: linear-gradient(135deg, var(--primary-light), var(--primary-dark));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            font-weight: 700;
            flex-shrink: 0;
            box-shadow: 0 4px 15px rgba(10,107,138,0.4);
        }

        .staff-info .staff-name {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-white);
            margin-bottom: 3px;
        }

        .staff-info .staff-id-badge {
            font-family: monospace;
            font-size: 0.75rem;
            background: rgba(26,143,176,0.15);
            color: var(--primary-light);
            padding: 2px 8px;
            border-radius: 4px;
            border: 1px solid rgba(26,143,176,0.3);
        }

        .staff-detail-row {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            margin-bottom: 10px;
            font-size: 0.85rem;
            color: var(--text-light);
        }

        .staff-detail-row i {
            color: var(--text-muted);
            width: 16px;
            flex-shrink: 0;
            margin-top: 2px;
        }

        .staff-card-actions {
            display: flex;
            gap: 8px;
            margin-top: 18px;
            padding-top: 16px;
            border-top: 1px solid var(--border-glass);
        }

        /* ---- Search bar ---- */
        .filter-bar {
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
            margin-bottom: 22px;
        }

        .search-wrap {
            position: relative;
            flex: 1;
            min-width: 220px;
        }

        .search-wrap i {
            position: absolute;
            left: 13px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
        }

        .search-input {
            width: 100%;
            background: rgba(255,255,255,0.06);
            border: 1px solid var(--border-glass);
            border-radius: var(--radius-sm);
            padding: 10px 14px 10px 38px;
            color: var(--text-white);
            font-family: var(--font-main);
            font-size: 0.88rem;
            outline: none;
            transition: var(--transition);
        }

        .search-input:focus {
            border-color: var(--primary-light);
            background: rgba(26,143,176,0.08);
        }

        .search-input::placeholder { color: var(--text-muted); }

        /* ---- View toggle ---- */
        .view-toggle {
            display: flex;
            gap: 6px;
        }

        .view-btn {
            background: rgba(255,255,255,0.06);
            border: 1px solid var(--border-glass);
            color: var(--text-muted);
            width: 36px;
            height: 36px;
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: var(--transition);
            font-size: 0.9rem;
        }

        .view-btn.active, .view-btn:hover {
            background: rgba(26,143,176,0.2);
            color: var(--primary-light);
            border-color: rgba(26,143,176,0.4);
        }

        /* ---- Password strength ---- */
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
            font-size: 0.7rem;
            margin-top: 4px;
            color: var(--text-muted);
        }

        /* ---- Empty state ---- */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            grid-column: 1 / -1;
        }

        .empty-icon {
            font-size: 3.5rem;
            color: var(--text-muted);
            margin-bottom: 16px;
            opacity: 0.4;
        }

        /* ---- Table view (hidden by default) ---- */
        #tableView { display: none; }

        /* ---- Hamburger ---- */
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
            .staff-grid    { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<div class="app-wrapper">

    <!-- ===========================
         SIDEBAR
    =========================== -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-logo">
            <div class="logo-icon"><i class="bi bi-building" style="color:#fff;"></i></div>
            <div class="resort-name">Ocean View<br><span>Resort</span></div>
            <div class="resort-tagline">Management Portal</div>
        </div>

        <nav class="sidebar-nav">
            <div class="nav-section-title">Main Menu</div>

            <a href="${pageContext.request.contextPath}/admin/reservations" class="nav-item">
                <i class="bi bi-calendar2-check"></i> Reservations
            </a>

            <a href="${pageContext.request.contextPath}/admin/staff" class="nav-item active">
                <i class="bi bi-people"></i> Staff Management
            </a>

            <div class="nav-section-title">Billing</div>

            <a href="${pageContext.request.contextPath}/admin/billing" class="nav-item">
                <i class="bi bi-receipt"></i> Billing &amp; Invoices
            </a>
        </nav>

        <div class="sidebar-footer">
            <div class="user-info-sidebar">
                <div class="user-avatar"><%= initial %></div>
                <div class="user-info-text">
                    <div class="user-name"><%= username %></div>
                    <div class="user-role">Administrator</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="bi bi-box-arrow-left"></i> Sign Out
            </a>
        </div>
    </aside>

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
                <div class="page-title">Staff Management</div>
                <div class="page-subtitle">Manage your hotel staff members</div>
            </div>
            <div>
                <button class="btn-accent" onclick="openCreateModal()" id="btnNewStaff">
                    <i class="bi bi-person-plus-fill me-1"></i> Add Staff
                </button>
            </div>
        </div>

        <div class="content-area">

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

            <!-- ---- Stats ---- -->
            <div class="stats-grid" style="max-width:600px;">
                <div class="stat-card glass-card purple">
                    <div class="stat-icon"><i class="bi bi-people-fill"></i></div>
                    <div class="stat-value">${totalStaff}</div>
                    <div class="stat-label">Total Staff</div>
                </div>
                <div class="stat-card glass-card blue">
                    <div class="stat-icon"><i class="bi bi-shield-check"></i></div>
                    <div class="stat-value">1</div>
                    <div class="stat-label">Administrators</div>
                </div>
            </div>

            <!-- ---- Filter + View Toggle ---- -->
            <div class="filter-bar">
                <div class="search-wrap">
                    <i class="bi bi-search"></i>
                    <input type="text"
                           class="search-input"
                           id="searchInput"
                           placeholder="Search by name, staff ID, mobile..."
                           oninput="filterStaff()" />
                </div>
                <div class="view-toggle">
                    <button class="view-btn active" id="cardViewBtn" onclick="switchView('card')" title="Card View">
                        <i class="bi bi-grid-3x3-gap"></i>
                    </button>
                    <button class="view-btn" id="tableViewBtn" onclick="switchView('table')" title="Table View">
                        <i class="bi bi-table"></i>
                    </button>
                </div>
            </div>

            <!-- ---- CARD VIEW ---- -->
            <div id="cardView">
                <div class="staff-grid" id="staffGrid">
                    <c:choose>
                        <c:when test="${empty staffList}">
                            <div class="empty-state glass-card">
                                <div class="empty-icon"><i class="bi bi-people"></i></div>
                                <p style="color:var(--text-muted); font-size:0.9rem;">
                                    No staff members yet. Click "Add Staff" to create one.
                                </p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="staff" items="${staffList}">
                                <div class="staff-card glass-card" data-name="${staff.username}"
                                     data-staffid="${staff.staffId}" data-mobile="${staff.mobileNum}">

                                    <div class="staff-card-header">
                                        <div class="staff-avatar-lg">
                                            ${staff.initial}
                                        </div>
                                        <div class="staff-info">
                                            <div class="staff-name">${staff.username}</div>
                                            <span class="staff-id-badge">${staff.staffId}</span>
                                        </div>
                                    </div>

                                    <div class="staff-detail-row">
                                        <i class="bi bi-telephone-fill"></i>
                                        <span>${not empty staff.mobileNum ? staff.mobileNum : '—'}</span>
                                    </div>
                                    <div class="staff-detail-row">
                                        <i class="bi bi-geo-alt-fill"></i>
                                        <span style="line-height:1.4;">${not empty staff.address ? staff.address : '—'}</span>
                                    </div>
                                    <div class="staff-detail-row">
                                        <i class="bi bi-person-badge-fill"></i>
                                        <span class="badge badge-staff">Staff</span>
                                    </div>

                                    <div class="staff-card-actions">
                                        <button class="btn-success-custom"
                                                style="flex:1;"
                                                onclick="openEditModal(
                                                    ${staff.id},
                                                    '${staff.username}',
                                                    '${staff.staffId}',
                                                    '${staff.mobileNum}',
                                                    `${staff.address}`
                                                )">
                                            <i class="bi bi-pencil-square me-1"></i>Edit
                                        </button>
                                        <button class="btn-danger-custom"
                                                onclick="confirmDelete(${staff.id}, '${staff.username}', '${staff.staffId}')">
                                            <i class="bi bi-trash3"></i>
                                        </button>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- ---- TABLE VIEW ---- -->
            <div id="tableView">
                <div class="glass-card table-section">
                    <div class="table-header">
                        <span class="table-title">All Staff Members</span>
                        <span class="table-count" id="tableRowCount">(${totalStaff} records)</span>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table" id="staffTable">
                            <thead>
                                <tr>
                                    <th>Staff ID</th>
                                    <th>Username</th>
                                    <th>Mobile Number</th>
                                    <th>Address</th>
                                    <th>Role</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="staffTableBody">
                                <c:choose>
                                    <c:when test="${empty staffList}">
                                        <tr>
                                            <td colspan="6" style="text-align:center; padding:40px; color:var(--text-muted);">
                                                No staff members found.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="staff" items="${staffList}">
                                            <tr>
                                                <td>
                                                    <span class="res-no-badge"
                                                          style="background:rgba(155,89,182,0.15); color:#c39bd3;
                                                                 border-color:rgba(155,89,182,0.3);">
                                                        ${staff.staffId}
                                                    </span>
                                                </td>
                                                <td>
                                                    <div style="display:flex; align-items:center; gap:10px;">
                                                        <div style="width:32px; height:32px; border-radius:8px;
                                                                    background:linear-gradient(135deg,var(--primary-light),var(--primary-dark));
                                                                    display:flex; align-items:center; justify-content:center;
                                                                    font-size:0.8rem; font-weight:700; flex-shrink:0;">
                                                            ${staff.initial}
                                                        </div>
                                                        <span style="font-weight:500; color:var(--text-white);">${staff.username}</span>
                                                    </div>
                                                </td>
                                                <td>${not empty staff.mobileNum ? staff.mobileNum : '—'}</td>
                                                <td style="max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
                                                    title="${staff.address}">
                                                    ${not empty staff.address ? staff.address : '—'}
                                                </td>
                                                <td><span class="badge badge-staff">Staff</span></td>
                                                <td>
                                                    <div class="action-btns">
                                                        <button class="btn-success-custom"
                                                                onclick="openEditModal(
                                                                    ${staff.id},
                                                                    '${staff.username}',
                                                                    '${staff.staffId}',
                                                                    '${staff.mobileNum}',
                                                                    `${staff.address}`
                                                                )">
                                                            <i class="bi bi-pencil-square"></i>
                                                        </button>
                                                        <button class="btn-danger-custom"
                                                                onclick="confirmDelete(${staff.id}, '${staff.username}', '${staff.staffId}')">
                                                            <i class="bi bi-trash3"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div><!-- /content-area -->
    </main>
</div><!-- /app-wrapper -->


<!-- =============================================
     CREATE STAFF MODAL
============================================= -->
<div class="modal-overlay" id="createModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title">
                <i class="bi bi-person-plus-fill me-2" style="color:var(--accent);"></i>Add New Staff
            </div>
            <button class="modal-close" onclick="closeModal('createModal')" aria-label="Close">
                <i class="bi bi-x"></i>
            </button>
        </div>

        <div style="font-size:0.8rem; color:var(--text-muted); margin-bottom:20px; padding:10px 14px;
                    background:rgba(26,143,176,0.08); border-radius:8px; border:1px solid rgba(26,143,176,0.2);">
            <i class="bi bi-info-circle me-2" style="color:var(--primary-light);"></i>
            Staff ID will be <strong style="color:var(--primary-light);">auto-generated</strong>
            (e.g. STF-001) via a MySQL stored procedure.
        </div>

        <form action="${pageContext.request.contextPath}/admin/staff" method="post" novalidate id="createForm">
            <input type="hidden" name="action" value="create" />

            <div class="form-group">
                <label for="c_username">Username</label>
                <div style="position:relative;">
                    <i class="bi bi-person-fill input-icon"></i>
                    <input type="text" id="c_username" name="username"
                           class="form-input" placeholder="e.g. john_doe" required
                           oninput="checkUsernameFormat(this)" />
                </div>
                <div id="usernameHint" style="font-size:0.72rem; color:var(--text-muted); margin-top:5px;">
                    Only letters, numbers, and underscores.
                </div>
            </div>

            <div class="form-group">
                <label for="c_password">Password</label>
                <div style="position:relative;">
                    <i class="bi bi-lock-fill input-icon"></i>
                    <input type="password" id="c_password" name="password"
                           class="form-input" placeholder="Min. 6 characters" required
                           oninput="checkStrength(this.value)" />
                    <button type="button" class="show-password-toggle" id="toggleCPwd"
                            style="position:absolute; right:14px; top:50%; transform:translateY(-50%);
                                   background:none; border:none; color:var(--text-muted); cursor:pointer; margin-top:12px;">
                        <i class="bi bi-eye" id="cEyeIcon"></i>
                    </button>
                </div>
                <div class="strength-bar">
                    <div class="strength-fill" id="strengthFill"></div>
                </div>
                <div class="strength-label" id="strengthLabel"></div>
            </div>

            <div class="form-group">
                <label for="c_mobileNum">Mobile Number</label>
                <div style="position:relative;">
                    <i class="bi bi-telephone-fill input-icon"></i>
                    <input type="text" id="c_mobileNum" name="mobileNum"
                           class="form-input" placeholder="e.g. 0771234567" />
                </div>
            </div>

            <div class="form-group">
                <label for="c_address">Address</label>
                <div style="position:relative;">
                    <i class="bi bi-geo-alt-fill input-icon"></i>
                    <input type="text" id="c_address" name="address"
                           class="form-input" placeholder="Staff member's address" />
                </div>
            </div>

            <button type="submit" class="btn-primary-custom" id="createSubmitBtn">
                <i class="bi bi-person-check me-2"></i>Create Staff Member
            </button>
        </form>
    </div>
</div>


<!-- =============================================
     EDIT STAFF MODAL
============================================= -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title">
                <i class="bi bi-pencil-square me-2" style="color:var(--primary-light);"></i>Edit Staff Member
            </div>
            <button class="modal-close" onclick="closeModal('editModal')" aria-label="Close">
                <i class="bi bi-x"></i>
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/admin/staff" method="post" novalidate id="editForm">
            <input type="hidden" name="action" value="update" />
            <input type="hidden" name="id"     id="e_id" />

            <div class="mb-3" style="padding:8px 14px; background:rgba(155,89,182,0.1);
                 border-radius:8px; font-size:0.82rem; color:var(--text-muted);">
                Staff ID: <span id="e_staffIdDisplay"
                                style="color:#c39bd3; font-weight:600; font-family:monospace;"></span>
            </div>

            <div class="form-group">
                <label for="e_username">Username</label>
                <div style="position:relative;">
                    <i class="bi bi-person-fill input-icon"></i>
                    <input type="text" id="e_username" name="username" class="form-input" required />
                </div>
            </div>

            <div class="form-group">
                <label for="e_password">
                    New Password
                    <span style="font-weight:400; color:var(--text-muted); font-size:0.75rem; margin-left:6px;">
                        (leave blank to keep current)
                    </span>
                </label>
                <div style="position:relative;">
                    <i class="bi bi-lock-fill input-icon"></i>
                    <input type="password" id="e_password" name="password"
                           class="form-input" placeholder="Leave blank to keep unchanged" />
                    <button type="button" id="toggleEPwd"
                            style="position:absolute; right:14px; top:50%; transform:translateY(-50%);
                                   background:none; border:none; color:var(--text-muted); cursor:pointer; margin-top:12px;">
                        <i class="bi bi-eye" id="eEyeIcon"></i>
                    </button>
                </div>
            </div>

            <div class="form-group">
                <label for="e_mobileNum">Mobile Number</label>
                <div style="position:relative;">
                    <i class="bi bi-telephone-fill input-icon"></i>
                    <input type="text" id="e_mobileNum" name="mobileNum" class="form-input" />
                </div>
            </div>

            <div class="form-group">
                <label for="e_address">Address</label>
                <div style="position:relative;">
                    <i class="bi bi-geo-alt-fill input-icon"></i>
                    <input type="text" id="e_address" name="address" class="form-input" />
                </div>
            </div>

            <button type="submit" class="btn-primary-custom">
                <i class="bi bi-save me-2"></i>Save Changes
            </button>
        </form>
    </div>
</div>


<!-- =============================================
     DELETE CONFIRMATION MODAL
============================================= -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal-box" style="max-width:400px; text-align:center;">
        <div style="font-size:3rem; color:#e74c3c; margin-bottom:16px;">
            <i class="bi bi-person-x-fill"></i>
        </div>
        <h3 style="font-family:var(--font-heading); margin-bottom:10px;">Remove Staff Member?</h3>
        <p style="color:var(--text-muted); font-size:0.88rem; margin-bottom:6px;">
            You are about to remove staff member
            <strong id="deleteStaffName" style="color:var(--text-white);"></strong>
        </p>
        <p style="color:var(--text-muted); font-size:0.82rem; margin-bottom:24px;">
            Staff ID: <strong id="deleteStaffId" style="color:#c39bd3; font-family:monospace;"></strong>
            <br/>
            <span style="color:#ff8a80; font-size:0.78rem;">
                <i class="bi bi-exclamation-triangle me-1"></i>
                Cannot delete if they have existing reservations.
            </span>
        </p>
        <div style="display:flex; gap:12px; justify-content:center;">
            <button class="btn-primary-custom" onclick="closeModal('deleteModal')"
                    style="background:rgba(255,255,255,0.1); box-shadow:none; width:auto; padding:10px 24px;">
                Cancel
            </button>
            <form action="${pageContext.request.contextPath}/admin/staff" method="post" style="display:inline;">
                <input type="hidden" name="action" value="delete" />
                <input type="hidden" name="id"     id="deleteStaffIdInput" />
                <button type="submit" class="btn-danger-custom" style="padding:10px 24px;">
                    <i class="bi bi-trash3 me-1"></i>Yes, Remove
                </button>
            </form>
        </div>
    </div>
</div>

<!-- Sidebar Overlay (mobile) -->
<div id="sidebarOverlay"
     style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.6);
            z-index:999; backdrop-filter:blur(3px);"
     onclick="closeSidebar()"></div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
// =============================================
// MODAL HELPERS
// =============================================
function openModal(id) {
    document.getElementById(id).classList.add('active');
    document.body.style.overflow = 'hidden';
}

function closeModal(id) {
    document.getElementById(id).classList.remove('active');
    document.body.style.overflow = '';
}

document.querySelectorAll('.modal-overlay').forEach(overlay => {
    overlay.addEventListener('click', e => {
        if (e.target === overlay) closeModal(overlay.id);
    });
});

document.addEventListener('keydown', e => {
    if (e.key === 'Escape')
        document.querySelectorAll('.modal-overlay.active').forEach(m => closeModal(m.id));
});

// =============================================
// CREATE MODAL
// =============================================
function openCreateModal() {
    document.getElementById('createForm').reset();
    document.getElementById('strengthFill').style.width = '0%';
    document.getElementById('strengthLabel').textContent = '';
    openModal('createModal');
}

// Password toggle (create)
document.getElementById('toggleCPwd').addEventListener('click', () => {
    const pwd = document.getElementById('c_password');
    const ico = document.getElementById('cEyeIcon');
    const isVisible = pwd.type === 'text';
    pwd.type = isVisible ? 'password' : 'text';
    ico.className = isVisible ? 'bi bi-eye' : 'bi bi-eye-slash';
});

// Username format hint
function checkUsernameFormat(input) {
    const hint = document.getElementById('usernameHint');
    const valid = /^[a-zA-Z0-9_]+$/.test(input.value);
    hint.style.color = input.value.length === 0
        ? 'var(--text-muted)'
        : valid ? '#6fcf97' : '#ff8a80';
    hint.textContent = input.value.length === 0
        ? 'Only letters, numbers, and underscores.'
        : valid ? '✓ Valid username' : '✗ Only letters, numbers, and underscores allowed';
}

// Password strength
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

// =============================================
// EDIT MODAL
// =============================================
function openEditModal(id, uname, staffId, mobile, address) {
    document.getElementById('e_id').value            = id;
    document.getElementById('e_staffIdDisplay').textContent = staffId;
    document.getElementById('e_username').value      = uname;
    document.getElementById('e_password').value      = '';
    document.getElementById('e_mobileNum').value     = mobile || '';
    document.getElementById('e_address').value       = address  || '';
    openModal('editModal');
}

// Password toggle (edit)
document.getElementById('toggleEPwd').addEventListener('click', () => {
    const pwd = document.getElementById('e_password');
    const ico = document.getElementById('eEyeIcon');
    const isVisible = pwd.type === 'text';
    pwd.type = isVisible ? 'password' : 'text';
    ico.className = isVisible ? 'bi bi-eye' : 'bi bi-eye-slash';
});

// =============================================
// DELETE MODAL
// =============================================
function confirmDelete(id, uname, staffId) {
    document.getElementById('deleteStaffName').textContent = uname;
    document.getElementById('deleteStaffId').textContent   = staffId;
    document.getElementById('deleteStaffIdInput').value    = id;
    openModal('deleteModal');
}

// =============================================
// SEARCH / FILTER
// =============================================
function filterStaff() {
    const term    = document.getElementById('searchInput').value.toLowerCase();
    const isTable = document.getElementById('tableView').style.display !== 'none';

    if (isTable) {
        // Filter table rows
        const rows = document.querySelectorAll('#staffTableBody tr');
        rows.forEach(row => {
            row.style.display = row.textContent.toLowerCase().includes(term) ? '' : 'none';
        });
    } else {
        // Filter cards
        const cards = document.querySelectorAll('#staffGrid .staff-card');
        cards.forEach(card => {
            const text = (card.dataset.name + card.dataset.staffid + card.dataset.mobile).toLowerCase();
            card.style.display = text.includes(term) ? '' : 'none';
        });
    }
}

// =============================================
// VIEW TOGGLE (CARD / TABLE)
// =============================================
function switchView(mode) {
    const cardView    = document.getElementById('cardView');
    const tableView   = document.getElementById('tableView');
    const cardBtn     = document.getElementById('cardViewBtn');
    const tableBtn    = document.getElementById('tableViewBtn');

    if (mode === 'card') {
        cardView.style.display  = 'block';
        tableView.style.display = 'none';
        cardBtn.classList.add('active');
        tableBtn.classList.remove('active');
    } else {
        cardView.style.display  = 'none';
        tableView.style.display = 'block';
        cardBtn.classList.remove('active');
        tableBtn.classList.add('active');
    }
    document.getElementById('searchInput').value = '';
}

// =============================================
// FLASH MESSAGES AUTO-DISMISS
// =============================================
const flashMsg = document.getElementById('flashMsg');
if (flashMsg) {
    setTimeout(() => {
        flashMsg.style.transition = 'opacity 0.5s';
        flashMsg.style.opacity    = '0';
        setTimeout(() => flashMsg.remove(), 500);
    }, 4000);
}

// =============================================
// MOBILE SIDEBAR
// =============================================
function closeSidebar() {
    document.getElementById('sidebar').classList.remove('open');
    document.getElementById('sidebarOverlay').style.display = 'none';
}

document.getElementById('hamburgerBtn')?.addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('open');
    const isOpen = document.getElementById('sidebar').classList.contains('open');
    document.getElementById('sidebarOverlay').style.display = isOpen ? 'block' : 'none';
});
</script>
</body>
</html>
