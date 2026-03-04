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
    <title>Billing & Invoice &mdash; Ocean View Resort</title>
    <meta name="description" content="Generate and print customer invoices." />

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />

    <style>
        /* ---- Search Box Layout ---- */
        .search-container {
            max-width: 600px;
            margin: 0 auto;
            text-align: center;
            padding: 40px 20px;
        }

        .search-icon-big {
            font-size: 4rem;
            color: var(--primary-light);
            margin-bottom: 20px;
            opacity: 0.8;
        }

        .search-title {
            font-family: var(--font-heading);
            font-size: 1.8rem;
            margin-bottom: 10px;
            color: var(--text-white);
        }

        .search-subtitle {
            color: var(--text-muted);
            margin-bottom: 30px;
        }

        .bill-search-form {
            display: flex;
            gap: 10px;
            background: rgba(255,255,255,0.05);
            padding: 20px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-glass);
        }

        .bill-search-form .form-input {
            margin-bottom: 0;
            padding-left: 20px;
            font-size: 1rem;
            text-align: center;
            letter-spacing: 1px;
        }

        .bill-search-form .btn-primary-custom {
            width: auto;
            padding: 10px 30px;
            white-space: nowrap;
        }

        /* ---- Invoice Layout (A4 styled, viewable on screen) ---- */
        .invoice-wrapper {
            max-width: 800px;
            margin: 0 auto;
            background: #ffffff;
            color: #1a1a1a;
            border-radius: var(--radius-sm);
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            overflow: hidden;
            position: relative;
        }

        .invoice-header {
            background: #0B1E30; /* Dark blue matching resort theme */
            color: #fff;
            padding: 40px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .invoice-brand {
            display: flex;
            gap: 16px;
            align-items: center;
        }

        .invoice-brand-logo {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, var(--primary-light), var(--primary-dark));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        }

        .invoice-brand-text h2 {
            margin: 0;
            font-family: var(--font-heading);
            font-size: 1.8rem;
            color: #fff;
        }
        .invoice-brand-text h2 span { color: var(--accent); }
        .invoice-brand-text p {
            margin: 0;
            font-size: 0.8rem;
            color: rgba(255,255,255,0.7);
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        .invoice-title {
            text-align: right;
        }
        .invoice-title h1 {
            color: var(--accent);
            margin: 0 0 5px 0;
            font-size: 2.2rem;
            font-family: var(--font-heading);
            text-transform: uppercase;
            letter-spacing: 2px;
        }
        .invoice-title p {
            margin: 0;
            font-size: 0.9rem;
            color: rgba(255,255,255,0.8);
        }

        .invoice-body {
            padding: 40px;
        }

        .invoice-meta {
            display: flex;
            justify-content: space-between;
            margin-bottom: 40px;
        }

        .meta-box h6 {
            font-size: 0.75rem;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 6px;
        }
        .meta-box p {
            margin: 0;
            font-size: 0.95rem;
            font-weight: 500;
            color: #222;
        }

        .customer-card {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            border-left: 4px solid var(--primary-light);
            margin-bottom: 30px;
        }

        .customer-card h4 {
            margin-top: 0;
            margin-bottom: 15px;
            font-size: 1.1rem;
            color: #333;
        }

        .customer-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            font-size: 0.9rem;
            color: #555;
        }

        .detail-item i {
            color: var(--primary-light);
            margin-right: 8px;
            width: 16px;
            text-align: center;
        }

        .invoice-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }

        .invoice-table th {
            background: #eef2f5;
            color: #444;
            padding: 12px 16px;
            text-align: left;
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            border-bottom: 2px solid #ddd;
        }

        .invoice-table td {
            padding: 16px;
            border-bottom: 1px solid #eee;
            color: #333;
            font-size: 0.95rem;
            vertical-align: middle;
        }

        .invoice-totals {
            width: 350px;
            margin-left: auto;
            background: #f8f9fa;
            padding: 24px;
            border-radius: 8px;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            font-size: 0.9rem;
            color: #555;
        }

        .total-row.grand-total {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 2px solid #ddd;
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--primary-dark);
        }

        .invoice-footer {
            margin-top: 40px;
            text-align: center;
            padding-top: 20px;
            border-top: 1px dashed #ccc;
            color: #777;
            font-size: 0.85rem;
        }

        .print-actions {
            text-align: center;
            margin-top: 30px;
            margin-bottom: 50px;
            display: flex;
            gap: 15px;
            justify-content: center;
        }

        /* ---- Mobile overrides ---- */
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
            .bill-search-form { flex-direction: column; }
            .bill-search-form .btn-primary-custom { width: 100%; }
            .invoice-header { flex-direction: column; gap: 20px; text-align: center; }
            .invoice-title { text-align: center; }
            .customer-details { grid-template-columns: 1fr; }
            .invoice-totals { width: 100%; }
        }

        /* ---- Print Styles ---- */
        @media print {
            body { background: #fff; padding: 0; margin: 0; }
            .sidebar, .top-bar, .print-actions, .app-wrapper, .main-content {
                margin: 0 !important;
                padding: 0 !important;
                display: block;
                background: none !important;
                border: none !important;
                box-shadow: none !important;
                min-height: auto !important;
            }
            .sidebar, .top-bar, .print-actions { display: none !important; }
            .invoice-wrapper {
                box-shadow: none !important;
                margin: 0 !important;
                padding: 0 !important;
                max-width: 100% !important;
                width: 100% !important;
            }
            .invoice-header {
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
                background: #0B1E30 !important;
                color: #fff !important;
            }
            .customer-card {
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
                background: #f8f9fa !important;
            }
            .invoice-totals {
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
                background: #f8f9fa !important;
            }
            .badge {
                border: 1px solid #ccc !important;
                color: #000 !important;
            }
            @page { margin: 10mm; }
        }
    </style>
</head>
<body>

<div class="app-wrapper">

    <!-- ===========================
         SIDEBAR (Hidden on print)
    =========================== -->
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp">
        <jsp:param name="activePage" value="admin-billing"/>
    </jsp:include>

    <!-- ===========================
         MAIN CONTENT
    =========================== -->
    <main class="main-content">

        <!-- Top Bar (Hidden on print) -->
        <div class="top-bar d-print-none">
            <div>
                <button class="hamburger-btn" id="hamburgerBtn" aria-label="Toggle Sidebar">
                    <i class="bi bi-list"></i>
                </button>
            </div>
            <div>
                <div class="page-title">Billing center</div>
                <div class="page-subtitle">Generate customer invoices</div>
            </div>
            <div></div>
        </div>

        <div class="content-area">

            <!-- Flash Error -->
            <c:if test="${not empty flashError}">
                <div class="alert-custom alert-error mb-4 d-print-none" style="max-width:800px; margin:0 auto;">
                    <i class="bi bi-exclamation-circle-fill"></i> ${flashError}
                </div>
            </c:if>

            <c:choose>
                <%-- IF NO RESERVATION SELECTED -> SHOW SEARCH BOX --%>
                <c:when test="${empty reservation}">
                    <div class="glass-card search-container">
                        <div class="search-icon-big"><i class="bi bi-receipt-cutoff"></i></div>
                        <h2 class="search-title">Find an Invoice</h2>
                        <p class="search-subtitle">Enter the reservation number below to generate an invoice.</p>

                        <form action="${pageContext.request.contextPath}/admin/billing" method="get" class="bill-search-form">
                            <input type="text" name="resNo" class="form-input" placeholder="e.g. RES-0001" required autocomplete="off" />
                            <button type="submit" class="btn-primary-custom" style="padding:13px 28px;">
                                <i class="bi bi-search me-2"></i>Search
                            </button>
                        </form>
                    </div>
                </c:when>

                <%-- IF RESERVATION FOUND -> SHOW INVOICE --%>
                <c:otherwise>
                    <!-- Invoice Container -->
                    <div class="invoice-wrapper" id="printableInvoice">
                        <!-- Header -->
                        <div class="invoice-header">
                            <div class="invoice-brand">
                                <div class="invoice-brand-logo"><i class="bi bi-building"></i></div>
                                <div class="invoice-brand-text">
                                    <h2>Ocean View <span>Resort</span></h2>
                                    <p>Galle Road, Colombo, Sri Lanka</p>
                                </div>
                            </div>
                            <div class="invoice-title">
                                <h1>INVOICE</h1>
                                <p># INV-${reservation.resNo.replace("RES-", "")}</p>
                            </div>
                        </div>

                        <!-- Body -->
                        <div class="invoice-body">
                            <!-- Meta Row -->
                            <div class="invoice-meta">
                                <div class="meta-box">
                                    <h6>Date Issued</h6>
                                    <p><fmt:formatDate value="${currentDate}" pattern="dd MMM yyyy" /></p>
                                </div>
                                <div class="meta-box" style="text-align:right;">
                                    <h6>Reservation No.</h6>
                                    <p>${reservation.resNo}</p>
                                </div>
                            </div>

                            <!-- Customer Info -->
                            <div class="customer-card">
                                <h4>Billed To</h4>
                                <div class="customer-details">
                                    <div class="detail-item">
                                        <i class="bi bi-person-fill"></i>
                                        <strong>${reservation.customerName}</strong>
                                    </div>
                                    <div class="detail-item">
                                        <i class="bi bi-telephone-fill"></i>
                                        ${reservation.customerMobileNum}
                                    </div>
                                    <div class="detail-item" style="grid-column: 1 / -1;">
                                        <i class="bi bi-geo-alt-fill"></i>
                                        ${reservation.customerAddress}
                                    </div>
                                </div>
                            </div>

                            <!-- Items Table -->
                            <table class="invoice-table">
                                <thead>
                                    <tr>
                                        <th>Description</th>
                                        <th>Check In</th>
                                        <th>Check Out</th>
                                        <th style="text-align:center;">Nights</th>
                                        <th style="text-align:right;">Amount (Rs.)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <div style="font-weight:600; margin-bottom:4px;">
                                                Accommodation -
                                                <span style="color:var(--primary-dark);">${reservation.roomType} Room</span>
                                            </div>
                                            <div style="font-size:0.8rem; color:#777;">
                                                Processed by: ${reservation.reservedByUsername} (${reservation.reservationBy})
                                            </div>
                                        </td>
                                        <td><fmt:formatDate value="${reservation.checkIn}" pattern="dd/MM/yyyy" /></td>
                                        <td><fmt:formatDate value="${reservation.checkOut}" pattern="dd/MM/yyyy" /></td>
                                        <td style="text-align:center; font-weight:600;">${reservation.totalDays}</td>
                                        <td style="text-align:right;">
                                            <fmt:formatNumber value="${reservation.totalPrice}" pattern="#,##0.00" />
                                        </td>
                                    </tr>
                                </tbody>
                            </table>

                            <!-- Totals Box -->
                            <div style="display:flex; justify-content:flex-end;">
                                <div class="invoice-totals">
                                    <div class="total-row">
                                        <span>Subtotal</span>
                                        <span>Rs. <fmt:formatNumber value="${reservation.totalPrice}" pattern="#,##0.00" /></span>
                                    </div>
                                    <div class="total-row">
                                        <span>Tax &amp; Service Charge</span>
                                        <span>Included</span>
                                    </div>
                                    <div class="total-row grand-total">
                                        <span>Total Due</span>
                                        <span>Rs. <fmt:formatNumber value="${reservation.totalPrice}" pattern="#,##0.00" /></span>
                                    </div>
                                </div>
                            </div>

                            <!-- Footer -->
                            <div class="invoice-footer">
                                <p>Thank you for choosing Ocean View Resort!</p>
                                <p style="font-size:0.75rem; margin-top:5px;">
                                    If you have any questions concerning this invoice, contact our reservations desk at +94 11 234 5678.
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Print / Action Buttons (Hidden on Print) -->
                    <div class="print-actions d-print-none">
                        <a href="${pageContext.request.contextPath}/admin/billing" class="btn-primary-custom" style="width:auto; padding:12px 24px; background:rgba(255,255,255,0.1); box-shadow:none;">
                            <i class="bi bi-arrow-left me-2"></i>Back to Search
                        </a>
                        <button onclick="window.print()" class="btn-accent" style="width:auto; padding:12px 30px; font-size:1rem;">
                            <i class="bi bi-printer-fill me-2"></i>Print Invoice
                        </button>
                    </div>

                </c:otherwise>
            </c:choose>

        </div><!-- /content-area -->
    </main>
</div>


</body>
</html>
