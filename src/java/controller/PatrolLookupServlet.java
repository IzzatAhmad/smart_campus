/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;
 
import dao.SummonsDAO;
import model.PatrolStaff;
 
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet("/patrol/lookup/plate")
public class PatrolLookupServlet extends HttpServlet {
 
    private final SummonsDAO summonsDAO = new SummonsDAO();
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
 
        try {
            // Check session
            PatrolStaff p = (PatrolStaff) req.getSession().getAttribute("patrol");
            if (p == null) {
                res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }
            
            String plateNumber = req.getParameter("plate");
            
            // Set response type to JSON
            res.setContentType("application/json");
            res.setCharacterEncoding("UTF-8");
            PrintWriter out = res.getWriter();
            
            // Validate input
            if (plateNumber == null || plateNumber.isBlank()) {
                out.print("{\"found\":\"false\",\"error\":\"Plate number is empty\"}");
                out.flush();
                return;
            }
            
            Map<String, String> result =
                    summonsDAO.getStudentByPlateNumber(plateNumber);
            if ("true".equals(result.get("found"))) {
                // Escape values to prevent JSON issues
                String studentName = escapeJson(result.get("studentName"));
                String matricNo    = escapeJson(result.get("matricNo"));
                String faculty     = escapeJson(result.get("faculty"));
                String plate       = escapeJson(result.get("plateNumber"));
                String brand       = escapeJson(result.get("brand"));
                String vehicleType = escapeJson(result.get("vehicleType"));
                String color       = escapeJson(result.get("color"));
                
                out.print("{" +
                        "\"found\":\"true\","        +
                        "\"studentName\":\""  + studentName  + "\"," +
                                "\"matricNo\":\""     + matricNo     + "\"," +
                                        "\"faculty\":\""      + faculty      + "\"," +
                                                "\"plateNumber\":\"" + plate        + "\"," +
                                                        "\"brand\":\""        + brand        + "\"," +
                                                                "\"vehicleType\":\"" + vehicleType  + "\"," +
                                                                        "\"color\":\""        + color        + "\""  +
                                                                                "}");
            } else {
                out.print("{\"found\":\"false\"}");
            }
            
            out.flush();
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(PatrolLookupServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
 
    // ── Escape special characters for JSON ──
    private String escapeJson(String value) {
        if (value == null) return "";
        return value
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t");
    }
}