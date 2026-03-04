package com.oceanview.servlet.admin;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.UserDAO;
import com.oceanview.model.Reservation;
import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * Admin ReservationServlet — Full CRUD for reservations (Admin role only).
 *
 * GET /admin/reservations → list all reservations
 * GET /admin/reservations?action=edit&resNo=RES-0001 → load edit modal
 * POST /admin/reservations?action=create → create new reservation
 * POST /admin/reservations?action=update → update existing reservation
 * POST /admin/reservations?action=delete → delete reservation
 */
public class ReservationServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("edit".equals(action)) {
            String resNo = req.getParameter("resNo");
            Reservation res = reservationDAO.getReservationByResNo(resNo);
            req.setAttribute("editReservation", res);
        }

        // Load data for the page
        loadPageAttributes(req);
        req.getRequestDispatcher("/WEB-INF/views/admin/reservations.jsp").forward(req, resp);
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
            resp.sendRedirect(req.getContextPath() + "/admin/reservations");
        }
    }

    // ---- Handlers ----

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        try {
            Reservation r = buildFromRequest(req);
            HttpSession session = req.getSession(false);
            User user = (User) session.getAttribute("user");
            r.setReservationBy(user.getStaffId() != null ? user.getStaffId() : "ADMIN");

            boolean success = reservationDAO.createReservation(r);
            if (success) {
                req.getSession().setAttribute("flashSuccess", "Reservation created successfully!");
            } else {
                req.getSession().setAttribute("flashError", "Failed to create reservation. Please try again.");
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", "Error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/reservations");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        try {
            Reservation r = buildFromRequest(req);
            r.setResNo(req.getParameter("resNo"));

            boolean success = reservationDAO.updateReservation(r);
            if (success) {
                req.getSession().setAttribute("flashSuccess", "Reservation updated successfully!");
            } else {
                req.getSession().setAttribute("flashError", "Failed to update reservation.");
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", "Error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/reservations");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String resNo = req.getParameter("resNo");
        if (resNo != null && !resNo.isEmpty()) {
            boolean success = reservationDAO.deleteReservation(resNo);
            if (success) {
                req.getSession().setAttribute("flashSuccess", "Reservation " + resNo + " deleted.");
            } else {
                req.getSession().setAttribute("flashError", "Failed to delete reservation " + resNo + ".");
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/reservations");
    }

    // ---- Shared attributes ----

    private void loadPageAttributes(HttpServletRequest req) {
        List<Reservation> reservations = reservationDAO.getAllReservations();
        req.setAttribute("reservations", reservations);
        req.setAttribute("totalReservations", reservations.size());
        req.setAttribute("totalRooms", roomDAO.countAll());
        req.setAttribute("availableRooms", roomDAO.countByStatus("AVAILABLE"));
        req.setAttribute("totalStaff", userDAO.getAllStaff().size());

        // Flash messages from session
        HttpSession session = req.getSession(false);
        if (session != null) {
            req.setAttribute("flashSuccess", session.getAttribute("flashSuccess"));
            req.setAttribute("flashError", session.getAttribute("flashError"));
            session.removeAttribute("flashSuccess");
            session.removeAttribute("flashError");
        }
    }

    // ---- Build reservation from form params ----

    private Reservation buildFromRequest(HttpServletRequest req) {
        Reservation r = new Reservation();
        r.setCustomerName(req.getParameter("customerName"));
        r.setCustomerMobileNum(req.getParameter("customerMobile"));
        r.setCustomerAddress(req.getParameter("customerAddress"));
        r.setRoomType(req.getParameter("roomType"));
        r.setCheckIn(Date.valueOf(req.getParameter("checkIn")));
        r.setCheckOut(Date.valueOf(req.getParameter("checkOut")));

        String roomIdStr = req.getParameter("roomId");
        if (roomIdStr != null && !roomIdStr.isEmpty()) {
            r.setRoomId(Integer.parseInt(roomIdStr));
        }
        return r;
    }
}
