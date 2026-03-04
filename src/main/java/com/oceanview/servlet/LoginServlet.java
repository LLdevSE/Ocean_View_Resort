package com.oceanview.servlet;

import com.oceanview.dao.UserDAO;
import com.oceanview.model.User;

import javax.servlet.ServletException;

import javax.servlet.http.*;
import java.io.IOException;

/**
 * LoginServlet
 * Handles GET → display login page (login.jsp)
 * Handles POST → validate credentials, create session, redirect by role
 */

public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // If already authenticated, redirect to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            redirectByRole((String) session.getAttribute("userRole"), req, resp);
            return;
        }

        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = sanitize(req.getParameter("username"));
        String password = req.getParameter("password");

        // --- Basic validation ---
        if (username == null || username.isEmpty() ||
                password == null || password.isEmpty()) {
            req.setAttribute("errorMsg", "Username and password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // --- Authenticate ---
        User user = userDAO.authenticate(username, password);

        if (user == null) {
            req.setAttribute("errorMsg", "Invalid username or password. Please try again.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // --- Create session ---
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("userRole", user.getRole());
        session.setAttribute("userId", user.getId());
        session.setAttribute("username", user.getUsername());
        session.setMaxInactiveInterval(30 * 60); // 30 minutes

        // --- Redirect to appropriate dashboard ---
        redirectByRole(user.getRole(), req, resp);
    }

    private void redirectByRole(String role, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if ("ADMIN".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/admin/reservations");
        } else {
            resp.sendRedirect(req.getContextPath() + "/staff/reservations");
        }
    }

    private String sanitize(String input) {
        return (input == null) ? null : input.trim();
    }
}
