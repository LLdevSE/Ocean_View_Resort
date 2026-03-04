package com.oceanview.servlet.staff;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.model.Reservation;
import com.oceanview.model.Room;
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
 * StaffReservationServlet — Handles reservations assigned to the logged-in
 * staff member.
 *
 * GET /staff/reservations → List specific staff member's reservations
 * POST /staff/reservations?action=create → Create new reservation for this
 * staff member
 * POST /staff/reservations?action=update → Update an existing reservation
 */
public class StaffReservationServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        loadPageData(req);
        req.getRequestDispatcher("/WEB-INF/views/staff/reservations.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("create".equals(action)) {
            handleCreate(req, resp);
        } else if ("update".equals(action)) {
            handleUpdate(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/staff/reservations");
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        Reservation res = new Reservation();
        res.setCustomerName(sanitize(req.getParameter("customerName")));
        res.setCustomerMobileNum(sanitize(req.getParameter("customerMobileNum")));
        res.setCustomerAddress(sanitize(req.getParameter("customerAddress")));
        res.setRoomType(req.getParameter("roomType"));
        res.setCheckIn(Date.valueOf(req.getParameter("checkIn")));
        res.setCheckOut(Date.valueOf(req.getParameter("checkOut")));
        res.setReservationBy(currentUser.getStaffId()); // Force bind to current staff member

        boolean success = reservationDAO.createReservation(res);

        if (success) {
            session.setAttribute("flashSuccess", "Reservation created successfully!");
        } else {
            session.setAttribute("flashError", "Failed to create reservation. Date conflict or no rooms available.");
        }

        resp.sendRedirect(req.getContextPath() + "/staff/reservations");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        String resNo = req.getParameter("resNo");
        if (resNo == null || resNo.trim().isEmpty()) {
            session.setAttribute("flashError", "Invalid reservation ID.");
            resp.sendRedirect(req.getContextPath() + "/staff/reservations");
            return;
        }

        // Before updating, verify this staff member actually owns this reservation
        // Alternatively, since staff can only access their UI, they only see their IDs,
        // but for strict security we could check ownership here.
        Reservation existingRes = reservationDAO.getReservationByResNo(resNo.trim());
        if (existingRes == null || !currentUser.getStaffId().equals(existingRes.getReservationBy())) {
            session.setAttribute("flashError", "Unauthorized to update this reservation.");
            resp.sendRedirect(req.getContextPath() + "/staff/reservations");
            return;
        }

        Reservation res = new Reservation();
        res.setResNo(resNo.trim());
        res.setCustomerName(sanitize(req.getParameter("customerName")));
        res.setCustomerMobileNum(sanitize(req.getParameter("customerMobileNum")));
        res.setCustomerAddress(sanitize(req.getParameter("customerAddress")));
        res.setRoomType(req.getParameter("roomType"));
        res.setCheckIn(Date.valueOf(req.getParameter("checkIn")));
        res.setCheckOut(Date.valueOf(req.getParameter("checkOut")));
        res.setReservationBy(currentUser.getStaffId());

        boolean success = reservationDAO.updateReservation(res);

        if (success) {
            session.setAttribute("flashSuccess", "Reservation updated successfully!");
        } else {
            session.setAttribute("flashError", "Failed to update reservation. Date conflict or invalid data.");
        }

        resp.sendRedirect(req.getContextPath() + "/staff/reservations");
    }

    private void loadPageData(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        User currentUser = null;
        if (session != null) {
            currentUser = (User) session.getAttribute("user");
        }

        if (currentUser != null) {
            // Load ALL reservations for staff members (same as admin)
            List<Reservation> allReservations = reservationDAO.getAllReservations();
            req.setAttribute("reservationList", allReservations);
            req.setAttribute("totalStaffReservations", allReservations.size());
        }

        // Available room counts for the UI (dashboard stats)
        req.setAttribute("availableStandard", roomDAO.getAvailableRoomCountByType(Room.RoomType.STANDARD.name()));
        req.setAttribute("availableDeluxe", roomDAO.getAvailableRoomCountByType(Room.RoomType.DELUXE.name()));
        req.setAttribute("availableSuite", roomDAO.getAvailableRoomCountByType(Room.RoomType.SUITE.name()));

        if (session != null) {
            req.setAttribute("flashSuccess", session.getAttribute("flashSuccess"));
            req.setAttribute("flashError", session.getAttribute("flashError"));
            session.removeAttribute("flashSuccess");
            session.removeAttribute("flashError");
        }
    }

    private String sanitize(String input) {
        return input == null ? null : input.trim();
    }
}
