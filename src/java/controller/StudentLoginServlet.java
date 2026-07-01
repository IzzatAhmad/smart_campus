/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.StudentDAO;
import model.Student;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class StudentLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
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
            Student s = new StudentDAO().login(email.trim(), password);

            if (s == null) {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            }

            req.getSession().setAttribute("student", s);
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Login failed.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}
