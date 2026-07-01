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

@WebServlet("/student/profile")
public class StudentProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student sessionStudent = (Student) req.getSession().getAttribute("student");
        if (sessionStudent == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            Student fresh = new StudentDAO().getById(sessionStudent.getStudentId());
            req.setAttribute("studentData", fresh);
            req.getRequestDispatcher("/student/profile.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student sessionStudent = (Student) req.getSession().getAttribute("student");
        if (sessionStudent == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String name = req.getParameter("name");
        String phone = req.getParameter("phone");
        String faculty = req.getParameter("faculty"); // ✅ NEW

        if (name == null || phone == null || faculty == null ||
            name.isBlank() || phone.isBlank() || faculty.isBlank()) {

            req.setAttribute("error", "All fields must be filled.");
            doGet(req, resp);
            return;
        }

        try {
            boolean ok = new StudentDAO().updateProfile(
                    sessionStudent.getStudentId(),
                    name.trim(),
                    phone.trim(),
                    faculty.trim()
            );

            if (ok) {
                // update session data
                sessionStudent.setStudentName(name.trim());
                sessionStudent.setPhoneNumber(phone.trim());
                sessionStudent.setFaculty(faculty.trim());

                req.getSession().setAttribute("student", sessionStudent);
                req.setAttribute("success", "Profile updated successfully.");
            } else {
                req.setAttribute("error", "Update failed.");
            }

            doGet(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Update error.");
            doGet(req, resp);
        }
    }
}

