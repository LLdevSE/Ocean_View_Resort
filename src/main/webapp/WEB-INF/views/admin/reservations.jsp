<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
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
    <title>Reservations &mdash; Ocean View Resort</title>
    <meta name="description" content="Manage all hotel reservations for Ocean View Resort." />

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />

    <style>
        /* ---- Search & Filter Bar ---- */
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
            font-size: 0.95rem;
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

        .filter-select {
            background: rgba(255,255,255,0.06);
            border: 1px solid var(--border-glass);
            border-radius: var(--radius-sm);
            padding: 10px 14px;
            color: var(--text-white);
            font-family: var(--font-main);
            font-size: 0.88rem;
            outline: none;
            cursor: pointer;
            min-width: 140px;
        }

        .filter-select option { background: #0d1b2a; }

        /* ---- Table card ---- */
        .table-section {
            padding: 0;
        }

        .table-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 24px;
            border-bottom: 1px solid var(--border-glass);
        }

        .table-title {
            font-family: var(--font-heading);
            font-size: 1.1rem;
            font-weight: 600;
        }

        .table-count {
            font-size: 0.75rem;
            color: var(--text-muted);
            margin-left: 8px;
        }

        /* ---- Res No badge ---- */
        .res-no-badge {
            font-family: monospace;
            font-size: 0.8rem;
            background: rgba(26,143,176,0.15);
            color: var(--primary-light);
            padding: 3px 8px;
            border-radius: 5px;
            border: 1px solid rgba(26,143,176,0.3);
            white-space: nowrap;
        }

        /* ---- Room type chips ---- */
        .chip-standard { background:rgba(39,174,96,0.15);  color:#6fcf97; border:1px solid rgba(39,174,96,0.3);  }
        .chip-deluxe   { background:rgba(240,165,0,0.15);  color:var(--accent); border:1px solid rgba(240,165,0,0.3); }
        .chip-suite    { background:rgba(155,89,182,0.15); color:#c39bd3; border:1px solid rgba(155,89,182,0.3); }

        /* ---- Empty state ---- */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }

        .empty-icon {
            font-size: 3.5rem;
            color: var(--text-muted);
            margin-bottom: 16px;
            opacity: 0.4;
        }

        /* ---- Mobile hamburger ---- */
        .hamburger-btn {
            display: none;
            background: none;
            border: 1px solid var(--border-glass);
            color: var(--text-white);
            border-radius: var(--radius-sm);
            padding: 6px 10px;
            cursor: pointer;
            font-size: 1.1rem;
        }

        @media (max-width: 768px) {
            .hamburger-btn { display: flex; align-items: center; }
            .table-responsive { overflow-x: auto; }
        }
    </style>
</head>
<body>

<div class="app-wrapper">

    <!-- ===========================
         SIDEBAR (SHARED)
    =========================== -->
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp">
        <jsp:param name="activePage" value="admin-reservations"/>
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
                <div class="page-title">Reservations</div>
                <div class="page-subtitle">Manage all hotel reservations</div>
            </div>
            <div>
                <button class="btn-accent" onclick="openCreateModal()" id="btnNewReservation">
                    <i class="bi bi-plus-lg me-1"></i> New Reservation
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

            <!-- ---- Stats Grid ---- -->
            <div class="stats-grid">
                <div class="stat-card glass-card blue">
                    <div class="stat-icon"><i class="bi bi-calendar2-check"></i></div>
                    <div class="stat-value">${totalReservations}</div>
                    <div class="stat-label">Total Reservations</div>
                </div>
                <div class="stat-card glass-card amber">
                    <div class="stat-icon"><i class="bi bi-door-open"></i></div>
                    <div class="stat-value">${availableRooms}</div>
                    <div class="stat-label">Available Rooms</div>
                </div>
                <div class="stat-card glass-card green">
                    <div class="stat-icon"><i class="bi bi-house-check"></i></div>
                    <div class="stat-value">${totalRooms}</div>
                    <div class="stat-label">Total Rooms</div>
                </div>
                <div class="stat-card glass-card purple">
                    <div class="stat-icon"><i class="bi bi-people"></i></div>
                    <div class="stat-value">${totalStaff}</div>
                    <div class="stat-label">Staff Members</div>
                </div>
                <div class="stat-card glass-card teal" style="background:linear-gradient(135deg,rgba(0,150,136,0.25),rgba(0,150,136,0.08));">
                    <div class="stat-icon"><i class="bi bi-door-closed-fill"></i></div>
                    <div class="stat-value">${availableStandard}</div>
                    <div class="stat-label">Standard Avail.</div>
                </div>
                <div class="stat-card glass-card orange" style="background:linear-gradient(135deg,rgba(255,152,0,0.25),rgba(255,152,0,0.08));">
                    <div class="stat-icon"><i class="bi bi-door-open-fill"></i></div>
                    <div class="stat-value">${availableDeluxe}</div>
                    <div class="stat-label">Deluxe Avail.</div>
                </div>
                <div class="stat-card glass-card pink" style="background:linear-gradient(135deg,rgba(233,30,99,0.25),rgba(233,30,99,0.08));">
                    <div class="stat-icon"><i class="bi bi-star-fill"></i></div>
                    <div class="stat-value">${availableSuite}</div>
                    <div class="stat-label">Suite Avail.</div>
                </div>
            </div>

            <!-- ---- Filter / Search ---- -->
            <div class="filter-bar">
                <div class="search-wrap">
                    <i class="bi bi-search"></i>
                    <input type="text"
                           class="search-input"
                           id="searchInput"
                           placeholder="Search by name, res no, mobile..."
                           oninput="filterTable()" />
                </div>
                <select class="filter-select" id="roomTypeFilter" onchange="filterTable()">
                    <option value="">All Room Types</option>
                    <option value="STANDARD">Standard</option>
                    <option value="DELUXE">Deluxe</option>
                    <option value="SUITE">Suite</option>
                </select>
            </div>

            <!-- ---- Reservations Table ---- -->
            <div class="glass-card table-section">
                <div class="table-header">
                    <div>
                        <span class="table-title">All Reservations</span>
                        <span class="table-count" id="rowCount">(${totalReservations} records)</span>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="data-table" id="reservationsTable">
                        <thead>
                            <tr>
                                <th>Res No</th>
                                <th>Customer Name</th>
                                <th>Mobile</th>
                                <th>Address</th>
                                <th>Room Type</th>
                                <th>Check In</th>
                                <th>Check Out</th>
                                <th>Days</th>
                                <th>Total (Rs.)</th>
                                <th>Reserved By</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="reservationsBody">
                            <c:choose>
                                <c:when test="${empty reservations}">
                                    <tr>
                                        <td colspan="11">
                                            <div class="empty-state">
                                                <div class="empty-icon"><i class="bi bi-calendar-x"></i></div>
                                                <p style="color:var(--text-muted); font-size:0.9rem;">
                                                    No reservations found. Create one to get started.
                                                </p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="res" items="${reservations}">
                                        <tr>
                                            <td><span class="res-no-badge">${res.resNo}</span></td>
                                            <td style="font-weight:500; color:var(--text-white);">${res.customerName}</td>
                                            <td>${res.customerMobileNum}</td>
                                            <td style="max-width:150px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
                                                title="${res.customerAddress}">${res.customerAddress}</td>
                                            <td>
                                                <span class="badge
                                                    <c:choose>
                                                        <c:when test="${res.roomType == 'STANDARD'}">chip-standard</c:when>
                                                        <c:when test="${res.roomType == 'DELUXE'}">chip-deluxe</c:when>
                                                        <c:otherwise>chip-suite</c:otherwise>
                                                    </c:choose>">
                                                    ${res.roomType}
                                                </span>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${res.checkIn}" pattern="dd MMM yyyy" />
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${res.checkOut}" pattern="dd MMM yyyy" />
                                            </td>
                                            <td style="text-align:center;">${res.totalDays}</td>
                                            <td style="color:var(--accent); font-weight:600;">
                                                <fmt:formatNumber value="${res.totalPrice}" type="number" minFractionDigits="2" maxFractionDigits="2" />
                                            </td>
                                            <td>
                                                <span style="font-size:0.8rem;">${res.reservedByUsername}</span>
                                                <br/>
                                                <span style="font-size:0.72rem; color:var(--text-muted);">${res.reservationBy}</span>
                                            </td>
                                            <td>
                                                <div class="action-btns">
                                                    <button class="btn-success-custom"
                                                            title="Edit"
                                                            onclick="openEditModal(
                                                                '${res.resNo}',
                                                                '${res.customerName}',
                                                                '${res.customerMobileNum}',
                                                                `${res.customerAddress}`,
                                                                '${res.roomType}',
                                                                '${res.checkIn}',
                                                                '${res.checkOut}'
                                                            )">
                                                        <i class="bi bi-pencil-square"></i>
                                                    </button>
                                                    <button class="btn-danger-custom"
                                                            title="Delete"
                                                            onclick="confirmDelete('${res.resNo}', '${res.customerName}')">
                                                        <i class="bi bi-trash3"></i>
                                                    </button>
                                                    <a href="${pageContext.request.contextPath}/admin/billing?resNo=${res.resNo}"
                                                       class="btn-accent"
                                                       title="View Bill"
                                                       style="padding:7px 12px; font-size:0.82rem;">
                                                        <i class="bi bi-receipt"></i>
                                                    </a>
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
            <!-- End Table -->

        </div><!-- /content-area -->
    </main>
