package com.oceanview.filter;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * AdminAuthFilter — intercepts all requests to /admin/* and ensures:
 * 1. The user is authenticated (has a valid session).
 * 2. The user's role is "ADMIN".
 *
 * If either check fails, the user is redirected to the login page.
 */
public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No initialization needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) request;
        HttpServletResponse httpResp = (HttpServletResponse) response;

        HttpSession session = httpReq.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        boolean isAdmin = isLoggedIn && "ADMIN".equals(session.getAttribute("userRole"));

        if (!isLoggedIn) {
            // Not logged in → redirect to login
            httpResp.sendRedirect(httpReq.getContextPath() + "/login");
            return;
        }

        if (!isAdmin) {
            // Authenticated but not ADMIN → 403 Forbidden
            httpResp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access Denied: You do not have ADMIN privileges.");
            return;
        }

        // Prevent caching of admin pages
        httpResp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResp.setHeader("Pragma", "no-cache");
        httpResp.setDateHeader("Expires", 0);

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
