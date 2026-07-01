/*
 * Smart Campus - Student Appeal Servlet
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
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/student/appeal/*")
public class StudentAppealServlet extends HttpServlet {

    private final AppealDAO  appealDAO  = new AppealDAO();
    private final SummonsDAO summonsDAO = new SummonsDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo(); // /list or /submit

        if (path == null) {
            resp.sendRedirect(req.getContextPath() + "/student/appeal/list");
            return;
        }

        switch (path) {
            case "/list":
                handleList(req, resp, s);
                break;
            case "/submit":
                handleSubmitGet(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/student/appeal/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo();

        if ("/submit".equals(path)) {
            try {
                handleSubmitPost(req, resp, s);
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(StudentAppealServlet.class.getName())
                      .log(Level.SEVERE, null, ex);
                req.getSession().setAttribute("errorMsg", "Failed to submit appeal.");
                resp.sendRedirect(req.getContextPath() + "/student/appeal/list");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/student/appeal/list");
        }
    }

    // ── GET: List all appeals for student ──
    private void handleList(HttpServletRequest req, HttpServletResponse resp,
                            Student s) throws ServletException, IOException {
        try {
            List<Appeal> appealList = appealDAO.getAppealsByStudent(s.getStudentId());
            req.setAttribute("appealList", appealList);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(StudentAppealServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
            req.setAttribute("appealList", null);
        }
        req.getRequestDispatcher("/student/appeal_list.jsp").forward(req, resp);
    }

    // ── GET: Show submit appeal form ──
    private void handleSubmitGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String summonsId = req.getParameter("id");
        if (summonsId == null || summonsId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/student/summons");
            return;
        }

        try {
            // Validate summons is UNPAID
            Summons summons = summonsDAO.getSummonsById(summonsId);
            if (summons == null) {
                req.getSession().setAttribute("errorMsg", "Summons not found.");
                resp.sendRedirect(req.getContextPath() + "/student/summons");
                return;
            }

            if (!"UNPAID".equals(summons.getStatus())) {
                req.getSession().setAttribute("errorMsg",
                    "Only UNPAID summons can be appealed.");
                resp.sendRedirect(req.getContextPath() + "/student/summons");
                return;
            }

            // Check no existing appeal
            if (appealDAO.hasAppeal(summonsId)) {
                req.getSession().setAttribute("errorMsg",
                    "An appeal has already been submitted for " + summonsId + ".");
                resp.sendRedirect(req.getContextPath() + "/student/appeal/list");
                return;
            }

            req.setAttribute("summons", summons);

        } catch (ClassNotFoundException ex) {
            Logger.getLogger(StudentAppealServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
            resp.sendRedirect(req.getContextPath() + "/student/summons");
            return;
        }

        req.getRequestDispatcher("/student/appeal_submit.jsp").forward(req, resp);
    }

    // ── POST: Submit appeal ──
    private void handleSubmitPost(HttpServletRequest req, HttpServletResponse resp,
                                  Student s)
            throws IOException, ClassNotFoundException {

        String summonsId    = req.getParameter("summonsId");
        String appealReason = req.getParameter("appealReason");

        // Validate
        if (summonsId == null || appealReason == null ||
            summonsId.isBlank() || appealReason.isBlank()) {
            req.getSession().setAttribute("errorMsg",
                "Please fill in the appeal reason.");
            resp.sendRedirect(req.getContextPath() +
                "/student/appeal/submit?id=" + summonsId);
            return;
        }

        if (appealReason.trim().length() < 20) {
            req.getSession().setAttribute("errorMsg",
                "Appeal reason must be at least 20 characters.");
            resp.sendRedirect(req.getContextPath() +
                "/student/appeal/submit?id=" + summonsId);
            return;
        }

        // Check summons is still UNPAID
        Summons summons = summonsDAO.getSummonsById(summonsId);
        if (summons == null || !"UNPAID".equals(summons.getStatus())) {
            req.getSession().setAttribute("errorMsg",
                "This summons cannot be appealed.");
            resp.sendRedirect(req.getContextPath() + "/student/summons");
            return;
        }

        // Check no duplicate appeal
        if (appealDAO.hasAppeal(summonsId)) {
            req.getSession().setAttribute("errorMsg",
                "An appeal already exists for summons " + summonsId + ".");
            resp.sendRedirect(req.getContextPath() + "/student/appeal/list");
            return;
        }

        // Build Appeal object
        Appeal appeal = new Appeal();
        appeal.setAppealId(appealDAO.generateAppealId());
        appeal.setSummonsId(summonsId);
        appeal.setStudentId(s.getStudentId());
        appeal.setAppealReason(appealReason.trim());
        appeal.setAppealDate(LocalDate.now().toString());

        // Save appeal
        boolean appealSaved = appealDAO.submitAppeal(appeal);
        if (!appealSaved) {
            req.getSession().setAttribute("errorMsg",
                "Failed to submit appeal. Please try again.");
            resp.sendRedirect(req.getContextPath() +
                "/student/appeal/submit?id=" + summonsId);
            return;
        }

        // Update summons status to APPEALED
        appealDAO.updateSummonsToAppealed(summonsId);

        req.getSession().setAttribute("successMsg",
            "Appeal for summons " + summonsId + " submitted successfully. " +
            "Please wait for clerical review.");
        resp.sendRedirect(req.getContextPath() + "/student/appeal/list");
    }
}
