package com.oceanview.servlet.staff;

import com.oceanview.dao.UserDAO;
import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * ProfileServlet — Allows staff members to view and update their own profile.
 *
 * GET /staff/profile → Display current user's profile
 * POST /staff/profile → Update user's profile details (mobile, address,
 * password)
 */
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Fetch fresh copy from DB
        User currentUser = (User) session.getAttribute("user");
        User freshUser = userDAO.getUserById(currentUser.getId());

        req.setAttribute("profileUser", freshUser);

        // Pass flash messages if any
        req.setAttribute("flashSuccess", session.getAttribute("flashSuccess"));
        req.setAttribute("flashError", session.getAttribute("flashError"));
        session.removeAttribute("flashSuccess");
        session.removeAttribute("flashError");

        req.getRequestDispatcher("/WEB-INF/views/staff/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        String action = req.getParameter("action");
        if ("update".equals(action)) {
            String mobileNum = sanitize(req.getParameter("mobileNum"));
            String address = sanitize(req.getParameter("address"));
            String password = req.getParameter("password"); // Optional

            // Create a user object with updated fields
            // Note: username won't be changed by the staff, but UserDAO requires it for the
            // update query
            User userToUpdate = new User();
            userToUpdate.setId(currentUser.getId());
            userToUpdate.setUsername(currentUser.getUsername());
            userToUpdate.setMobileNum(mobileNum);
            userToUpdate.setAddress(address);

            if (password != null && !password.isEmpty()) {
                userToUpdate.setPassword(password); // UserDAO will hash this
            } else {
                userToUpdate.setPassword(null); // Indicates no password change
            }

            boolean success = userDAO.updateUser(userToUpdate);

            if (success) {
                session.setAttribute("flashSuccess", "Profile updated successfully.");

                // Update session object with new data so the header/UI stays in sync
                User updatedUser = userDAO.getUserById(currentUser.getId());
                session.setAttribute("user", updatedUser);
            } else {
                session.setAttribute("flashError", "Failed to update profile. Please try again.");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/staff/profile");
    }

    private String sanitize(String input) {
        return input == null ? null : input.trim();
    }
}
