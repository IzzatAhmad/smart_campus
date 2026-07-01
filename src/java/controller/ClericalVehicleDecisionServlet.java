/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.VehicleDAO;
import model.ClericalStaff;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/clerical/vehicle/decide")
public class ClericalVehicleDecisionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        ClericalStaff c = (ClericalStaff) req.getSession().getAttribute("clerical");
        if (c == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String vehicleId = req.getParameter("vehicleId");
        String action = req.getParameter("action"); // APPROVE / REJECT
        String comment = req.getParameter("comment");

        if (vehicleId == null || action == null || vehicleId.isBlank() || action.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/clerical/vehicle/requests");
            return;
        }

        String status = action.trim().toUpperCase();
        if (!status.equals("APPROVED") && !status.equals("REJECTED")) {
            resp.sendRedirect(req.getContextPath() + "/clerical/vehicle/requests");
            return;
        }

        if (comment == null) comment = "";
        comment = comment.trim();

        try {
            boolean ok = new VehicleDAO().decide(vehicleId, status, comment);

            // Optional: use session flash message
            if (ok) {
                req.getSession().setAttribute("success", "Vehicle " + vehicleId + " marked as " + status + ".");
            } else {
                req.getSession().setAttribute("error", "Decision failed. Vehicle not updated.");
            }

            resp.sendRedirect(req.getContextPath() + "/clerical/vehicle/requests");

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("error", "Error: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/clerical/vehicle/requests");
        }
    }
}

