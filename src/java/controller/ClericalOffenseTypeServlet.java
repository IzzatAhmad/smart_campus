/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.OffenseTypeDAO;
import model.ClericalStaff;
import model.OffenseType;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/clerical/offense/*")
public class ClericalOffenseTypeServlet extends HttpServlet {

    private final OffenseTypeDAO dao = new OffenseTypeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Check session
        ClericalStaff c = (ClericalStaff) req.getSession().getAttribute("clerical");
        if (c == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo(); // /list

        if (path == null || path.equals("/list")) {
            List<OffenseType> offenseList = null;
            try {
                offenseList = dao.getAllOffenseTypes();
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(ClericalOffenseTypeServlet.class.getName()).log(Level.SEVERE, null, ex);
            }
            req.setAttribute("offenseList", offenseList);
            req.getRequestDispatcher(
                "/clerical/offense_list.jsp"
            ).forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Check session
        ClericalStaff c = (ClericalStaff) req.getSession().getAttribute("clerical");
        if (c == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo(); // /add, /edit, /toggle

        if (path == null) {
            res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
            return;
        }

        switch (path) {
            case "/add":
            {
                try {
                    handleAdd(req, res);
                } catch (ClassNotFoundException ex) {
                    Logger.getLogger(ClericalOffenseTypeServlet.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
                break;

            case "/edit":
            {
                try {
                    handleEdit(req, res);
                } catch (ClassNotFoundException ex) {
                    Logger.getLogger(ClericalOffenseTypeServlet.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
                break;

            case "/toggle":
            {
                try {
                    handleToggle(req, res);
                } catch (ClassNotFoundException ex) {
                    Logger.getLogger(ClericalOffenseTypeServlet.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
                break;

            default:
                res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
        }
    }

    // ── Handle Add ──
    private void handleAdd(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ClassNotFoundException {

        String offenseName     = req.getParameter("offenseName").trim();
        String offenseCategory = req.getParameter("offenseCategory").trim();
        String amountStr       = req.getParameter("amount").trim();
        String description     = req.getParameter("description");
        String createdBy       = req.getParameter("createdBy");

        // Validate required fields
        if (offenseName.isEmpty() || offenseCategory.isEmpty() || amountStr.isEmpty()) {
            req.getSession().setAttribute("errorMsg",
                "All required fields must be filled.");
            res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
            return;
        }

        // Check duplicate offense name
        if (dao.isOffenseNameExists(offenseName, null)) {
            req.getSession().setAttribute("errorMsg",
                "Offense type \"" + offenseName + "\" already exists.");
            res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
            return;
        }

        // Validate amount
        double amount = 0;
        try {
            amount = Double.parseDouble(amountStr);
            if (amount < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMsg", "Invalid fine amount.");
            res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
            return;
        }

        // Build OffenseType object
        OffenseType o = new OffenseType();
        o.setOffenseId(dao.generateOffenseId());
        o.setOffenseName(offenseName);
        o.setOffenseCategory(offenseCategory);
        o.setAmount(amount);
        o.setDescription(description != null ? description.trim() : "");
        o.setCreatedBy(createdBy);

        // Save to DB
        if (dao.addOffenseType(o)) {
            req.getSession().setAttribute("successMsg",
                "Offense type \"" + offenseName + "\" added successfully.");
        } else {
            req.getSession().setAttribute("errorMsg",
                "Failed to add offense type. Please try again.");
        }

        res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
    }

    // ── Handle Edit ──
    private void handleEdit(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ClassNotFoundException {

        String offenseId       = req.getParameter("offenseId").trim();
        String offenseName     = req.getParameter("offenseName").trim();
        String offenseCategory = req.getParameter("offenseCategory").trim();
        String amountStr       = req.getParameter("amount").trim();
        String description     = req.getParameter("description");

        // Validate required fields
        if (offenseId.isEmpty() || offenseName.isEmpty() ||
            offenseCategory.isEmpty() || amountStr.isEmpty()) {
            req.getSession().setAttribute("errorMsg",
                "All required fields must be filled.");
            res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
            return;
        }

        // Check duplicate name excluding current offense
        if (dao.isOffenseNameExists(offenseName, offenseId)) {
            req.getSession().setAttribute("errorMsg",
                "Offense type \"" + offenseName + "\" already exists.");
            res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
            return;
        }

        // Validate amount
        double amount = 0;
        try {
            amount = Double.parseDouble(amountStr);
            if (amount < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMsg", "Invalid fine amount.");
            res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
            return;
        }

        // Build OffenseType object
        OffenseType o = new OffenseType();
        o.setOffenseId(offenseId);
        o.setOffenseName(offenseName);
        o.setOffenseCategory(offenseCategory);
        o.setAmount(amount);
        o.setDescription(description != null ? description.trim() : "");

        // Update DB
        if (dao.editOffenseType(o)) {
            req.getSession().setAttribute("successMsg",
                "Offense type \"" + offenseName + "\" updated successfully.");
        } else {
            req.getSession().setAttribute("errorMsg",
                "Failed to update offense type. Please try again.");
        }

        res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
    }

    // ── Handle Toggle Status ──
    private void handleToggle(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ClassNotFoundException {

        String offenseId = req.getParameter("offenseId").trim();
        String newStatus = req.getParameter("newStatus").trim();

        // Validate
        if (offenseId.isEmpty() || newStatus.isEmpty()) {
            req.getSession().setAttribute("errorMsg", "Invalid request.");
            res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
            return;
        }

        if (!newStatus.equals("ACTIVE") && !newStatus.equals("INACTIVE")) {
            req.getSession().setAttribute("errorMsg", "Invalid status value.");
            res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
            return;
        }

        // Update DB
        if (dao.toggleStatus(offenseId, newStatus)) {
            String action = newStatus.equals("ACTIVE") ? "activated" : "deactivated";
            req.getSession().setAttribute("successMsg",
                "Offense type " + offenseId + " has been " + action + ".");
        } else {
            req.getSession().setAttribute("errorMsg",
                "Failed to update status. Please try again.");
        }

        res.sendRedirect(req.getContextPath() + "/clerical/offense/list");
    }
}