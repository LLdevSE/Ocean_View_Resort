package com.oceanview.model;

import java.math.BigDecimal;
import java.sql.Date;

/**
 * Reservation Model — maps to the `reservations` table.
 */
public class Reservation implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    private String resNo;
    private String customerName;
    private String customerMobileNum;
    private String customerAddress;
    private String roomType; // STANDARD / DELUXE / SUITE
    private Integer roomId;
    private Date checkIn;
    private Date checkOut;
    private Integer totalDays; // Calculated by trigger
    private BigDecimal totalPrice; // Calculated by trigger
    private String reservationBy; // staff_id of the creator
    private String reservedByUsername; // Joined from users table (display only)

    // ---- Constructors ----

    public Reservation() {
    }

    // ---- Getters & Setters ----

    public String getResNo() {
        return resNo;
    }

    public void setResNo(String resNo) {
        this.resNo = resNo;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String n) {
        this.customerName = n;
    }

    public String getCustomerMobileNum() {
        return customerMobileNum;
    }

    public void setCustomerMobileNum(String m) {
        this.customerMobileNum = m;
    }

    public String getCustomerAddress() {
        return customerAddress;
    }

    public void setCustomerAddress(String a) {
        this.customerAddress = a;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String rt) {
        this.roomType = rt;
    }

    public Integer getRoomId() {
        return roomId;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }

    public Date getCheckIn() {
        return checkIn;
    }

    public void setCheckIn(Date checkIn) {
        this.checkIn = checkIn;
    }

    public Date getCheckOut() {
        return checkOut;
    }

    public void setCheckOut(Date checkOut) {
        this.checkOut = checkOut;
    }

    public Integer getTotalDays() {
        return totalDays;
    }

    public void setTotalDays(Integer totalDays) {
        this.totalDays = totalDays;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(BigDecimal tp) {
        this.totalPrice = tp;
    }

    public String getReservationBy() {
        return reservationBy;
    }

    public void setReservationBy(String rb) {
        this.reservationBy = rb;
    }

    public String getReservedByUsername() {
        return reservedByUsername;
    }

    public void setReservedByUsername(String u) {
        this.reservedByUsername = u;
    }
}
