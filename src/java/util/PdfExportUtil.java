/*
 * PdfExportUtil.java
 * Place in: src/java/util/PdfExportUtil.java
 */
package util;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import java.io.ByteArrayOutputStream;
import java.util.List;
import java.util.Map;

public class PdfExportUtil {

    private static final String[] MONTH_NAMES = {
        "", "Jan","Feb","Mar","Apr","May","Jun",
        "Jul","Aug","Sep","Oct","Nov","Dec"
    };
    private static final String[] MONTH_NAMES_FULL = {
        "", "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    };

    private static final BaseColor UMT_BLUE   = new BaseColor(0, 51, 141);
    private static final BaseColor HEADER_BG  = new BaseColor(0, 51, 141);
    private static final BaseColor ALT_ROW    = new BaseColor(235, 241, 255);
    private static final BaseColor GOLD       = new BaseColor(251, 191, 36);
    private static final BaseColor BAR_TOTAL  = new BaseColor(111, 60, 255);
    private static final BaseColor BAR_VEH    = new BaseColor(59, 130, 246);
    private static final BaseColor BAR_MISC   = new BaseColor(251, 146, 60);
    private static final BaseColor PIE_PAID   = new BaseColor(22, 163, 74);
    private static final BaseColor PIE_UNPAID = new BaseColor(234, 88, 12);
    private static final BaseColor PIE_APPEAL = new BaseColor(37, 99, 235);

    private static Font FONT_TITLE, FONT_SUBTITLE, FONT_SECTION,
                        FONT_HEADER, FONT_BODY, FONT_BODY_BOLD,
                        FONT_SMALL, FONT_CHART_LABEL, FONT_CHART_TITLE;

    static {
        try {
            FONT_TITLE       = FontFactory.getFont(FontFactory.HELVETICA_BOLD,  18, UMT_BLUE);
            FONT_SUBTITLE    = FontFactory.getFont(FontFactory.HELVETICA,        11, BaseColor.DARK_GRAY);
            FONT_SECTION     = FontFactory.getFont(FontFactory.HELVETICA_BOLD,   12, UMT_BLUE);
            FONT_HEADER      = FontFactory.getFont(FontFactory.HELVETICA_BOLD,    9, BaseColor.WHITE);
            FONT_BODY        = FontFactory.getFont(FontFactory.HELVETICA,         9, BaseColor.BLACK);
            FONT_BODY_BOLD   = FontFactory.getFont(FontFactory.HELVETICA_BOLD,    9, BaseColor.BLACK);
            FONT_SMALL       = FontFactory.getFont(FontFactory.HELVETICA,         8, BaseColor.GRAY);
            FONT_CHART_LABEL = FontFactory.getFont(FontFactory.HELVETICA,         7, BaseColor.DARK_GRAY);
            FONT_CHART_TITLE = FontFactory.getFont(FontFactory.HELVETICA_BOLD,   10, UMT_BLUE);
        } catch (Exception e) { e.printStackTrace(); }
    }

    public static byte[] generate(
            int year, int month,
            Map<String, String> summary,
            List<Map<String, String>> monthlySummons,
            List<Map<String, String>> monthlyPayments,
            List<Map<String, String>> hotspots,
            List<Map<String, String>> detail) throws Exception {

        Document doc = new Document(PageSize.A4, 36, 36, 50, 40);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        PdfWriter writer = PdfWriter.getInstance(doc, out);

        writer.setPageEvent(new PdfPageEventHelper() {
            @Override
            public void onEndPage(PdfWriter w, Document d) {
                PdfContentByte cb = w.getDirectContent();
                cb.setColorFill(GOLD);
                cb.rectangle(36, d.top() + 8, d.right() - 36, 4);
                cb.fill();
                ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
                    new Phrase("Bahagian Keselamatan, Universiti Malaysia Terengganu  |  Page " + w.getPageNumber(), FONT_SMALL),
                    (d.left() + d.right()) / 2, d.bottom() - 10, 0);
            }
        });

        doc.open();
        PdfContentByte cb = writer.getDirectContent();

        // ── Cover Header ──
        String periodLabel = month > 0
            ? "Monthly Report — " + MONTH_NAMES_FULL[month] + " " + year
            : "Annual Report — " + year;

        cb.setColorFill(HEADER_BG);
        cb.rectangle(36, doc.top() - 80, doc.right() - 36, 80);
        cb.fill();
        ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
            new Phrase("UNIVERSITI MALAYSIA TERENGGANU",
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, BaseColor.WHITE)),
            50, doc.top() - 30, 0);
        ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
            new Phrase("Bahagian Keselamatan — Smart Campus Disciplinary System",
                FontFactory.getFont(FontFactory.HELVETICA, 10, new BaseColor(191, 219, 254))),
            50, doc.top() - 48, 0);
        ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
            new Phrase(periodLabel,
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, GOLD)),
            50, doc.top() - 66, 0);

        doc.add(new Paragraph("\n\n\n\n\n"));

        // ── Summary Stats ──
        doc.add(sectionTitle("Summary Statistics"));
        PdfPTable statTable = new PdfPTable(2);
        statTable.setWidthPercentage(60);
        statTable.setHorizontalAlignment(Element.ALIGN_LEFT);
        statTable.setSpacingAfter(14);
        addStatRow(statTable, "Total Summons Issued",  summary.getOrDefault("totalSummons",   "0"));
        addStatRow(statTable, "Total Paid",            summary.getOrDefault("totalPaid",      "0"));
        addStatRow(statTable, "Total Unpaid",          summary.getOrDefault("totalUnpaid",    "0"));
        addStatRow(statTable, "Total Collected (RM)",  "RM " + summary.getOrDefault("totalCollected", "0.00"));
        addStatRow(statTable, "Students Involved",     summary.getOrDefault("totalStudents",  "0"));
        doc.add(statTable);

        // ══════════════════════════════════════════
        // CHART PAGE
        // ══════════════════════════════════════════
        doc.newPage();
        doc.add(sectionTitle("Analytics Charts"));
        doc.add(new Paragraph("\n"));

        // ── Chart 1: Bar Chart — Monthly Summons ──
        drawBarChart(cb, doc, monthlySummons, 36, 480, 523, 200);
        doc.add(new Paragraph("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"));

        // ── Chart 2: Pie Chart — Summons Status ──
        int paid   = Integer.parseInt(summary.getOrDefault("totalPaid",   "0"));
        int unpaid = Integer.parseInt(summary.getOrDefault("totalUnpaid", "0"));
        int appeal = Integer.parseInt(summary.getOrDefault("totalAppealed","0"));
        drawPieChart(cb, doc, paid, unpaid, appeal, 160, 230, 80);

        // ── Chart 3: Bar Chart — Monthly Collections ──
        drawCollectionChart(cb, doc, monthlyPayments, 320, 165, 255, 160);

        doc.add(new Paragraph("\n\n\n\n\n\n\n\n\n\n\n\n\n\n"));

        // ══════════════════════════════════════════
        // DATA TABLES PAGE
        // ══════════════════════════════════════════
        doc.newPage();

        // ── Monthly Summons Table ──
        doc.add(sectionTitle("Monthly Summons Breakdown"));
        PdfPTable msTable = new PdfPTable(4);
        msTable.setWidthPercentage(100);
        msTable.setWidths(new float[]{2f, 1.5f, 1.5f, 1.5f});
        msTable.setSpacingAfter(14);
        addTableHeader(msTable, "Month", "Total", "Vehicle", "Misconduct");
        int totalS = 0, totalV = 0, totalM = 0;
        boolean alt = false;
        for (Map<String, String> row : monthlySummons) {
            int m  = Integer.parseInt(row.get("month"));
            int t  = Integer.parseInt(row.get("total"));
            int v  = Integer.parseInt(row.get("vehicle"));
            int mc = Integer.parseInt(row.get("misconduct"));
            addTableRow(msTable, alt ? ALT_ROW : BaseColor.WHITE,
                MONTH_NAMES_FULL[m], String.valueOf(t), String.valueOf(v), String.valueOf(mc));
            totalS += t; totalV += v; totalM += mc;
            alt = !alt;
        }
        addTotalRow(msTable, "TOTAL", String.valueOf(totalS), String.valueOf(totalV), String.valueOf(totalM));
        doc.add(msTable);

        // ── Monthly Payments Table ──
        doc.add(sectionTitle("Monthly Payment & Collection"));
        PdfPTable mpTable = new PdfPTable(3);
        mpTable.setWidthPercentage(100);
        mpTable.setWidths(new float[]{2f, 2f, 2f});
        mpTable.setSpacingAfter(14);
        addTableHeader(mpTable, "Month", "Payments Count", "Amount Collected (RM)");
        double grandTotal = 0; int grandCount = 0;
        alt = false;
        for (Map<String, String> row : monthlyPayments) {
            int m    = Integer.parseInt(row.get("month"));
            int cnt  = Integer.parseInt(row.get("totalPayments"));
            double amt = Double.parseDouble(row.get("totalCollected"));
            addTableRow(mpTable, alt ? ALT_ROW : BaseColor.WHITE,
                MONTH_NAMES_FULL[m], String.valueOf(cnt), "RM " + row.get("totalCollected"));
            grandTotal += amt; grandCount += cnt;
            alt = !alt;
        }
        addTotalRow(mpTable, "TOTAL", String.valueOf(grandCount), String.format("RM %.2f", grandTotal));
        doc.add(mpTable);

        // ── Hotspots Table ──
        doc.add(sectionTitle("Top Offense Hotspot Locations"));
        PdfPTable hsTable = new PdfPTable(3);
        hsTable.setWidthPercentage(100);
        hsTable.setWidths(new float[]{0.5f, 3f, 1f});
        hsTable.setSpacingAfter(14);
        addTableHeader(hsTable, "#", "Location", "Total Offenses");
        int rank = 1; alt = false;
        for (Map<String, String> row : hotspots) {
            addTableRow(hsTable, alt ? ALT_ROW : BaseColor.WHITE,
                String.valueOf(rank++), row.get("location"), row.get("count"));
            alt = !alt;
        }
        doc.add(hsTable);

        // ── Detail Table ──
        if (!detail.isEmpty()) {
            doc.newPage();
            doc.add(sectionTitle("Detail — " + MONTH_NAMES_FULL[month] + " " + year));
            PdfPTable detTable = new PdfPTable(7);
            detTable.setWidthPercentage(100);
            detTable.setWidths(new float[]{1.2f, 1.5f, 1.5f, 2f, 1f, 1.2f, 1.5f});
            detTable.setSpacingAfter(14);
            addTableHeader(detTable, "Summons ID","Date","Type","Offense","Amount","Status","Student");
            alt = false;
            for (Map<String, String> row : detail) {
                addTableRow(detTable, alt ? ALT_ROW : BaseColor.WHITE,
                    row.get("summonsId"), row.get("summonsDate"), row.get("summonsType"),
                    row.get("offenseName"), "RM " + row.get("amount"),
                    row.get("status"), row.get("studentName"));
                alt = !alt;
            }
            doc.add(detTable);
        }

        doc.close();
        return out.toByteArray();
    }

    // ══════════════════════════════════════════
    // CHART DRAWING METHODS
    // ══════════════════════════════════════════

    /**
     * Bar chart: Monthly Summons (Total, Vehicle, Misconduct)
     * originX/Y = bottom-left corner of chart area
     * chartW/chartH = dimensions
     */
    private static void drawBarChart(PdfContentByte cb, Document doc,
            List<Map<String, String>> data, float originX, float originY,
            float chartW, float chartH) {

        if (data == null || data.isEmpty()) return;

        // Title
        ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
            new Phrase("Monthly Summons Breakdown (Vehicle vs Misconduct)", FONT_CHART_TITLE),
            originX, originY + chartH + 14, 0);

        // Find max value for scale
        int maxVal = 1;
        for (Map<String, String> row : data) {
            int t = Integer.parseInt(row.get("total"));
            if (t > maxVal) maxVal = t;
        }
        // Round up to nice number
        maxVal = (int)(Math.ceil(maxVal / 5.0) * 5);
        if (maxVal == 0) maxVal = 10;

        float padding   = 30f;
        float axisX     = originX + padding;
        float axisY     = originY;
        float plotW     = chartW - padding - 10;
        float plotH     = chartH;
        int   n         = data.size();
        float groupW    = plotW / n;
        float barW      = groupW * 0.25f;
        float groupGap  = groupW * 0.1f;

        // Y-axis gridlines & labels (5 lines)
        cb.setLineWidth(0.3f);
        for (int i = 0; i <= 5; i++) {
            float y = axisY + (plotH * i / 5f);
            int label = (int)(maxVal * i / 5);
            // Gridline
            cb.setColorStroke(new BaseColor(220, 220, 220));
            cb.moveTo(axisX, y); cb.lineTo(axisX + plotW, y); cb.stroke();
            // Label
            ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                new Phrase(String.valueOf(label), FONT_CHART_LABEL),
                axisX - 4, y - 3, 0);
        }

        // Draw bars per month
        for (int i = 0; i < n; i++) {
            Map<String, String> row = data.get(i);
            int mIdx = Integer.parseInt(row.get("month"));
            int veh  = Integer.parseInt(row.get("vehicle"));
            int mis  = Integer.parseInt(row.get("misconduct"));
            int tot  = Integer.parseInt(row.get("total"));

            float groupLeft = axisX + i * groupW + groupGap;

            // Vehicle bar (blue)
            float hVeh = (maxVal > 0) ? (veh  / (float) maxVal) * plotH : 0;
            cb.setColorFill(BAR_VEH);
            cb.rectangle(groupLeft, axisY, barW, hVeh);
            cb.fill();

            // Misconduct bar (orange)
            float hMis = (maxVal > 0) ? (mis  / (float) maxVal) * plotH : 0;
            cb.setColorFill(BAR_MISC);
            cb.rectangle(groupLeft + barW + 2, axisY, barW, hMis);
            cb.fill();

            // Total label above taller bar
            float hMax = Math.max(hVeh, hMis);
            if (tot > 0) {
                ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
                    new Phrase(String.valueOf(tot), FONT_CHART_LABEL),
                    groupLeft + barW, axisY + hMax + 4, 0);
            }

            // X-axis month label
            ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
                new Phrase(MONTH_NAMES[mIdx], FONT_CHART_LABEL),
                groupLeft + barW, axisY - 10, 0);
        }

        // Axes
        cb.setColorStroke(new BaseColor(180, 180, 180));
        cb.setLineWidth(0.8f);
        cb.moveTo(axisX, axisY); cb.lineTo(axisX, axisY + plotH); cb.stroke(); // Y
        cb.moveTo(axisX, axisY); cb.lineTo(axisX + plotW, axisY); cb.stroke(); // X

        // Legend
        float lx = axisX + plotW - 120;
        float ly = axisY + plotH + 2;
        drawLegendDot(cb, lx,      ly, BAR_VEH,  "Vehicle");
        drawLegendDot(cb, lx + 60, ly, BAR_MISC, "Misconduct");
    }

    /**
     * Pie/doughnut chart: Paid vs Unpaid vs Appealed
     */
    private static void drawPieChart(PdfContentByte cb, Document doc,
            int paid, int unpaid, int appeal,
            float centerX, float centerY, float radius) {

        int total = paid + unpaid + appeal;

        // Title
        ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
            new Phrase("Summons Status Distribution", FONT_CHART_TITLE),
            centerX - radius, centerY + radius + 18, 0);

        if (total == 0) {
            ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
                new Phrase("No data", FONT_CHART_LABEL), centerX, centerY, 0);
            return;
        }

        float[] values = { paid, unpaid, appeal };
        BaseColor[] colors = { PIE_PAID, PIE_UNPAID, PIE_APPEAL };
        String[] labels = { "Paid", "Unpaid", "Appealed" };

        float startAngle = 90f; // start from top
        for (int i = 0; i < values.length; i++) {
            if (values[i] == 0) continue;
            float sweep = (values[i] / (float) total) * 360f;

            cb.setColorFill(colors[i]);
            // Draw pie slice as a filled arc sector
            cb.moveTo(centerX, centerY);
            // Approximate arc with line segments
            int steps = Math.max(3, (int)(sweep / 3));
            for (int s = 0; s <= steps; s++) {
                double angle = Math.toRadians(startAngle - (sweep * s / steps));
                float px = centerX + (float)(radius * Math.cos(angle));
                float py = centerY + (float)(radius * Math.sin(angle));
                cb.lineTo(px, py);
            }
            cb.closePath();
            cb.fill();

            // Draw white divider line
            cb.setColorStroke(BaseColor.WHITE);
            cb.setLineWidth(1.5f);
            double startRad = Math.toRadians(startAngle);
            cb.moveTo(centerX, centerY);
            cb.lineTo(centerX + (float)(radius * Math.cos(startRad)),
                      centerY + (float)(radius * Math.sin(startRad)));
            cb.stroke();

            startAngle -= sweep;
        }

        // White center circle (doughnut hole)
        cb.setColorFill(BaseColor.WHITE);
        cb.circle(centerX, centerY, radius * 0.45f);
        cb.fill();

        // Center label
        ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
            new Phrase(String.valueOf(total),
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, UMT_BLUE)),
            centerX, centerY + 2, 0);
        ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
            new Phrase("Total", FONT_CHART_LABEL), centerX, centerY - 9, 0);

        // Legend
        float lx = centerX + radius + 14;
        float ly = centerY + 30;
        for (int i = 0; i < labels.length; i++) {
            int pct = total > 0 ? Math.round(values[i] / total * 100) : 0;
            cb.setColorFill(colors[i]);
            cb.rectangle(lx, ly - (i * 18), 10, 10);
            cb.fill();
            ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
                new Phrase(labels[i] + " (" + (int)values[i] + ", " + pct + "%)", FONT_CHART_LABEL),
                lx + 14, ly - (i * 18), 0);
        }
    }

    /**
     * Bar chart: Monthly collection amount (RM)
     */
    private static void drawCollectionChart(PdfContentByte cb, Document doc,
            List<Map<String, String>> data,
            float originX, float originY, float chartW, float chartH) {

        if (data == null || data.isEmpty()) return;

        ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
            new Phrase("Monthly Collection (RM)", FONT_CHART_TITLE),
            originX, originY + chartH + 14, 0);

        double maxVal = 1;
        for (Map<String, String> row : data) {
            double amt = Double.parseDouble(row.get("totalCollected"));
            if (amt > maxVal) maxVal = amt;
        }
        maxVal = Math.ceil(maxVal / 50.0) * 50;
        if (maxVal == 0) maxVal = 100;

        float padding = 40f;
        float axisX   = originX + padding;
        float axisY   = originY;
        float plotW   = chartW - padding - 10;
        float plotH   = chartH;
        int   n       = data.size();
        float barW    = (plotW / n) * 0.55f;
        float step    = plotW / n;

        // Gridlines
        cb.setLineWidth(0.3f);
        for (int i = 0; i <= 4; i++) {
            float y = axisY + (plotH * i / 4f);
            cb.setColorStroke(new BaseColor(220, 220, 220));
            cb.moveTo(axisX, y); cb.lineTo(axisX + plotW, y); cb.stroke();
            ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                new Phrase(String.format("%.0f", maxVal * i / 4), FONT_CHART_LABEL),
                axisX - 3, y - 3, 0);
        }

        // Bars
        for (int i = 0; i < n; i++) {
            Map<String, String> row = data.get(i);
            int mIdx = Integer.parseInt(row.get("month"));
            double amt = Double.parseDouble(row.get("totalCollected"));

            float barX = axisX + i * step + (step - barW) / 2;
            float barH = (maxVal > 0) ? (float)(amt / maxVal) * plotH : 0;

            cb.setColorFill(BAR_TOTAL);
            cb.rectangle(barX, axisY, barW, barH);
            cb.fill();

            if (amt > 0) {
                ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
                    new Phrase(String.format("%.0f", amt), FONT_CHART_LABEL),
                    barX + barW / 2, axisY + barH + 3, 0);
            }

            ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
                new Phrase(MONTH_NAMES[mIdx], FONT_CHART_LABEL),
                barX + barW / 2, axisY - 10, 0);
        }

        // Axes
        cb.setColorStroke(new BaseColor(180, 180, 180));
        cb.setLineWidth(0.8f);
        cb.moveTo(axisX, axisY); cb.lineTo(axisX, axisY + plotH); cb.stroke();
        cb.moveTo(axisX, axisY); cb.lineTo(axisX + plotW, axisY); cb.stroke();
    }

    // ── Legend helper ──
    private static void drawLegendDot(PdfContentByte cb, float x, float y,
            BaseColor color, String label) {
        cb.setColorFill(color);
        cb.rectangle(x, y, 8, 8);
        cb.fill();
        ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
            new Phrase(label, FONT_CHART_LABEL), x + 11, y, 0);
    }

    // ── Table helpers ──
    private static Paragraph sectionTitle(String text) {
        Paragraph p = new Paragraph(text, FONT_SECTION);
        p.setSpacingBefore(10); p.setSpacingAfter(6);
        return p;
    }
    private static void addStatRow(PdfPTable t, String label, String value) {
        PdfPCell c1 = new PdfPCell(new Phrase(label, FONT_BODY_BOLD));
        c1.setBorder(Rectangle.BOTTOM); c1.setPadding(5);
        PdfPCell c2 = new PdfPCell(new Phrase(value, FONT_BODY));
        c2.setBorder(Rectangle.BOTTOM); c2.setPadding(5);
        t.addCell(c1); t.addCell(c2);
    }
    private static void addTableHeader(PdfPTable t, String... headers) {
        for (String h : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(h, FONT_HEADER));
            cell.setBackgroundColor(HEADER_BG); cell.setPadding(6);
            cell.setBorder(Rectangle.NO_BORDER);
            t.addCell(cell);
        }
    }
    private static void addTableRow(PdfPTable t, BaseColor bg, String... values) {
        for (String v : values) {
            PdfPCell cell = new PdfPCell(new Phrase(v != null ? v : "—", FONT_BODY));
            cell.setBackgroundColor(bg); cell.setPadding(5);
            cell.setBorder(Rectangle.BOTTOM);
            cell.setBorderColor(new BaseColor(220, 220, 220));
            t.addCell(cell);
        }
    }
    private static void addTotalRow(PdfPTable t, String... values) {
        for (String v : values) {
            PdfPCell cell = new PdfPCell(new Phrase(v, FONT_BODY_BOLD));
            cell.setBackgroundColor(new BaseColor(220, 230, 255));
            cell.setPadding(5); cell.setBorder(Rectangle.TOP);
            t.addCell(cell);
        }
    }
}
