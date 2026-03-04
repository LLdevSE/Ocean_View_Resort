package com.oceanview.servlet.admin;

import com.oceanview.dao.UserDAO;
import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Admin StaffServlet — Full CRUD for staff members (Admin role only).
 *
 * GET /admin/staff → list all staff
 * GET /admin/staff?action=edit&id=3 → populate edit modal
 * POST /admin/staff?action=create → create new staff (calls stored procedure)
 * POST /admin/staff?action=update → update existing staff
 * POST /admin/staff?action=delete → delete a staff member
 */
public class StaffServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("edit".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                User staff = userDAO.getUserById(Integer.parseInt(idStr));
                req.setAttribute("editStaff", staff);
            }
        }

        loadPageAttributes(req);
        req.getRequestDispatcher("/WEB-INF/views/admin/staff.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("create".equals(action)) {
            handleCreate(req, resp);
        } else if ("update".equals(action)) {
            handleUpdate(req, resp);
        } else if ("delete".equals(action)) {
            handleDelete(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/staff");
        }
    }

    // ---- Handlers ----

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String username = sanitize(req.getParameter("username"));
        String password = req.getParameter("password");
        String mobile = sanitize(req.getParameter("mobileNum"));
        String address = sanitize(req.getParameter("address"));

        // Validate
        if (username == null || username.isEmpty() ||
                password == null || password.isEmpty()) {
            req.getSession().setAttribute("flashError", "Username and password are required.");
            resp.sendRedirect(req.getContextPath() + "/admin/staff");
            return;
        }

        if (userDAO.usernameExists(username)) {
            req.getSession().setAttribute("flashError",
                    "Username '" + username + "' already exists. Please choose another.");
            resp.sendRedirect(req.getContextPath() + "/admin/staff");
            return;
        }

        User newStaff = new User();
        newStaff.setUsername(username);
        newStaff.setPassword(password); // UserDAO will BCrypt-hash via stored procedure
        newStaff.setMobileNum(mobile);
        newStaff.setAddress(address);
        newStaff.setRole("STAFF");

        boolean success = userDAO.createUser(newStaff);
        if (success) {
            req.getSession().setAttribute("flashSuccess",
                    "Staff member '" + username + "' created successfully!");
        } else {
            req.getSession().setAttribute("flashError",
                    "Failed to create staff member. Please try again.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/staff");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String idStr = req.getParameter("id");
        String username = sanitize(req.getParameter("username"));
        String password = req.getParameter("password"); // may be empty (no change)
        String mobile = sanitize(req.getParameter("mobileNum"));
        String address = sanitize(req.getParameter("address"));

        if (idStr == null || username == null || username.isEmpty()) {
            req.getSession().setAttribute("flashError", "Invalid update request.");
            resp.sendRedirect(req.getContextPath() + "/admin/staff");
            return;
        }

        User staff = new User();
        staff.setId(Integer.parseInt(idStr));
        staff.setUsername(username);
        // Only update password if provided
        staff.setPassword((password != null && !password.isEmpty()) ? password : null);
        staff.setMobileNum(mobile);
        staff.setAddress(address);

        boolean success = userDAO.updateUser(staff);
        if (success) {
            req.getSession().setAttribute("flashSuccess",
                    "Staff member updated successfully!");
        } else {
            req.getSession().setAttribute("flashError",
                    "Failed to update staff member.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/staff");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            int id = Integer.parseInt(idStr);

            // Prevent deleting self
            HttpSession session = req.getSession(false);
            if (session != null) {
                Integer currentUserId = (Integer) session.getAttribute("userId");
                if (currentUserId != null && currentUserId == id) {
                    req.getSession().setAttribute("flashError",
                            "You cannot delete your own account.");
                    resp.sendRedirect(req.getContextPath() + "/admin/staff");
                    return;
                }
            }

            boolean success = userDAO.deleteUser(id);
            if (success) {
                req.getSession().setAttribute("flashSuccess", "Staff member deleted successfully.");
            } else {
                req.getSession().setAttribute("flashError",
                        "Failed to delete staff member. They may have existing reservations.");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/staff");
    }

    // ---- Shared page attributes ----

    private void loadPageAttributes(HttpServletRequest req) {
        req.setAttribute("staffList", userDAO.getAllStaff());
        req.setAttribute("totalStaff", userDAO.getAllStaff().size());

        HttpSession session = req.getSession(false);
        if (session != null) {
            req.setAttribute("flashSuccess", session.getAttribute("flashSuccess"));
            req.setAttribute("flashError", session.getAttribute("flashError"));
            session.removeAttribute("flashSuccess");
            session.removeAttribute("flashError");
        }
    }

    private String sanitize(String input) {
        return (input == null) ? null : input.trim();
    }
}
