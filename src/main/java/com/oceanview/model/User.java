package com.oceanview.model;

/**
 * User Model — represents a staff or admin user.
 * Implements Serializable so it can be stored in the HTTP session.
 */
public class User implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    public enum Role { ADMIN, STAFF }

    private int    id;
    private String staffId;      // e.g. STF-001 (null/empty for admin)
    private String username;
    private String password;     // BCrypt hash
    private String role;         // "ADMIN" or "STAFF"
    private String mobileNum;
    private String address;

    // ---- Constructors ----

    public User() {}

    public User(int id, String staffId, String username,
                String password, String role,
                String mobileNum, String address) {
        this.id        = id;
        this.staffId   = staffId;
        this.username  = username;
        this.password  = password;
        this.role      = role;
        this.mobileNum = mobileNum;
        this.address   = address;
    }

    // ---- Getters & Setters ----

    public int getId()                 { return id; }
    public void setId(int id)          { this.id = id; }

    public String getStaffId()                 { return staffId; }
    public void setStaffId(String staffId)     { this.staffId = staffId; }

    public String getUsername()                { return username; }
    public void setUsername(String username)   { this.username = username; }

    public String getPassword()                { return password; }
    public void setPassword(String password)   { this.password = password; }

    public String getRole()                    { return role; }
    public void setRole(String role)           { this.role = role; }

    public String getMobileNum()               { return mobileNum; }
    public void setMobileNum(String mobileNum) { this.mobileNum = mobileNum; }

    public String getAddress()                 { return address; }
    public void setAddress(String address)     { this.address = address; }

    // Convenience method used in JSP to get display initial
    public String getInitial() {
        return (username != null && !username.isEmpty())
               ? String.valueOf(username.charAt(0)).toUpperCase()
               : "?";
    }

    @Override
    public String toString() {
        return "User{id=" + id + ", username='" + username +
               "', role='" + role + "', staffId='" + staffId + "'}";
    }
}
