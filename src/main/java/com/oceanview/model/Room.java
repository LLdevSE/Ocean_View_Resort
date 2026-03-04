package com.oceanview.model;

import java.math.BigDecimal;

/**
 * Room Model — maps to the `rooms` table.
 * Used by the Factory Pattern when creating room instances.
 */
public class Room implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    public enum RoomType {
        STANDARD, DELUXE, SUITE
    }

    public enum Status {
        AVAILABLE, BOOKED, MAINTENANCE
    }

    private int id;
    private String roomNumber;
    private String roomType;
    private BigDecimal pricePerNight;
    private String status;

    public Room() {
    }

    public Room(int id, String roomNumber, String roomType,
            BigDecimal pricePerNight, String status) {
        this.id = id;
        this.roomNumber = roomNumber;
        this.roomType = roomType;
        this.pricePerNight = pricePerNight;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String rn) {
        this.roomNumber = rn;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String rt) {
        this.roomType = rt;
    }

    public BigDecimal getPricePerNight() {
        return pricePerNight;
    }

    public void setPricePerNight(BigDecimal p) {
        this.pricePerNight = p;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
