package com.oceanview.dao;

import com.oceanview.db.DatabaseConnectionManager;
import com.oceanview.model.Room;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * RoomDAO — DAO Pattern for the `rooms` table.
 * Used by the Factory Pattern to get available rooms by type.
 */
public class RoomDAO {

    private static final Logger LOGGER = Logger.getLogger(RoomDAO.class.getName());
    private final DatabaseConnectionManager dbManager = DatabaseConnectionManager.getInstance();

    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM rooms ORDER BY room_type, room_number";
        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapRow(rs));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching rooms", e);
        }
        return list;
    }

    public int getAvailableRoomCountByType(String roomType) {
        String sql = "SELECT (SELECT COUNT(*) FROM rooms WHERE room_type = ?) - " +
                "(SELECT COUNT(*) FROM reservations WHERE room_type = ? AND check_in <= CURDATE() AND check_out > CURDATE())";
        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomType);
            ps.setString(2, roomType);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return Math.max(0, rs.getInt(1));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching available room count by type: " + roomType, e);
        }
        return 0;
    }

    public int countAvailableRoomsToday() {
        String sql = "SELECT (SELECT COUNT(*) FROM rooms) - " +
                "(SELECT COUNT(*) FROM reservations WHERE check_in <= CURDATE() AND check_out > CURDATE())";
        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next())
                return Math.max(0, rs.getInt(1));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting available rooms today", e);
        }
        return 0;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM rooms";
        try (Connection conn = dbManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next())
                return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting all rooms", e);
        }
        return 0;
    }

    private Room mapRow(ResultSet rs) throws SQLException {
        Room r = new Room();
        r.setId(rs.getInt("id"));
        r.setRoomNumber(rs.getString("room_number"));
        r.setRoomType(rs.getString("room_type"));
        r.setPricePerNight(rs.getBigDecimal("price_per_night"));
        r.setStatus(rs.getString("status"));
        return r;
    }
}
