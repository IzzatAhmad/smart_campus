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
 
@WebServlet("/clerical/students/*")
public class ClericalStudentActivityServlet extends HttpServlet {
 
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
            handleStudentList(req, resp);
        } else if (path.equals("/view")) {
            handleStudentView(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/clerical/students/list");
        }
    }
 
    // ── Show all students with summons summary ──
    private void handleStudentList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Map<String, Object>> studentList = dao.getAllStudentsWithStats();
            req.setAttribute("studentList", studentList);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(ClericalStudentActivityServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
            req.setAttribute("studentList", null);
        }
        req.getRequestDispatcher("/clerical/student_activity.jsp").forward(req, resp);
    }
 
    // ── Show single student detail with all their summons ──
    private void handleStudentView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        String studentId = req.getParameter("id");
        if (studentId == null || studentId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/clerical/students/list");
            return;
        }
 
        try {
            Map<String, Object> studentInfo = dao.getStudentInfo(studentId);
            List<Map<String, Object>> summonsList = dao.getStudentSummons(studentId);
            List<Map<String, Object>> vehicleList = dao.getStudentVehicles(studentId);
 
            req.setAttribute("studentInfo",  studentInfo);
            req.setAttribute("summonsList",  summonsList);
            req.setAttribute("vehicleList",  vehicleList);
 
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(ClericalStudentActivityServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
        }
 
        req.getRequestDispatcher("/clerical/student_view.jsp").forward(req, resp);
    }
}