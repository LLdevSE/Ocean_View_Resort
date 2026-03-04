<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
    <title>My Reservations &mdash; Staff Portal</title>
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />

    <style>
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

        .type-filter {
            background: rgba(255,255,255,0.06);
            border: 1px solid var(--border-glass);
            color: var(--text-white);
            padding: 9px 14px;
            border-radius: var(--radius-sm);
            font-size: 0.88rem;
            outline: none;
            cursor: pointer;
        }

        .type-filter option { background: #0b1521; color: #fff; }

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
        <jsp:param name="activePage" value="staff-reservations"/>
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
                <div class="page-title">My Reservations</div>
                <div class="page-subtitle">Manage reservations you have created</div>
            </div>
            <div>
                <button class="btn-accent" onclick="openCreateModal()">
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

            <!-- Dashboard Stats -->
            <div class="stats-grid">
                <div class="stat-card glass-card purple">
                    <div class="stat-icon"><i class="bi bi-bookmark-star-fill"></i></div>
                    <div class="stat-value">${totalStaffReservations}</div>
                    <div class="stat-label">My Reservations</div>
                </div>
                <!-- Room Availability Indicators -->
                <div class="stat-card glass-card blue">
                    <div class="stat-icon"><i class="bi bi-door-open-fill"></i></div>
                    <div class="stat-value">${availableStandard}</div>
                    <div class="stat-label">Standard Avail.</div>
                </div>
                <div class="stat-card glass-card emerald">
                    <div class="stat-icon"><i class="bi bi-door-closed-fill"></i></div>
                    <div class="stat-value">${availableDeluxe}</div>
                    <div class="stat-label">Deluxe Avail.</div>
                </div>
                <div class="stat-card glass-card orange">
                    <div class="stat-icon"><i class="bi bi-star-fill"></i></div>
                    <div class="stat-value">${availableSuite}</div>
                    <div class="stat-label">Suite Avail.</div>
                </div>
            </div>

            <!-- Filter Bar -->
            <div class="filter-bar">
                <div class="search-wrap">
                    <i class="bi bi-search"></i>
                    <input type="text" 
                           class="search-input" 
                           id="searchInput" 
                           placeholder="Search by res no, name, mobile..." 
                           oninput="filterTable()" />
                </div>
                <select class="type-filter" id="typeFilter" onchange="filterTable()">
                    <option value="ALL">All Room Types</option>
                    <option value="STANDARD">Standard</option>
                    <option value="DELUXE">Deluxe</option>
                    <option value="SUITE">Suite</option>
                </select>
            </div>

            <!-- Table Section -->
            <div class="glass-card table-section">
                <div class="table-header">
                    <span class="table-title">Reservations Handled By Me</span>
                    <span class="table-count" id="tableRowCount">(${totalStaffReservations} records)</span>
                </div>
                
                <div class="table-responsive">
                    <table class="data-table" id="resTable">
                        <thead>
                            <tr>
                                <th>Res No</th>
                                <th>Customer Info</th>
                                <th>Room Type</th>
                                <th>Check In</th>
                                <th>Check Out</th>
                                <th style="text-align:right;">Amount (Rs.)</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="resTableBody">
                            <c:choose>
                                <c:when test="${empty reservationList}">
                                    <tr>
                                        <td colspan="7" style="text-align:center; padding:40px; color:var(--text-muted);">
                                            You haven't created any reservations yet. Click "New Reservation" to start.
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="res" items="${reservationList}">
                                        <tr data-type="${res.roomType}">
                                            <td><span class="res-no-badge">${res.resNo}</span></td>
                                            <td>
                                                <div style="font-weight:600; color:var(--text-white); margin-bottom:4px;">
                                                    ${res.customerName}
                                                </div>
                                                <div style="font-size:0.8rem; color:var(--text-muted);">
                                                    <i class="bi bi-telephone-fill me-1"></i>${res.customerMobileNum}
                                                </div>
                                            </td>
                                            <td>
                                                <span class="badge badge-${res.roomType.toLowerCase()}">
                                                    ${res.roomType}
                                                </span>
                                            </td>
                                            <td style="color:var(--text-white);">
                                                <fmt:formatDate value="${res.checkIn}" pattern="dd/MM/yyyy" />
                                            </td>
                                            <td style="color:var(--text-white);">
                                                <fmt:formatDate value="${res.checkOut}" pattern="dd/MM/yyyy" />
                                            </td>
                                            <td style="text-align:right; font-weight:600; color:var(--text-white);">
                                                <fmt:formatNumber value="${res.totalPrice}" pattern="#,##0.00" />
                                            </td>
                                            <td>
                                                <!-- Staff can only Edit (no Delete) -->
                                                <div class="action-btns">
                                                    <button class="btn-success-custom" 
                                                            title="Edit Reservation"
                                                            onclick="openEditModal(
                                                                '${res.resNo}',
                                                                '${res.customerName}',
                                                                '${res.customerMobileNum}',
                                                                `${res.customerAddress}`,
                                                                '${res.roomType}',
                                                                '${res.checkIn}',
                                                                '${res.checkOut}'
                                                            )">
                                                        <i class="bi bi-pencil-square"></i> Edit
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

        </div><!-- /content-area -->
    </main>
