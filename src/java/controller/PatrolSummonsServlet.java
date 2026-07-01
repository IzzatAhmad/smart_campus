/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;
 
import dao.OffenseTypeDAO;
import dao.SummonsDAO;
import model.OffenseType;
import model.PatrolStaff;
import model.Summons;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet("/patrol/summons/*")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1MB
    maxFileSize       = 1024 * 1024 * 5,  // 5MB
    maxRequestSize    = 1024 * 1024 * 10  // 10MB
)
public class PatrolSummonsServlet extends HttpServlet {
 
    private final SummonsDAO    summonsDAO    = new SummonsDAO();
    private final OffenseTypeDAO offenseDAO   = new OffenseTypeDAO();
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
 
        // Check session
        PatrolStaff p = (PatrolStaff) req.getSession().getAttribute("patrol");
        if (p == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }
 
        String path = req.getPathInfo(); // /create or /history
 
        if (path == null) {
            res.sendRedirect(req.getContextPath() + "/patrol/dashboard");
            return;
        }
 
        switch (path) {
            case "/create":
                handleCreateGet(req, res);
                break;
            case "/history":
                handleHistoryGet(req, res, p);
                break;
            default:
                res.sendRedirect(req.getContextPath() + "/patrol/dashboard");
        }
    }
 
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
 
        // Check session
        PatrolStaff p = (PatrolStaff) req.getSession().getAttribute("patrol");
        if (p == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }
 
        String path = req.getPathInfo();
 
        if ("/create".equals(path)) {
            try {
                handleCreatePost(req, res, p);
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(PatrolSummonsServlet.class.getName())
                      .log(Level.SEVERE, null, ex);
            }
        } else {
            res.sendRedirect(req.getContextPath() + "/patrol/dashboard");
        }
    }
 
    // ── GET: Show Create Summons Form ──
    private void handleCreateGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
 
        try {
            // Load active offense types for dropdown
            List<OffenseType> offenseList = offenseDAO.getActiveOffenseTypes();
            req.setAttribute("offenseList", offenseList);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
 
        req.getRequestDispatcher("/patrol/create_summons.jsp").forward(req, res);
    }
 
    // ── GET: Show History Page ──
    private void handleHistoryGet(HttpServletRequest req, HttpServletResponse res,
                                  PatrolStaff p) throws ServletException, IOException {
        try {
            List<Summons> summonsList = summonsDAO.getSummonsByPatrol(p.getPatrolStaffId());
            req.setAttribute("summonsList", summonsList);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
 
        req.getRequestDispatcher("/patrol/summons_history.jsp").forward(req, res);
    }
 
    // ── POST: Create Summons ──
    private void handleCreatePost(HttpServletRequest req, HttpServletResponse res,
                                  PatrolStaff p)
            throws IOException, ClassNotFoundException, ServletException {
 
        String summonsType = req.getParameter("summonsType");
        String offenseId   = req.getParameter("offenseId");
        String amountStr   = req.getParameter("amount");
        String location    = req.getParameter("location");
        String description = req.getParameter("description");
        String plateNumber = req.getParameter("plateNumber");
        String matricNo    = req.getParameter("matricNo");
 
        // ── Validate required fields ──
        if (summonsType == null || offenseId == null || 
            amountStr == null   || location == null  ||
            summonsType.isBlank() || offenseId.isBlank() ||
            amountStr.isBlank()   || location.isBlank()) {
            req.getSession().setAttribute("errorMsg", 
                "All required fields must be filled.");
            res.sendRedirect(req.getContextPath() + "/patrol/summons/create");
            return;
        }
 
        // ── Validate by type ──
        if ("VEHICLE".equals(summonsType)) {
            if (plateNumber == null || plateNumber.isBlank()) {
                req.getSession().setAttribute("errorMsg",
                    "Plate number is required for vehicle offense.");
                res.sendRedirect(req.getContextPath() + "/patrol/summons/create");
                return;
            }
            // Check plate number exists and approved
            if (!summonsDAO.isPlateNumberExists(plateNumber.trim())) {
                req.getSession().setAttribute("errorMsg",
                    "Plate number \"" + plateNumber + "\" not found or not approved.");
                res.sendRedirect(req.getContextPath() + "/patrol/summons/create");
                return;
            }
        } else if ("MISCONDUCT".equals(summonsType)) {
            if (matricNo == null || matricNo.isBlank()) {
                req.getSession().setAttribute("errorMsg",
                    "Matric number is required for misconduct offense.");
                res.sendRedirect(req.getContextPath() + "/patrol/summons/create");
                return;
            }
            // Check matric number exists
            if (!summonsDAO.isMatricNoExists(matricNo.trim())) {
                req.getSession().setAttribute("errorMsg",
                    "Matric number \"" + matricNo + "\" not found.");
                res.sendRedirect(req.getContextPath() + "/patrol/summons/create");
                return;
            }
        }
 
        // ── Validate amount ──
        double amount;
        try {
            amount = Double.parseDouble(amountStr);
            if (amount <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMsg", "Invalid fine amount.");
            res.sendRedirect(req.getContextPath() + "/patrol/summons/create");
            return;
        }
 
        // ── Handle evidence image upload ──
        String evidencePath = null;
        try {
            Part filePart = req.getPart("evidenceImage");
            if (filePart != null && filePart.getSize() > 0) {
                String originalName = filePart.getSubmittedFileName();
                String ext = originalName.substring(originalName.lastIndexOf("."));
                String fileName = "EVIDENCE_" + p.getPatrolStaffId() + 
                                  "_" + System.currentTimeMillis() + ext;
 
                // Save to uploads/evidence/ folder
                String uploadDir = getServletContext().getRealPath("") + 
                                   File.separator + "uploads" + 
                                   File.separator + "evidence";
 
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();
 
                filePart.write(uploadDir + File.separator + fileName);
                evidencePath = "uploads/evidence/" + fileName;
            }
        } catch (Exception e) {
            // Evidence upload optional - continue without it
            System.out.println("Evidence upload skipped: " + e.getMessage());
        }
 
        // ── Build Summons object ──
        Summons s = new Summons();
        s.setSummonsId(summonsDAO.generateSummonsId());
        s.setSummonsDate(LocalDate.now().toString());
        s.setSummonsType(summonsType);
        s.setOffenseId(offenseId);
        s.setAmount(amount);
        s.setLocation(location.trim());
        s.setDescription(description != null ? description.trim() : "");
        s.setPatrolStaffId(p.getPatrolStaffId());
        s.setEvidencePath(evidencePath);
 
        if ("VEHICLE".equals(summonsType)) {
            s.setPlateNumber(plateNumber.trim().toUpperCase());
        } else {
            s.setMatricNo(matricNo.trim().toUpperCase());
        }
 
        // ── Save to DB ──
        if (summonsDAO.createSummons(s)) {
            req.getSession().setAttribute("successMsg",
                "Summons " + s.getSummonsId() + " created successfully.");
            res.sendRedirect(req.getContextPath() + "/patrol/summons/history");
        } else {
            req.getSession().setAttribute("errorMsg",
                "Failed to create summons. Please try again.");
            res.sendRedirect(req.getContextPath() + "/patrol/summons/create");
        }
    }
}