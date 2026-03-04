package com.oceanview.servlet.admin;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Admin BillingServlet — Handles displaying and printing reservation invoices.
 *
 * GET /admin/billing → Show search page to find a reservation to bill
 * GET /admin/billing?resNo=X → Show the invoice for reservation X
 */
public class BillingServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String resNo = req.getParameter("resNo");

        if (resNo != null && !resNo.trim().isEmpty()) {
            // Find the specific reservation
            Reservation res = reservationDAO.getReservationByResNo(resNo.trim());

            if (res != null) {
                req.setAttribute("reservation", res);
                // Also pass current date for the invoice date
                req.setAttribute("currentDate", new java.util.Date());
            } else {
                req.setAttribute("flashError", "Reservation not found: " + resNo);
            }
        }

        // Just forward to the JSP. The JSP handles both the search view and the invoice
        // view.
        req.getRequestDispatcher("/WEB-INF/views/admin/billing.jsp").forward(req, resp);
    }
}
