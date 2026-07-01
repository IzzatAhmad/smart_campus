/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.ClericalStaffDAO;
import model.ClericalStaff;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/clerical/login")
public class ClericalLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // use same login.jsp for now
        req.getRequestDispatcher("/login").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || password == null || email.isBlank() || password.isBlank()) {
            req.setAttribute("error", "Please enter email and password.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        try {
            ClericalStaff c = new ClericalStaffDAO().login(email.trim(), password);

            if (c == null) {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            }

            // store clerical session (separate from student)
            req.getSession().setAttribute("clerical", c);

            // redirect to clerical dashboard (create later)
            resp.sendRedirect(req.getContextPath() + "/clerical/dashboard");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Login failed.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}