</div>

<!-- =============================================
     CREATE RESERVATION MODAL
============================================= -->
<div class="modal-overlay" id="createModal">
    <div class="modal-box modal-lg">
        <div class="modal-header">
            <div class="modal-title">
                <i class="bi bi-calendar-plus-fill me-2" style="color:var(--accent);"></i>New Reservation
            </div>
            <button class="modal-close" onclick="closeModal('createModal')">
                <i class="bi bi-x"></i>
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/staff/reservations" method="post" id="createForm">
            <input type="hidden" name="action" value="create" />
            
            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label>Customer Name</label>
                    <input type="text" name="customerName" class="form-input" required />
                </div>
                <div class="col-md-6">
                    <label>Mobile Number</label>
                    <input type="text" name="customerMobileNum" class="form-input" required />
                </div>
            </div>

            <div class="form-group mb-3">
                <label>Customer Address</label>
                <input type="text" name="customerAddress" class="form-input" required />
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <label>Room Type</label>
                    <div class="select-wrapper">
                        <select name="roomType" id="c_roomType" class="form-input" required onchange="calculatePrice('create')">
                            <option value="STANDARD" selected data-price="10000">Standard (Rs. 10,000/night)</option>
                            <option value="DELUXE" data-price="20000">Deluxe (Rs. 20,000/night)</option>
                            <option value="SUITE" data-price="50000">Suite (Rs. 50,000/night)</option>
                        </select>
                        <i class="bi bi-chevron-down select-icon"></i>
                    </div>
                </div>
                <div class="col-md-4">
                    <label>Check-In Date</label>
                    <input type="date" name="checkIn" id="c_checkIn" class="form-input" required onchange="calculatePrice('create')" />
                </div>
                <div class="col-md-4">
                    <label>Check-Out Date</label>
                    <input type="date" name="checkOut" id="c_checkOut" class="form-input" required onchange="calculatePrice('create')" />
                </div>
            </div>

            <!-- Price Estimator -->
            <div class="price-estimator" id="c_priceEstimator">
                <div style="font-size:0.85rem; color:var(--text-muted); margin-bottom:5px;">Estimated Total</div>
                <div class="price-value">
                    <span id="c_totalDays">0</span> nights &times; <span id="c_roomRate">Rs. 0</span>
                    = <span style="font-size:1.4rem; color:var(--text-white); margin-left:10px;">Rs. <span id="c_totalPrice" style="color:var(--accent);">0.00</span></span>
                </div>
            </div>

            <button type="submit" class="btn-primary-custom w-100" id="c_submitBtn" disabled>
                <i class="bi bi-calendar-check me-2"></i> Confirm Reservation
            </button>
        </form>
    </div>
</div>

<!-- =============================================
     EDIT RESERVATION MODAL
============================================= -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box modal-lg">
        <div class="modal-header">
            <div class="modal-title">
                <i class="bi bi-pencil-square me-2" style="color:var(--primary-light);"></i>Edit Reservation
            </div>
            <button class="modal-close" onclick="closeModal('editModal')">
                <i class="bi bi-x"></i>
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/staff/reservations" method="post" id="editForm">
            <input type="hidden" name="action" value="update" />
            <input type="hidden" name="resNo" id="e_resNo" />
            
            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label>Customer Name</label>
                    <input type="text" id="e_customerName" name="customerName" class="form-input" required />
                </div>
                <div class="col-md-6">
                    <label>Mobile Number</label>
                    <input type="text" id="e_customerMobileNum" name="customerMobileNum" class="form-input" required />
                </div>
            </div>

            <div class="form-group mb-3">
                <label>Customer Address</label>
                <input type="text" id="e_customerAddress" name="customerAddress" class="form-input" required />
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <label>Room Type</label>
                    <div class="select-wrapper">
                        <select name="roomType" id="e_roomType" class="form-input" required onchange="calculatePrice('edit')">
                            <option value="STANDARD" data-price="10000">Standard (Rs. 10,000/night)</option>
                            <option value="DELUXE" data-price="20000">Deluxe (Rs. 20,000/night)</option>
                            <option value="SUITE" data-price="50000">Suite (Rs. 50,000/night)</option>
                        </select>
                        <i class="bi bi-chevron-down select-icon"></i>
                    </div>
                </div>
                <div class="col-md-4">
                    <label>Check-In Date</label>
                    <input type="date" name="checkIn" id="e_checkIn" class="form-input" required onchange="calculatePrice('edit')" />
                </div>
                <div class="col-md-4">
                    <label>Check-Out Date</label>
                    <input type="date" name="checkOut" id="e_checkOut" class="form-input" required onchange="calculatePrice('edit')" />
                </div>
            </div>

            <div class="price-estimator" id="e_priceEstimator">
                <div style="font-size:0.85rem; color:var(--text-muted); margin-bottom:5px;">Updated Estimated Total</div>
                <div class="price-value">
                    <span id="e_totalDays">0</span> nights &times; <span id="e_roomRate">Rs. 0</span>
                    = <span style="font-size:1.4rem; color:var(--text-white); margin-left:10px;">Rs. <span id="e_totalPrice" style="color:var(--accent);">0.00</span></span>
                </div>
            </div>

            <button type="submit" class="btn-primary-custom w-100" id="e_submitBtn">
                <i class="bi bi-save me-2"></i> Save Changes
            </button>
        </form>
    </div>