</div><!-- /app-wrapper -->


<!-- =============================================
     CREATE RESERVATION MODAL
============================================= -->
<div class="modal-overlay" id="createModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title"><i class="bi bi-calendar-plus me-2" style="color:var(--accent);"></i>New Reservation</div>
            <button class="modal-close" onclick="closeModal('createModal')" aria-label="Close"><i class="bi bi-x"></i></button>
        </div>

        <form action="${pageContext.request.contextPath}/admin/reservations" method="post" novalidate id="createForm">
            <input type="hidden" name="action" value="create" />

            <div class="form-group">
                <label for="c_customerName">Customer Name</label>
                <div style="position:relative;">
                    <i class="bi bi-person-fill input-icon"></i>
                    <input type="text" id="c_customerName" name="customerName" class="form-input" placeholder="Full name" required />
                </div>
            </div>

            <div class="form-group">
                <label for="c_customerMobile">Mobile Number</label>
                <div style="position:relative;">
                    <i class="bi bi-telephone-fill input-icon"></i>
                    <input type="text" id="c_customerMobile" name="customerMobile" class="form-input" placeholder="e.g. 0771234567" required />
                </div>
            </div>

            <div class="form-group">
                <label for="c_customerAddress">Address</label>
                <div style="position:relative;">
                    <i class="bi bi-geo-alt-fill input-icon"></i>
                    <input type="text" id="c_customerAddress" name="customerAddress" class="form-input" placeholder="Customer address" required />
                </div>
            </div>

            <div class="form-group">
                <label for="c_roomType">Room Type</label>
                <select id="c_roomType" name="roomType" class="form-input no-icon" required>
                    <option value="">-- Select Room Type --</option>
                    <option value="STANDARD">Standard (Rs. 5,500 / night)</option>
                    <option value="DELUXE">Deluxe (Rs. 9,500 / night)</option>
                    <option value="SUITE">Suite (Rs. 18,000 / night)</option>
                </select>
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:14px;">
                <div class="form-group">
                    <label for="c_checkIn">Check In</label>
                    <div style="position:relative;">
                        <i class="bi bi-calendar-event-fill input-icon"></i>
                        <input type="date" id="c_checkIn" name="checkIn" class="form-input" required />
                    </div>
                </div>
                <div class="form-group">
                    <label for="c_checkOut">Check Out</label>
                    <div style="position:relative;">
                        <i class="bi bi-calendar-check-fill input-icon"></i>
                        <input type="date" id="c_checkOut" name="checkOut" class="form-input" required />
                    </div>
                </div>
            </div>

            <!-- Live price estimate -->
            <div id="priceEstimate" style="display:none; margin-bottom:18px; padding:12px 16px;
                 background:rgba(240,165,0,0.1); border:1px solid rgba(240,165,0,0.3); border-radius:8px;
                 font-size:0.85rem; color:var(--accent);">
                <i class="bi bi-calculator me-2"></i>
                Estimated Total: <strong id="estTotal">Rs. 0.00</strong>
                (<span id="estDays">0</span> nights × Rs. <span id="estRate">0</span>/night)
            </div>

            <button type="submit" class="btn-primary-custom" id="createSubmitBtn">
                <i class="bi bi-check-circle me-2"></i>Create Reservation
            </button>
        </form>
    </div>
