package com.oceanview.dao;

import com.oceanview.db.DatabaseConnectionManager;
import com.oceanview.model.Reservation;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ReservationDAO — DAO Pattern
 * Handles all SQL for the `reservations` table.
 */
public class ReservationDAO {

    private static final Logger LOGGER = Logger.getLogger(ReservationDAO.class.getName());
    private final DatabaseConnectionManager dbManager = DatabaseConnectionManager.getInstance();

    // ---- READ ----

    /**
     * Returns all reservations, joined with the booking staff member's username.
     */
    public List<Reservation> getAllReservations() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.res_no, r.customer_name, r.customer_mobile_num, " +
                "       r.customer_address, r.room_type, r.room_id, " +
                "       r.check_in, r.check_out, r.total_days, r.total_price, " +
                "       r.reservation_by, u.username AS reserved_by_username " +
                "FROM reservations r " +
                "LEFT JOIN users u ON r.reservation_by = u.staff_id " +
                "ORDER BY r.created_at DESC";

        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next())
                list.add(mapRow(rs));

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all reservations", e);
        }
        return list;
    }

    /**
     * Returns reservations created by a specific staff member (by staff_id).
     */
    public List<Reservation> getReservationsByStaff(String staffId) {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.res_no, r.customer_name, r.customer_mobile_num, " +
                "       r.customer_address, r.room_type, r.room_id, " +
                "       r.check_in, r.check_out, r.total_days, r.total_price, " +
                "       r.reservation_by, u.username AS reserved_by_username " +
                "FROM reservations r " +
                "LEFT JOIN users u ON r.reservation_by = u.staff_id " +
                "WHERE r.reservation_by = ? " +
                "ORDER BY r.created_at DESC";

        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching reservations for staffId: " + staffId, e);
        }
        return list;
    }

    /**
     * Returns a single reservation by its res_no.
     */
    public Reservation getReservationByResNo(String resNo) {
        String sql = "SELECT r.res_no, r.customer_name, r.customer_mobile_num, " +
                "       r.customer_address, r.room_type, r.room_id, " +
                "       r.check_in, r.check_out, r.total_days, r.total_price, " +
                "       r.reservation_by, u.username AS reserved_by_username " +
                "FROM reservations r " +
                "LEFT JOIN users u ON r.reservation_by = u.staff_id " +
                "WHERE r.res_no = ?";

        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, resNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapRow(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching reservation by resNo: " + resNo, e);
        }
        return null;
    }

    // ---- CREATE ----

    /**
     * Inserts a new reservation. res_no, total_days, total_price are SET by
     * triggers.
     */
    public boolean createReservation(Reservation r) {
        String sql = "INSERT INTO reservations " +
                "(customer_name, customer_mobile_num, customer_address, " +
                " room_type, room_id, check_in, check_out, reservation_by) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, r.getCustomerName());
            ps.setString(2, r.getCustomerMobileNum());
            ps.setString(3, r.getCustomerAddress());
            ps.setString(4, r.getRoomType());
            if (r.getRoomId() != null)
                ps.setInt(5, r.getRoomId());
            else
                ps.setNull(5, Types.INTEGER);
            ps.setDate(6, r.getCheckIn());
            ps.setDate(7, r.getCheckOut());
            ps.setString(8, r.getReservationBy());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating reservation", e);
            return false;
        }
    }

    // ---- UPDATE ----

    /**
     * Updates an existing reservation (admin only).
     */
    public boolean updateReservation(Reservation r) {
        String sql = "UPDATE reservations SET " +
                "customer_name=?, customer_mobile_num=?, customer_address=?, " +
                "room_type=?, room_id=?, check_in=?, check_out=? " +
                "WHERE res_no=?";

        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, r.getCustomerName());
            ps.setString(2, r.getCustomerMobileNum());
            ps.setString(3, r.getCustomerAddress());
            ps.setString(4, r.getRoomType());
            if (r.getRoomId() != null)
                ps.setInt(5, r.getRoomId());
            else
                ps.setNull(5, Types.INTEGER);
            ps.setDate(6, r.getCheckIn());
            ps.setDate(7, r.getCheckOut());
            ps.setString(8, r.getResNo());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating reservation: " + r.getResNo(), e);
            return false;
        }
    }

    // ---- DELETE ----

    /**
     * Deletes a reservation by res_no (admin only).
     */
    public boolean deleteReservation(String resNo) {
        String sql = "DELETE FROM reservations WHERE res_no = ?";

        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, resNo);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting reservation: " + resNo, e);
            return false;
        }
    }

    // ---- Counts for Dashboard ----

    public int countAll() {
        return countBySQL("SELECT COUNT(*) FROM reservations");
    }

    public int countByStaff(String staffId) {
        String sql = "SELECT COUNT(*) FROM reservations WHERE reservation_by = ?";
        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting reservations by staff", e);
        }
        return 0;
    }

    private int countBySQL(String sql) {
        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next())
                return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting reservations", e);
        }
        return 0;
    }

    // ---- Private Helpers ----

    private Reservation mapRow(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setResNo(rs.getString("res_no"));
        r.setCustomerName(rs.getString("customer_name"));
        r.setCustomerMobileNum(rs.getString("customer_mobile_num"));
        r.setCustomerAddress(rs.getString("customer_address"));
        r.setRoomType(rs.getString("room_type"));
        int roomId = rs.getInt("room_id");
        if (!rs.wasNull())
            r.setRoomId(roomId);
        r.setCheckIn(rs.getDate("check_in"));
        r.setCheckOut(rs.getDate("check_out"));
        int td = rs.getInt("total_days");
        if (!rs.wasNull())
            r.setTotalDays(td);
        r.setTotalPrice(rs.getBigDecimal("total_price"));
        r.setReservationBy(rs.getString("reservation_by"));
        r.setReservedByUsername(rs.getString("reserved_by_username"));
        return r;
    }
}
