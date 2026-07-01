package controller;

import dao.SummonsDAO;
import dao.ReportDAO;
import model.ClericalStaff;
import model.Summons;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/clerical/summons/list")
public class ClericalSummonsListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        ClericalStaff c = (ClericalStaff) req.getSession().getAttribute("clerical");
        if (c == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // ── Parse filter params ──
        int selectedYear  = 0;
        int selectedMonth = 0;

        try {
            String yearParam  = req.getParameter("year");
            String monthParam = req.getParameter("month");
            if (yearParam  != null && !yearParam.isBlank())  selectedYear  = Integer.parseInt(yearParam);
            if (monthParam != null && !monthParam.isBlank()) selectedMonth = Integer.parseInt(monthParam);
        } catch (NumberFormatException e) { /* keep defaults */ }

        try {
            SummonsDAO dao = new SummonsDAO();

            // ── Summons list (filtered or all) ──
            List<Summons> summonsList = dao.getAllSummonsFiltered(selectedYear, selectedMonth);

            // ── Summary counts from the returned list ──
            int totalSummons  = summonsList.size();
            int unpaidCount   = 0, paidCount = 0, appealedCount = 0, overdueCount = 0;
            double totalAmt   = 0.0, unpaidAmt = 0.0;
            for (Summons s : summonsList) {
                totalAmt += s.getAmount();
                switch (s.getStatus() != null ? s.getStatus() : "") {
                    case "UNPAID":   unpaidCount++;  unpaidAmt += s.getAmount(); break;
                    case "PAID":     paidCount++;    break;
                    case "APPEALED": appealedCount++;break;
                    case "OVERDUE":  overdueCount++; unpaidAmt += s.getAmount(); break;
                }
            }

            // ── Available years for dropdown ──
            List<Integer> availableYears = new ReportDAO().getAvailableYears();

            req.setAttribute("summonsList",    summonsList);
            req.setAttribute("totalSummons",   totalSummons);
            req.setAttribute("unpaidCount",    unpaidCount);
            req.setAttribute("paidCount",      paidCount);
            req.setAttribute("appealedCount",  appealedCount);
            req.setAttribute("overdueCount",   overdueCount);
            req.setAttribute("totalAmt",       totalAmt);
            req.setAttribute("unpaidAmt",      unpaidAmt);
            req.setAttribute("selectedYear",   selectedYear);
            req.setAttribute("selectedMonth",  selectedMonth);
            req.setAttribute("availableYears", availableYears);

        } catch (Exception e) {
            Logger.getLogger(ClericalSummonsListServlet.class.getName())
                  .log(Level.SEVERE, null, e);
        }

        req.getRequestDispatcher("/clerical/clerical_summons_list.jsp").forward(req, resp);
    }
}
