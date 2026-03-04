package com.oceanview.factory;

import com.oceanview.model.Room;

import java.math.BigDecimal;

/**
 * RoomFactory — Factory Pattern
 * Creates Room objects with default prices based on room type.
 */
public class RoomFactory {

    public static final BigDecimal PRICE_STANDARD = new BigDecimal("5500.00");
    public static final BigDecimal PRICE_DELUXE = new BigDecimal("9500.00");
    public static final BigDecimal PRICE_SUITE = new BigDecimal("18000.00");

    /**
     * Creates a new Room instance configured for the specified type.
     * Used primarily when creating new rooms or quoting prices.
     */
    public static Room createRoom(String type) {
        Room room = new Room();
        room.setRoomType(type.toUpperCase());
        room.setStatus("AVAILABLE");

        switch (type.toUpperCase()) {
            case "STANDARD":
                room.setPricePerNight(PRICE_STANDARD);
                break;
            case "DELUXE":
                room.setPricePerNight(PRICE_DELUXE);
                break;
            case "SUITE":
                room.setPricePerNight(PRICE_SUITE);
                break;
            default:
                throw new IllegalArgumentException("Unknown room type: " + type);
        }
        return room;
    }

    /**
     * Returns the default price per night for a given room type.
     */
    public static BigDecimal getDefaultPrice(String type) {
        switch (type.toUpperCase()) {
            case "STANDARD":
                return PRICE_STANDARD;
            case "DELUXE":
                return PRICE_DELUXE;
            case "SUITE":
                return PRICE_SUITE;
            default:
                return BigDecimal.ZERO;
        }
    }
}
