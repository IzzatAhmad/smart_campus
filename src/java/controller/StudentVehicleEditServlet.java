package controller;

import dao.VehicleDAO;
import model.Student;
import model.Vehicle;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/student/vehicle/edit")
public class StudentVehicleEditServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String id = req.getParameter("id");
        if (id == null || id.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/student/vehicles");
            return;
        }

        try {
            Vehicle v = new VehicleDAO().findByIdAndStudent(id, s.getStudentId());
            if (v == null) {
                resp.sendRedirect(req.getContextPath() + "/student/vehicles");
                return;
            }

            // ── Only APPROVED vehicles can be edited ──
            if (!"APPROVED".equalsIgnoreCase(v.getStatus())) {
                req.getSession().setAttribute("errorMsg",
                    "You can only edit a vehicle that has been approved by clerical staff.");
                resp.sendRedirect(req.getContextPath() + "/student/vehicles");
                return;
            }

            req.setAttribute("vehicle", v);
            req.getRequestDispatcher("/student/vehicle_edit.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/student/vehicles");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String id = req.getParameter("vehicleId");
        if (id == null || id.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/student/vehicles");
            return;
        }

        try {
            VehicleDAO dao = new VehicleDAO();

            Vehicle old = dao.findByIdAndStudent(id, s.getStudentId());
            if (old == null) {
                resp.sendRedirect(req.getContextPath() + "/student/vehicles");
                return;
            }

            // ── Double-check on POST as well — prevent direct form submission ──
            if (!"APPROVED".equalsIgnoreCase(old.getStatus())) {
                req.getSession().setAttribute("errorMsg",
                    "You can only edit a vehicle that has been approved.");
                resp.sendRedirect(req.getContextPath() + "/student/vehicles");
                return;
            }

            // ── Only color is editable ──
            String color = req.getParameter("color");

            if (color == null || color.isBlank()) {
                req.setAttribute("error", "Please enter a color.");
                req.setAttribute("vehicle", old);
                req.getRequestDispatcher("/student/vehicle_edit.jsp").forward(req, resp);
                return;
            }

            // Update color only — status is NOT changed
            boolean ok = dao.updateColorOnly(id, s.getStudentId(), color.trim());
            if (!ok) {
                req.setAttribute("error", "Update failed. Please try again.");
                req.setAttribute("vehicle", old);
                req.getRequestDispatcher("/student/vehicle_edit.jsp").forward(req, resp);
                return;
            }

            req.getSession().setAttribute("successMsg", "Vehicle color updated successfully.");
            resp.sendRedirect(req.getContextPath() + "/student/vehicles");

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/student/vehicles");
        }
    }
}