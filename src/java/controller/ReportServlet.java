/*
 * ReportServlet.java
 * Place in: src/java/controller/ReportServlet.java
 */
package controller;

import dao.ReportDAO;
import dao.WekaPredictionDAO;
import model.ClericalStaff;
import util.ExcelExportUtil;
import util.PdfExportUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/clerical/report/*")
public class ReportServlet extends HttpServlet {

    private final ReportDAO        reportDAO = new ReportDAO();
    private final WekaPredictionDAO wekaDAO  = new WekaPredictionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Session check ──
        ClericalStaff c = (ClericalStaff) req.getSession().getAttribute("clerical");
        if (c == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String path = req.getPathInfo(); // /view, /export/excel, /export/pdf
        if (path == null) path = "/view";

        switch (path) {
            case "/view":         handleView(req, resp);        break;
            case "/export/excel": {
                try {
                    handleExcelExport(req, resp);
                } catch (Exception ex) {
                    Logger.getLogger(ReportServlet.class.getName()).log(Level.SEVERE, null, ex);
                }
            } break;
            case "/export/pdf": {
                try {
                    handlePdfExport(req, resp);
                } catch (Exception ex) {
                    Logger.getLogger(ReportServlet.class.getName()).log(Level.SEVERE, null, ex);
                }
            } break;
            default: resp.sendRedirect(req.getContextPath() + "/clerical/report/view");
        }
    }

    // ── GET /clerical/report/view ──
    private void handleView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            // ── Year / Month filter ──
            List<Integer> availableYears = reportDAO.getAvailableYears();
            int currentYear = LocalDate.now().getYear();

            String yearParam = req.getParameter("year");
            int selectedYear = currentYear;
            try { if (yearParam != null) selectedYear = Integer.parseInt(yearParam); }
            catch (NumberFormatException ignored) {}

            String monthParam = req.getParameter("month");
            int selectedMonth = 0;
            try { if (monthParam != null) selectedMonth = Integer.parseInt(monthParam); }
            catch (NumberFormatException ignored) {}

            // ── Existing report data ──
            Map<String, String>       summary        = reportDAO.getYearSummary(selectedYear);
            List<Map<String, String>> monthlySummons = reportDAO.getMonthlySummons(selectedYear);
            List<Map<String, String>> monthlyPayments= reportDAO.getMonthlyPayments(selectedYear);
            List<Map<String, String>> offenseTypes   = reportDAO.getOffenseTypeBreakdown(selectedYear);
            List<Map<String, String>> hotspots       = reportDAO.getHotspots(selectedYear);
            List<Map<String, String>> monthlyDetail  = selectedMonth > 0
                    ? reportDAO.getMonthlyDetail(selectedYear, selectedMonth)
                    : new java.util.ArrayList<>();

            req.setAttribute("availableYears",  availableYears);
            req.setAttribute("selectedYear",    selectedYear);
            req.setAttribute("selectedMonth",   selectedMonth);
            req.setAttribute("summary",         summary);
            req.setAttribute("monthlySummons",  monthlySummons);
            req.setAttribute("monthlyPayments", monthlyPayments);
            req.setAttribute("offenseTypes",    offenseTypes);
            req.setAttribute("hotspots",        hotspots);
            req.setAttribute("monthlyDetail",   monthlyDetail);

            // ══════════════════════════════════════════════════════════════
            // WEKA PREDICTIVE ANALYTICS
            // ══════════════════════════════════════════════════════════════

            // Model 1: Linear Regression — predict next month summons count
            try {
                double predicted = wekaDAO.predictNextMonthSummons();
                req.setAttribute("predictedNextMonth", predicted);
            } catch (Exception e) {
                Logger.getLogger(ReportServlet.class.getName())
                      .log(Level.WARNING, "WEKA LinearRegression failed", e);
                req.setAttribute("predictedNextMonth", -1.0);
            }

            // Model 2: J48 Decision Tree — student risk classification
            try {
                Map<String, String> riskMap = wekaDAO.classifyStudentRisk();
                int highRisk = 0, medRisk = 0, lowRisk = 0;
                for (String risk : riskMap.values()) {
                    if ("HIGH".equals(risk))        highRisk++;
                    else if ("MEDIUM".equals(risk)) medRisk++;
                    else                            lowRisk++;
                }
                req.setAttribute("studentRiskMap", riskMap);
                req.setAttribute("riskHigh",       highRisk);
                req.setAttribute("riskMedium",     medRisk);
                req.setAttribute("riskLow",        lowRisk);
            } catch (Exception e) {
                Logger.getLogger(ReportServlet.class.getName())
                      .log(Level.WARNING, "WEKA J48 failed", e);
                req.setAttribute("riskHigh",   0);
                req.setAttribute("riskMedium", 0);
                req.setAttribute("riskLow",    0);
            }

            // Model 3: SimpleKMeans — hotspot zone clustering
            try {
                List<Map<String, String>> hotspotClusters = wekaDAO.detectHotspotClusters();
                req.setAttribute("hotspotClusters", hotspotClusters);
            } catch (Exception e) {
                Logger.getLogger(ReportServlet.class.getName())
                      .log(Level.WARNING, "WEKA KMeans failed", e);
                req.setAttribute("hotspotClusters", new java.util.ArrayList<>());
            }
            // ══════════════════════════════════════════════════════════════

            req.getRequestDispatcher("/clerical/report.jsp").forward(req, resp);

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "Failed to load report data.");
            resp.sendRedirect(req.getContextPath() + "/clerical/dashboard");
        }
    }

    // ── GET /clerical/report/export/excel ──
    private void handleExcelExport(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, Exception {

        int year  = LocalDate.now().getYear();
        int month = 0;
        try { year  = Integer.parseInt(req.getParameter("year"));  } catch (Exception ignored) {}
        try { month = Integer.parseInt(req.getParameter("month")); } catch (Exception ignored) {}

        try {
            List<Map<String, String>> detail = month > 0
                    ? reportDAO.getMonthlyDetail(year, month)
                    : new java.util.ArrayList<>();

            Map<String, String>       summary        = reportDAO.getYearSummary(year);
            List<Map<String, String>> monthlySummons = reportDAO.getMonthlySummons(year);
            List<Map<String, String>> monthlyPayments= reportDAO.getMonthlyPayments(year);
            List<Map<String, String>> hotspots       = reportDAO.getHotspots(year);

            byte[] excelBytes = ExcelExportUtil.generate(
                year, month, summary, monthlySummons, monthlyPayments, hotspots, detail);

            String filename = month > 0
                    ? "UMT_Report_" + year + "_Month" + month + ".xlsx"
                    : "UMT_Report_" + year + ".xlsx";

            resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
            resp.getOutputStream().write(excelBytes);
            resp.getOutputStream().flush();

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            resp.sendError(500, "Failed to generate Excel report.");
        }
    }

    // ── GET /clerical/report/export/pdf ──
    private void handlePdfExport(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, Exception {

        int year  = LocalDate.now().getYear();
        int month = 0;
        try { year  = Integer.parseInt(req.getParameter("year"));  } catch (Exception ignored) {}
        try { month = Integer.parseInt(req.getParameter("month")); } catch (Exception ignored) {}

        try {
            List<Map<String, String>> detail = month > 0
                    ? reportDAO.getMonthlyDetail(year, month)
                    : new java.util.ArrayList<>();

            Map<String, String>       summary        = reportDAO.getYearSummary(year);
            List<Map<String, String>> monthlySummons = reportDAO.getMonthlySummons(year);
            List<Map<String, String>> monthlyPayments= reportDAO.getMonthlyPayments(year);
            List<Map<String, String>> hotspots       = reportDAO.getHotspots(year);

            byte[] pdfBytes = PdfExportUtil.generate(
                year, month, summary, monthlySummons, monthlyPayments, hotspots, detail);

            String filename = month > 0
                    ? "UMT_Report_" + year + "_Month" + month + ".pdf"
                    : "UMT_Report_" + year + ".pdf";

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
            resp.getOutputStream().write(pdfBytes);
            resp.getOutputStream().flush();

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            resp.sendError(500, "Failed to generate PDF report.");
        }
    }
}