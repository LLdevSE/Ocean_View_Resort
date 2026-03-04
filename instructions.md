Role: Act as a Top-Level Enterprise Full-Stack Java Developer and a Senior UI/UX Specialist.

Context: Develop a complete, distributed Hotel Reservation System for "Ocean View Resort" using a 3-tier architecture and the MVC (Model-View-Controller) design pattern.

Tech Stack: > * Backend: Java Servlets, JSP (or pure HTML served via Servlets), Apache Tomcat 9, Maven.

Database: MySQL.

Frontend: HTML5, CSS3, Vanilla JavaScript, Bootstrap 5 (for a modern, responsive, user-friendly UI).

Architecture & Design Patterns Required:

3-Tier Architecture: Strictly separate Presentation, Business Logic, and Data Access layers.

Singleton Pattern: Implement a DatabaseConnectionManager to ensure only a single instance of the database connection pool exists.

Data Access Object (DAO) Pattern: Create DAOs (UserDAO, ReservationDAO, RoomDAO) to abstract all SQL queries away from the business logic.

Factory Pattern: Use a Factory to instantiate different types of Users (e.g., Admin, Staff) or Rooms (Standard, Deluxe, Suite).

Database Requirements (MySQL):

Create tables:

users (id, role [Admin/Staff], username, password, mobile_num, address, staff_id [VARCHAR, Auto-generated with a specific format like 'STF-001']). Note: The system must initialize with a default admin user (Username: admin, Password: admin678).

rooms (id, room_type, price_per_night, status).

reservations (res_no [Primary Key], customer_name, customer_mobile_num, customer_address, room_type, check_in, check_out, reservation_by [Foreign Key referencing users.staff_id]).

Advanced Features: Write a MySQL Stored Procedure to auto-generate the custom staff_id before insert. Write a trigger to calculate total days and room availability.

Role-Based Access Control (RBAC) & System Functionalities:
Implement strict Authorization using Java Servlet Filters to intercept requests and check the user's session role.

1. Admin Functions (Role: ADMIN):

Authentication: Login via the main portal.

Reservation Management: Full CRUD (Create, Read/View, Update, Delete) access. The view must display: Res No, Customer Name, Customer Mobile Num, Customer Address, Room Type, Check in, Check out, and Reservation By.

Staff Management: Full CRUD (Create, Read/View, Update, Delete) access for Staff Members. Capture: name, password, mobile Num, address, and the auto-generated Staff ID.

Billing: Calculate and Print the Reservation Bill.

2. Staff Functions (Role: STAFF):

Authentication: Login via the main portal.

Reservation Management: Restricted access (Create and View only). Cannot Update or Delete reservations.

Profile Management: View own Account info (cannot view or manage other staff).

Instructions for AI: Ensure the JSP/HTML UI dynamically renders navigation links based on the logged-in user's role (e.g., the "Manage Staff" link is hidden from Staff users). Implement backend validation in the Servlets to reject unauthorized POST/DELETE requests.


VERY IMPORTANT - first create the website frontend pages only page by page. because I wanna add this project to the github and update it. So after create a page please ask me to permission of proceed for next pages. I will add this project to the github after create the first page.