</div>

<!-- =============================================
     EDIT RESERVATION MODAL
============================================= -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title"><i class="bi bi-pencil-square me-2" style="color:var(--primary-light);"></i>Edit Reservation</div>
            <button class="modal-close" onclick="closeModal('editModal')" aria-label="Close"><i class="bi bi-x"></i></button>
        </div>

        <form action="${pageContext.request.contextPath}/admin/reservations" method="post" novalidate id="editForm">
            <input type="hidden" name="action" value="update" />
            <input type="hidden" name="resNo"  id="e_resNo" />

            <div class="mb-3" style="padding:8px 12px; background:rgba(26,143,176,0.1);
                 border-radius:8px; font-size:0.82rem; color:var(--text-muted);">
                Editing: <span id="e_resNoDisplay" style="color:var(--primary-light); font-weight:600;"></span>
            </div>

            <div class="form-group">
                <label for="e_customerName">Customer Name</label>
                <div style="position:relative;">
                    <i class="bi bi-person-fill input-icon"></i>
                    <input type="text" id="e_customerName" name="customerName" class="form-input" required />
                </div>
            </div>

            <div class="form-group">
                <label for="e_customerMobile">Mobile Number</label>
                <div style="position:relative;">
                    <i class="bi bi-telephone-fill input-icon"></i>
                    <input type="text" id="e_customerMobile" name="customerMobile" class="form-input" required />
                </div>
            </div>

            <div class="form-group">
                <label for="e_customerAddress">Address</label>
                <div style="position:relative;">
                    <i class="bi bi-geo-alt-fill input-icon"></i>
                    <input type="text" id="e_customerAddress" name="customerAddress" class="form-input" required />
                </div>
            </div>

            <div class="form-group">
                <label for="e_roomType">Room Type</label>
                <select id="e_roomType" name="roomType" class="form-input no-icon" required>
                    <option value="STANDARD">Standard (Rs. 5,500 / night)</option>
                    <option value="DELUXE">Deluxe (Rs. 9,500 / night)</option>
                    <option value="SUITE">Suite (Rs. 18,000 / night)</option>
                </select>
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:14px;">
                <div class="form-group">
                    <label for="e_checkIn">Check In</label>
                    <div style="position:relative;">
                        <i class="bi bi-calendar-event-fill input-icon"></i>
                        <input type="date" id="e_checkIn" name="checkIn" class="form-input" required />
                    </div>
                </div>
                <div class="form-group">
                    <label for="e_checkOut">Check Out</label>
                    <div style="position:relative;">
                        <i class="bi bi-calendar-check-fill input-icon"></i>
                        <input type="date" id="e_checkOut" name="checkOut" class="form-input" required />
                    </div>
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
            <i class="bi bi-trash3-fill"></i>
        </div>
        <h3 style="font-family:var(--font-heading); margin-bottom:10px;">Delete Reservation?</h3>
        <p style="color:var(--text-muted); font-size:0.88rem; margin-bottom:24px;">
            This will permanently delete reservation <strong id="deleteResNo" style="color:var(--primary-light);"></strong>
            for <strong id="deleteCustomer" style="color:var(--text-white);"></strong>.
            This action cannot be undone.
        </p>
        <div style="display:flex; gap:12px; justify-content:center;">
            <button class="btn-primary-custom" onclick="closeModal('deleteModal')"
                    style="background:rgba(255,255,255,0.1); box-shadow:none; width:auto; padding:10px 24px;">
                Cancel
            </button>
            <form action="${pageContext.request.contextPath}/admin/reservations" method="post" style="display:inline;">
                <input type="hidden" name="action" value="delete" />
                <input type="hidden" name="resNo"  id="deleteResNoInput" />
                <button type="submit" class="btn-danger-custom" style="padding:10px 24px;">
                    <i class="bi bi-trash3 me-1"></i>Yes, Delete
                </button>
            </form>
        </div>
    </div>
