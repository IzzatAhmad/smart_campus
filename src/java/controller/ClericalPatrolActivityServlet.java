/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;
 
import dao.ClericalMonitorDAO;
import model.ClericalStaff;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet("/clerical/patrol/*")
public class ClericalPatrolActivityServlet extends HttpServlet {
 
    private final ClericalMonitorDAO dao = new ClericalMonitorDAO();
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        // ── Check session ──
        ClericalStaff c = (ClericalStaff) req.getSession().getAttribute("clerical");
        if (c == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
 
        String path = req.getPathInfo(); // /list or /view
 
        if (path == null || path.equals("/list")) {
            handlePatrolList(req, resp);
        } else if (path.equals("/view")) {
            handlePatrolView(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/clerical/patrol/list");
        }
    }
 
    // ── Show all patrol staff with activity summary ──
    private void handlePatrolList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Map<String, Object>> patrolList = dao.getAllPatrolWithStats();
            req.setAttribute("patrolList", patrolList);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(ClericalPatrolActivityServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
            req.setAttribute("patrolList", null);
        }
        req.getRequestDispatcher("/clerical/patrol_activity.jsp").forward(req, resp);
    }
 
    // ── Show single patrol staff detail with all their summons history ──
    private void handlePatrolView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        String patrolId = req.getParameter("id");
        if (patrolId == null || patrolId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/clerical/patrol/list");
            return;
        }
 
        try {
            Map<String, Object> patrolInfo   = dao.getPatrolInfo(patrolId);
            List<Map<String, Object>> summonsList = dao.getPatrolSummons(patrolId);
 
            req.setAttribute("patrolInfo",  patrolInfo);
            req.setAttribute("summonsList", summonsList);
 
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(ClericalPatrolActivityServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
        }
 
        req.getRequestDispatcher("/clerical/patrol_view.jsp").forward(req, resp);
    }
}
