/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;
 
import dao.SummonsDAO;
import dao.StudentDAO;
import model.Student;
import model.Summons;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet("/student/dashboard")
public class StudentDashboardServlet extends HttpServlet {
 
    private final SummonsDAO summonsDAO = new SummonsDAO();
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        // ── Check session ──
        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
 
        try {
            String matricNo = s.getMatricNo();
            String studentId = s.getStudentId();
 
            // ── Real summons stats ──
            int totalSummons    = summonsDAO.countTotalByStudent(matricNo, studentId);
            int unpaidSummons   = summonsDAO.countByStatusForStudent(matricNo, studentId, "UNPAID");
            int paidSummons     = summonsDAO.countByStatusForStudent(matricNo, studentId, "PAID");
            int appealedSummons = summonsDAO.countByStatusForStudent(matricNo, studentId, "APPEALED");
 
            // ── Outstanding balance ──
            double outstanding = summonsDAO.getTotalOutstandingByStudent(matricNo, studentId);
 
            // ── Recent 5 summons ──
            List<Summons> recentSummons = summonsDAO.getRecentByStudent(matricNo, studentId, 5);
 
            // ── Set attributes ──
            req.setAttribute("totalSummons",    totalSummons);
            req.setAttribute("unpaidSummons",   unpaidSummons);
            req.setAttribute("paidSummons",     paidSummons);
            req.setAttribute("appealedSummons", appealedSummons);
            req.setAttribute("outstanding",     outstanding);
            req.setAttribute("recentSummons",   recentSummons);
 
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(StudentDashboardServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
 
            // Set safe defaults on error
            req.setAttribute("totalSummons",    0);
            req.setAttribute("unpaidSummons",   0);
            req.setAttribute("paidSummons",     0);
            req.setAttribute("appealedSummons", 0);
            req.setAttribute("outstanding",     0.0);
            req.setAttribute("recentSummons",   null);
        }
 
        req.getRequestDispatcher("/student/dashboard.jsp").forward(req, resp);
    }
}