</div>





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

// Close on backdrop click
document.querySelectorAll('.modal-overlay').forEach(overlay => {
    overlay.addEventListener('click', e => {
        if (e.target === overlay) closeModal(overlay.id);
    });
});

// Close on Escape key
document.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
        document.querySelectorAll('.modal-overlay.active').forEach(m => closeModal(m.id));
    }
});

// =============================================
// CREATE MODAL
// =============================================
function openCreateModal() {
    document.getElementById('createForm').reset();
    document.getElementById('priceEstimate').style.display = 'none';

    // Set min date for check-in to today
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('c_checkIn').min  = today;
    document.getElementById('c_checkOut').min = today;

    openModal('createModal');
}

// Live price estimator
const PRICES = { STANDARD: 5500, DELUXE: 9500, SUITE: 18000 };

function recalcPrice() {
    const roomType = document.getElementById('c_roomType').value;
    const checkIn  = document.getElementById('c_checkIn').value;
    const checkOut = document.getElementById('c_checkOut').value;
    const estimate = document.getElementById('priceEstimate');

    if (roomType && checkIn && checkOut) {
        const d1   = new Date(checkIn);
        const d2   = new Date(checkOut);
        const days = Math.max(Math.ceil((d2 - d1) / 86400000), 1);
        const rate = PRICES[roomType] || 0;
        const total = (days * rate).toLocaleString('en-US', {minimumFractionDigits:2});

        document.getElementById('estDays').textContent = days;
        document.getElementById('estRate').textContent = rate.toLocaleString();
        document.getElementById('estTotal').textContent = 'Rs. ' + total;

        estimate.style.display = 'block';

        // Enforce check-out > check-in
        document.getElementById('c_checkOut').min = checkIn;
    } else {
        estimate.style.display = 'none';
    }
}

