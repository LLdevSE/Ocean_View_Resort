package com.oceanview.filter;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * StaffAuthFilter — intercepts all requests to /staff/* and ensures:
 * 1. The user is authenticated (has a valid session).
 * 2. The user's role is either "STAFF" or "ADMIN" (admin can also access staff
 * views).
 */
public class StaffAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) request;
        HttpServletResponse httpResp = (HttpServletResponse) response;

        HttpSession session = httpReq.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        String role = isLoggedIn ? (String) session.getAttribute("userRole") : null;
        boolean hasAccess = "STAFF".equals(role) || "ADMIN".equals(role);

        if (!isLoggedIn) {
            httpResp.sendRedirect(httpReq.getContextPath() + "/login");
            return;
        }

        if (!hasAccess) {
            httpResp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied.");
            return;
        }

        // Prevent caching
        httpResp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResp.setHeader("Pragma", "no-cache");
        httpResp.setDateHeader("Expires", 0);

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
