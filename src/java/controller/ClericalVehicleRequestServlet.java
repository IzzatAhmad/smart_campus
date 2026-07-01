/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.VehicleDAO;
import model.ClericalStaff;
import model.Vehicle;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/clerical/vehicle/requests")
public class ClericalVehicleRequestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        ClericalStaff c = (ClericalStaff) req.getSession().getAttribute("clerical");
        if (c == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Vehicle> list = new VehicleDAO().listPending();
            req.setAttribute("pendingList", list);
            req.getRequestDispatcher("/clerical/vehicle_requests.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load pending requests.");
            req.getRequestDispatcher("/clerical/vehicle_requests.jsp").forward(req, resp);
        }
    }
}