['c_roomType', 'c_checkIn', 'c_checkOut'].forEach(id => {
    document.getElementById(id).addEventListener('change', recalcPrice);
    document.getElementById(id).addEventListener('input',  recalcPrice);
});

// =============================================
// EDIT MODAL
// =============================================
function openEditModal(resNo, name, mobile, address, roomType, checkIn, checkOut) {
    document.getElementById('e_resNo').value         = resNo;
    document.getElementById('e_resNoDisplay').textContent = resNo;
    document.getElementById('e_customerName').value   = name;
    document.getElementById('e_customerMobile').value = mobile;
    document.getElementById('e_customerAddress').value = address;
    document.getElementById('e_roomType').value       = roomType;
    document.getElementById('e_checkIn').value        = checkIn;
    document.getElementById('e_checkOut').value       = checkOut;
    openModal('editModal');
}

// =============================================
// DELETE MODAL
// =============================================
function confirmDelete(resNo, customerName) {
    document.getElementById('deleteResNo').textContent    = resNo;
    document.getElementById('deleteCustomer').textContent = customerName;
    document.getElementById('deleteResNoInput').value     = resNo;
    openModal('deleteModal');
}

// =============================================
// SEARCH & FILTER
// =============================================
function filterTable() {
    const term     = document.getElementById('searchInput').value.toLowerCase();
    const typeFilter = document.getElementById('roomTypeFilter').value.toUpperCase();
    const rows     = document.querySelectorAll('#reservationsBody tr');
    let visible    = 0;

    rows.forEach(row => {
        const text     = row.textContent.toLowerCase();
        const roomCell = row.querySelector('td:nth-child(5)');
        const roomType = roomCell ? roomCell.textContent.trim().toUpperCase() : '';

        const matchText = text.includes(term);
        const matchType = !typeFilter || roomType.includes(typeFilter);

        if (matchText && matchType) {
            row.style.display = '';
            visible++;
        } else {
            row.style.display = 'none';
        }
    });

    document.getElementById('rowCount').textContent = '(' + visible + ' records)';
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


</script>

</body>
</html>
