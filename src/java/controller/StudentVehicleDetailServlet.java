/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.VehicleDAO;
import model.Student;
import model.Vehicle;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/student/vehicle/details")
public class StudentVehicleDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String vehicleId = req.getParameter("id");
        if (vehicleId == null) {
            resp.sendRedirect(req.getContextPath() + "/student/vehicles");
            return;
        }

        try {
            Vehicle v = new VehicleDAO().findByIdAndStudent(vehicleId, s.getStudentId());

            if (v == null) {
                resp.sendRedirect(req.getContextPath() + "/student/vehicles");
                return;
            }

            req.setAttribute("vehicle", v);
            req.getRequestDispatcher("/student/vehicle_details.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/student/vehicles");
        }
    }
}

