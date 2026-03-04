<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.oceanview.model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    String sName    = sessionUser != null ? sessionUser.getUsername() : "User";
    String sInitial = sessionUser != null ? sessionUser.getInitial()  : "U";
    String sRole    = sessionUser != null ? sessionUser.getRole()     : "GUEST";
%>

<!-- ===========================
     SHARED SIDEBAR COMPONENT
=========================== -->
<aside class="sidebar" id="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon"><i class="bi bi-building" style="color:#fff;"></i></div>
        <div class="resort-name">Ocean View<br><span>Resort</span></div>
        <div class="resort-tagline">
            <%= "ADMIN".equals(sRole) ? "Management Portal" : "Staff Portal" %>
        </div>
    </div>

    <nav class="sidebar-nav">
        <% if ("ADMIN".equals(sRole)) { %>
            <!-- Admin Navigation -->
            <div class="nav-section-title">Main Menu</div>
            <a href="${pageContext.request.contextPath}/admin/reservations"
               class="nav-item ${param.activePage == 'admin-reservations' ? 'active' : ''}">
                <i class="bi bi-calendar2-check"></i> Reservations
            </a>

            <a href="${pageContext.request.contextPath}/admin/staff"
               class="nav-item ${param.activePage == 'admin-staff' ? 'active' : ''}">
                <i class="bi bi-people"></i> Staff Management
            </a>

            <div class="nav-section-title">Billing</div>
            <a href="${pageContext.request.contextPath}/admin/billing"
               class="nav-item ${param.activePage == 'admin-billing' ? 'active' : ''}">
                <i class="bi bi-receipt"></i> Billing &amp; Invoices
            </a>

        <% } else if ("STAFF".equals(sRole)) { %>
            <!-- Staff Navigation -->
            <div class="nav-section-title">Main Menu</div>
            <a href="${pageContext.request.contextPath}/staff/reservations" 
               class="nav-item ${param.activePage == 'staff-reservations' ? 'active' : ''}">
                <i class="bi bi-calendar2-check"></i> My Reservations
            </a>
            
            <div class="nav-section-title">Personal</div>
            <a href="${pageContext.request.contextPath}/staff/profile" 
               class="nav-item ${param.activePage == 'staff-profile' ? 'active' : ''}">
                <i class="bi bi-person-circle"></i> My Profile
            </a>
        <% } %>
    </nav>

    <div class="sidebar-footer">
        <div class="user-info-sidebar">
            <div class="user-avatar"><%= sInitial %></div>
            <div class="user-info-text">
                <div class="user-name"><%= sName %></div>
                <div class="user-role"><%= "ADMIN".equals(sRole) ? "Administrator" : "Staff Member" %></div>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
            <i class="bi bi-box-arrow-left"></i> Sign Out
        </a>
    </div>
</aside>

<!-- Sidebar Overlay (mobile) -->
<div class="sidebar-overlay" id="sidebarOverlay"
     style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.6);
            z-index:999; backdrop-filter:blur(3px);"
     onclick="closeSidebar()"></div>

<script>
// =============================================
// SHARED MOBILE SIDEBAR SCRIPT
// =============================================
function closeSidebar() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebarOverlay');
    if (sidebar) sidebar.classList.remove('open');
    if (overlay) overlay.style.display = 'none';
}

document.addEventListener("DOMContentLoaded", () => {
    const hamburgerBtn = document.getElementById('hamburgerBtn');
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebarOverlay');

    if (hamburgerBtn && sidebar && overlay) {
        hamburgerBtn.addEventListener('click', () => {
            sidebar.classList.toggle('open');
            const isOpen = sidebar.classList.contains('open');
            overlay.style.display = isOpen ? 'block' : 'none';
        });
    }
});
</script>
