/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;
 
import dao.PatrolStaffDAO;
import model.PatrolStaff;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
 
@WebServlet("/patrol/login")
public class PatrolLoginServlet extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Use same login.jsp
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }
 
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
 
        // Validate input
        if (email == null || password == null || 
            email.isBlank() || password.isBlank()) {
            req.setAttribute("error", "Please enter email and password.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }
 
        try {
            PatrolStaff p = new PatrolStaffDAO().login(email.trim(), password);
 
            if (p == null) {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            }
 
            // Store patrol session
            req.getSession().setAttribute("patrol", p);
 
            // Redirect to patrol dashboard
            resp.sendRedirect(req.getContextPath() + "/patrol/dashboard");
 
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Login failed. Please try again.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}