</div>


// Format dates for min attributes
const today = new Date().toISOString().split('T')[0];
document.getElementById('c_checkIn').min = today;
document.getElementById('c_checkOut').min = today;

function calculatePrice(mode) {
    const prefix = mode === 'create' ? 'c_' : 'e_';
    
    const typeSelect = document.getElementById(prefix + 'roomType');
    const checkInStr = document.getElementById(prefix + 'checkIn').value;
    const checkOutStr = document.getElementById(prefix + 'checkOut').value;
    const submitBtn = document.getElementById(prefix + 'submitBtn');
    
    const pricePerNight = parseFloat(typeSelect.options[typeSelect.selectedIndex].dataset.price);
    
    // Formatting currency locally matches server
    document.getElementById(prefix + 'roomRate').textContent = 'Rs. ' + pricePerNight.toLocaleString();
    
    if (checkInStr && checkOutStr) {
        const inDate = new Date(checkInStr);
        const outDate = new Date(checkOutStr);
        
        let days = Math.round((outDate - inDate) / (1000 * 60 * 60 * 24));
        
        if (days >= 1) {
            document.getElementById(prefix + 'totalDays').textContent = days;
            const total = days * pricePerNight;
            document.getElementById(prefix + 'totalPrice').textContent = total.toLocaleString(undefined, {minimumFractionDigits: 2});
            submitBtn.disabled = false;
        } else {
            document.getElementById(prefix + 'totalDays').textContent = '0';
            document.getElementById(prefix + 'totalPrice').textContent = '0.00';
            submitBtn.disabled = true;
        }
    } else {
        submitBtn.disabled = true;
    }
}

// Modal Helpers
function openModal(id) {
    document.getElementById(id).classList.add('active');
    document.body.style.overflow = 'hidden';
}
function closeModal(id) {
    document.getElementById(id).classList.remove('active');
    document.body.style.overflow = '';
}
document.querySelectorAll('.modal-overlay').forEach(el => {
    el.addEventListener('click', e => { if(e.target === el) closeModal(el.id); });
});

function openCreateModal() {
    document.getElementById('createForm').reset();
    document.getElementById('c_totalDays').textContent = '0';
    document.getElementById('c_totalPrice').textContent = '0.00';
    document.getElementById('c_submitBtn').disabled = true;
    
    // Trigger price calc for default selected room type to update the "Rs. 0" label
    calculatePrice('create');
    
    openModal('createModal');
}

function openEditModal(resNo, name, mobile, address, type, cin, cout) {
    document.getElementById('e_resNo').value = resNo;
    document.getElementById('e_customerName').value = name;
    document.getElementById('e_customerMobileNum').value = mobile;
    document.getElementById('e_customerAddress').value = address;
    document.getElementById('e_roomType').value = type;
    document.getElementById('e_checkIn').value = cin;
    document.getElementById('e_checkOut').value = cout;
    
    calculatePrice('edit');
    openModal('editModal');
}

// Search & Filter
function filterTable() {
    const term = document.getElementById('searchInput').value.toLowerCase();
    const filterType = document.getElementById('typeFilter').value;
    const rows = document.querySelectorAll('#resTableBody tr');
    let visibleCount = 0;
    
    rows.forEach(row => {
        // Skip the "empty" message row if present
        if(row.children.length === 1) return;
        
        const rowType = row.dataset.type;
        const text = row.textContent.toLowerCase();
        
        const matchesTerm = text.includes(term);
        const matchesType = (filterType === 'ALL' || rowType === filterType);
        
        if (matchesTerm && matchesType) {
            row.style.display = '';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });
    
    document.getElementById('tableRowCount').textContent = `(${visibleCount} records)`;
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
