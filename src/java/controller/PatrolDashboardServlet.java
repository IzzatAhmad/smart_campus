/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;
 
import dao.SummonsDAO;
import model.PatrolStaff;
import model.Summons;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet("/patrol/dashboard")
public class PatrolDashboardServlet extends HttpServlet {
 
    private final SummonsDAO summonsDAO = new SummonsDAO();
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        // Check session
        PatrolStaff p = (PatrolStaff) req.getSession().getAttribute("patrol");
        if (p == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
 
        try {
            String patrolStaffId = p.getPatrolStaffId();
 
            // ── Real stats from DB ──
            int totalReports   = summonsDAO.countTotalByPatrol(patrolStaffId);
            int todayReports   = summonsDAO.countTodayByPatrol(patrolStaffId);
            int pendingReports = summonsDAO.countPendingByPatrol(patrolStaffId);
 
            // ── Recent 5 summons ──
            List<Summons> recentList = summonsDAO.getRecentByPatrol(patrolStaffId, 5);
 
            // ── Set attributes ──
            req.setAttribute("totalReports",   totalReports);
            req.setAttribute("todayReports",   todayReports);
            req.setAttribute("pendingReports", pendingReports);
            req.setAttribute("recentList",     recentList);
 
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(PatrolDashboardServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
 
            // Set defaults if DB error
            req.setAttribute("totalReports",   0);
            req.setAttribute("todayReports",   0);
            req.setAttribute("pendingReports", 0);
            req.setAttribute("recentList",     null);
        }
 
        req.getRequestDispatcher("/patrol/dashboard.jsp").forward(req, resp);
    }
}
