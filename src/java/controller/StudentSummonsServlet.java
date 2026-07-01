/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;
 
import dao.AppealDAO;
import dao.SummonsDAO;
import model.Appeal;
import model.Student;
import model.Summons;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet("/student/summons")
public class StudentSummonsServlet extends HttpServlet {
 
    private final SummonsDAO summonsDAO = new SummonsDAO();
    private final AppealDAO  appealDAO  = new AppealDAO();
 
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
            String matricNo  = s.getMatricNo();
            String studentId = s.getStudentId();
 
            // ── Get all summons for student ──
            List<Summons> summonsList = summonsDAO.getAllByStudent(matricNo, studentId);
 
            // ── Summons IDs that already have an appeal (any status) ──
            // Used by JSP to hide the Appeal button for already-appealed summons
            Set<String> appealedSummonsIds = new HashSet<>();
            try {
                List<Appeal> studentAppeals = appealDAO.getAppealsByStudent(studentId);
                for (Appeal a : studentAppeals) {
                    appealedSummonsIds.add(a.getSummonsId());
                }
            } catch (ClassNotFoundException ex) {
                // Safe default: empty set (appeal buttons may show, server will block anyway)
            }

            // ── Stats ──
            int totalSummons    = summonsList.size();
            int unpaidSummons   = (int) summonsList.stream()
                                    .filter(sm -> "UNPAID".equals(sm.getStatus())).count();
            int paidSummons     = (int) summonsList.stream()
                                    .filter(sm -> "PAID".equals(sm.getStatus())).count();
            int appealedSummons = (int) summonsList.stream()
                                    .filter(sm -> "APPEALED".equals(sm.getStatus())).count();
            double outstanding  = summonsList.stream()
                                    .filter(sm -> "UNPAID".equals(sm.getStatus()))
                                    .mapToDouble(Summons::getAmount).sum();
 
            // ── Set attributes ──
            req.setAttribute("summonsList",     summonsList);
            req.setAttribute("totalSummons",    totalSummons);
            req.setAttribute("unpaidSummons",   unpaidSummons);
            req.setAttribute("paidSummons",     paidSummons);
            req.setAttribute("appealedSummons", appealedSummons);
            req.setAttribute("outstanding",         outstanding);
            req.setAttribute("appealedSummonsIds", appealedSummonsIds);
 
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(StudentSummonsServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
 
            req.setAttribute("summonsList",     null);
            req.setAttribute("totalSummons",    0);
            req.setAttribute("unpaidSummons",   0);
            req.setAttribute("paidSummons",     0);
            req.setAttribute("appealedSummons", 0);
            req.setAttribute("outstanding",         0.0);
            req.setAttribute("appealedSummonsIds", new HashSet<String>());
        }
 
        req.getRequestDispatcher("/student/student_summons.jsp").forward(req, resp);
    }
}