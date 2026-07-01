package controller;

import dao.VehicleDAO;
import model.Student;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/student/vehicle/delete")
public class StudentVehicleDeleteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String id = req.getParameter("id");
        if (id == null || id.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/student/vehicles");
            return;
        }

        try {
            VehicleDAO dao = new VehicleDAO();

            // ── Rule: cannot delete if vehicle has any summons ──
            if (dao.hasSummons(id)) {
                req.getSession().setAttribute("errorMsg",
                    "This vehicle cannot be deleted because it has summons records.");
                resp.sendRedirect(req.getContextPath() + "/student/vehicles");
                return;
            }

            boolean ok = dao.deleteByStudent(id, s.getStudentId());
            if (ok) {
                req.getSession().setAttribute("successMsg", "Vehicle deleted successfully.");
            } else {
                req.getSession().setAttribute("errorMsg", "Delete failed. Vehicle may not belong to you.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "An error occurred. Please try again.");
        }

        resp.sendRedirect(req.getContextPath() + "/student/vehicles");
    }
}