/*
 * Smart Campus - Clerical Appeal Servlet
 */
package controller;

import dao.AppealDAO;
import model.Appeal;
import model.ClericalStaff;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/clerical/appeals/*")
public class ClericalAppealServlet extends HttpServlet {

    private final AppealDAO appealDAO = new AppealDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        ClericalStaff c = (ClericalStaff) req.getSession().getAttribute("clerical");
        if (c == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo(); // /list or /review

        if (path == null || path.equals("/list")) {
            handleList(req, resp);
        } else if (path.equals("/review")) {
            handleReviewGet(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/clerical/appeals/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        ClericalStaff c = (ClericalStaff) req.getSession().getAttribute("clerical");
        if (c == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo();

        if ("/review".equals(path)) {
            try {
                handleReviewPost(req, resp, c);
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(ClericalAppealServlet.class.getName())
                      .log(Level.SEVERE, null, ex);
                req.getSession().setAttribute("errorMsg",
                    "Failed to process review. Please try again.");
                resp.sendRedirect(req.getContextPath() + "/clerical/appeals/list");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/clerical/appeals/list");
        }
    }

    // ── GET: List all appeals ──
    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Appeal> appealList = appealDAO.getAllAppeals();
            int pendingCount = (int) appealList.stream()
                .filter(a -> "PENDING".equals(a.getStatus())).count();

            req.setAttribute("appealList",   appealList);
            req.setAttribute("pendingCount", pendingCount);

        } catch (ClassNotFoundException ex) {
            Logger.getLogger(ClericalAppealServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
            req.setAttribute("appealList",   null);
            req.setAttribute("pendingCount", 0);
        }
        req.getRequestDispatcher("/clerical/clerical_appeal_list.jsp").forward(req, resp);
    }

    // ── GET: Show review form ──
    private void handleReviewGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String appealId = req.getParameter("id");
        if (appealId == null || appealId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/clerical/appeals/list");
            return;
        }

        try {
            // Find appeal by ID from list
            List<Appeal> all = appealDAO.getAllAppeals();
            Appeal appeal = all.stream()
                .filter(a -> appealId.equals(a.getAppealId()))
                .findFirst().orElse(null);

            if (appeal == null) {
                req.getSession().setAttribute("errorMsg", "Appeal not found.");
                resp.sendRedirect(req.getContextPath() + "/clerical/appeals/list");
                return;
            }

            req.setAttribute("appeal", appeal);

        } catch (ClassNotFoundException ex) {
            Logger.getLogger(ClericalAppealServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
            resp.sendRedirect(req.getContextPath() + "/clerical/appeals/list");
            return;
        }

        req.getRequestDispatcher("/clerical/appeal_review.jsp").forward(req, resp);
    }

    // ── POST: Submit review decision ──
    private void handleReviewPost(HttpServletRequest req, HttpServletResponse resp,
                                  ClericalStaff c)
            throws IOException, ClassNotFoundException {

        String appealId       = req.getParameter("appealId");
        String summonsId      = req.getParameter("summonsId");
        String decision       = req.getParameter("decision");
        String comment        = req.getParameter("clericalComment");
        String reducedAmtStr  = req.getParameter("reducedAmount");

        // Validate
        if (appealId == null || decision == null ||
            appealId.isBlank() || decision.isBlank()) {
            req.getSession().setAttribute("errorMsg", "Invalid request.");
            resp.sendRedirect(req.getContextPath() + "/clerical/appeals/list");
            return;
        }

        // Validate decision value
        if (!decision.equals("REASONABLE") &&
            !decision.equals("MODERATELY_REASONABLE") &&
            !decision.equals("UNREASONABLE")) {
            req.getSession().setAttribute("errorMsg", "Invalid decision value.");
            resp.sendRedirect(req.getContextPath() + "/clerical/appeals/list");
            return;
        }

        if (comment == null) comment = "";
        comment = comment.trim();

        // Handle reduced amount for MODERATELY_REASONABLE
        double reducedAmount = 0;
        if ("MODERATELY_REASONABLE".equals(decision)) {
            try {
                reducedAmount = Double.parseDouble(reducedAmtStr);
                if (reducedAmount <= 0) throw new NumberFormatException();
            } catch (NumberFormatException e) {
                req.getSession().setAttribute("errorMsg",
                    "Please enter a valid reduced amount.");
                resp.sendRedirect(req.getContextPath() +
                    "/clerical/appeals/review?id=" + appealId);
                return;
            }
        }

        // Save review
        boolean reviewed = appealDAO.reviewAppeal(
            appealId, decision, comment,
            c.getClericalStaffId(),
            LocalDate.now().toString()
        );

        if (!reviewed) {
            req.getSession().setAttribute("errorMsg",
                "Failed to save review. Please try again.");
            resp.sendRedirect(req.getContextPath() +
                "/clerical/appeals/review?id=" + appealId);
            return;
        }

        // Update summons status based on decision
        appealDAO.updateSummonsAfterReview(summonsId, decision, reducedAmount);

        String decisionLabel = decision.equals("REASONABLE") ? "Reasonable" :
                               decision.equals("MODERATELY_REASONABLE") ? "Moderately Reasonable" :
                               "Unreasonable";

        req.getSession().setAttribute("successMsg",
            "Appeal " + appealId + " reviewed as " + decisionLabel + ".");
        resp.sendRedirect(req.getContextPath() + "/clerical/appeals/list");
    }
}
