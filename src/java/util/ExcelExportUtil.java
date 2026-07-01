/*
 * ExcelExportUtil.java
 * Place in: src/java/util/ExcelExportUtil.java
 */
package util;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.ByteArrayOutputStream;
import java.util.List;
import java.util.Map;

public class ExcelExportUtil {

    private static final String[] MONTH_NAMES = {
        "", "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    };

    public static byte[] generate(
            int year, int month,
            Map<String, String> summary,
            List<Map<String, String>> monthlySummons,
            List<Map<String, String>> monthlyPayments,
            List<Map<String, String>> hotspots,
            List<Map<String, String>> detail) throws Exception {

        try (XSSFWorkbook wb = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            // ── Styles ──
            CellStyle headerStyle = wb.createCellStyle();
            headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            Font headerFont = wb.createFont();
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            CellStyle titleStyle = wb.createCellStyle();
            Font titleFont = wb.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 14);
            titleFont.setColor(IndexedColors.DARK_BLUE.getIndex());
            titleStyle.setFont(titleFont);

            CellStyle subTitleStyle = wb.createCellStyle();
            Font subFont = wb.createFont();
            subFont.setBold(true);
            subFont.setFontHeightInPoints((short) 11);
            subTitleStyle.setFont(subFont);

            CellStyle amtStyle = wb.createCellStyle();
            amtStyle.setDataFormat(wb.createDataFormat().getFormat("RM #,##0.00"));

            CellStyle altStyle = wb.createCellStyle();
            altStyle.setFillForegroundColor(IndexedColors.LIGHT_TURQUOISE.getIndex());
            altStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            // ══════════════════════════════════════════════════
            // SHEET 1 — Summary
            // ══════════════════════════════════════════════════
            Sheet s1 = wb.createSheet("Summary");
            s1.setColumnWidth(0, 7000);
            s1.setColumnWidth(1, 5000);

            int r = 0;
            Row titleRow = s1.createRow(r++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("Universiti Malaysia Terengganu — Bahagian Keselamatan");
            titleCell.setCellStyle(titleStyle);
            s1.addMergedRegion(new CellRangeAddress(0, 0, 0, 3));

            Row subRow = s1.createRow(r++);
            String periodLabel = month > 0
                ? "Monthly Report — " + MONTH_NAMES[month] + " " + year
                : "Annual Report — " + year;
            subRow.createCell(0).setCellValue(periodLabel);
            subRow.getCell(0).setCellStyle(subTitleStyle);
            s1.addMergedRegion(new CellRangeAddress(1, 1, 0, 3));
            r++;

            // Summary table
            String[][] summaryData = {
                {"Total Summons Issued",    summary.getOrDefault("totalSummons",  "0")},
                {"Total Paid",              summary.getOrDefault("totalPaid",     "0")},
                {"Total Unpaid",            summary.getOrDefault("totalUnpaid",   "0")},
                {"Total Collected (RM)",    summary.getOrDefault("totalCollected","0.00")},
                {"Students Involved",       summary.getOrDefault("totalStudents", "0")}
            };
            for (String[] pair : summaryData) {
                Row row = s1.createRow(r++);
                row.createCell(0).setCellValue(pair[0]);
                row.createCell(1).setCellValue(pair[1]);
            }

            // ══════════════════════════════════════════════════
            // SHEET 2 — Monthly Summons
            // ══════════════════════════════════════════════════
            Sheet s2 = wb.createSheet("Monthly Summons");
            s2.setColumnWidth(0, 4000);
            s2.setColumnWidth(1, 4000);
            s2.setColumnWidth(2, 4000);
            s2.setColumnWidth(3, 4000);

            Row h2 = s2.createRow(0);
            String[] headers2 = {"Month", "Total", "Vehicle", "Misconduct"};
            for (int i = 0; i < headers2.length; i++) {
                Cell c = h2.createCell(i);
                c.setCellValue(headers2[i]);
                c.setCellStyle(headerStyle);
            }

            int totalSummons = 0, totalVehicle = 0, totalMisconduct = 0;
            int rr = 1;
            for (Map<String, String> row : monthlySummons) {
                Row dataRow = s2.createRow(rr++);
                int m = Integer.parseInt(row.get("month"));
                int t = Integer.parseInt(row.get("total"));
                int v = Integer.parseInt(row.get("vehicle"));
                int mc= Integer.parseInt(row.get("misconduct"));
                dataRow.createCell(0).setCellValue(MONTH_NAMES[m]);
                dataRow.createCell(1).setCellValue(t);
                dataRow.createCell(2).setCellValue(v);
                dataRow.createCell(3).setCellValue(mc);
                totalSummons += t; totalVehicle += v; totalMisconduct += mc;
            }
            // Total row
            Row totalRow2 = s2.createRow(rr);
            totalRow2.createCell(0).setCellValue("TOTAL");
            totalRow2.getCell(0).setCellStyle(subTitleStyle);
            totalRow2.createCell(1).setCellValue(totalSummons);
            totalRow2.createCell(2).setCellValue(totalVehicle);
            totalRow2.createCell(3).setCellValue(totalMisconduct);

            // ══════════════════════════════════════════════════
            // SHEET 3 — Monthly Payments
            // ══════════════════════════════════════════════════
            Sheet s3 = wb.createSheet("Monthly Payments");
            s3.setColumnWidth(0, 4000);
            s3.setColumnWidth(1, 4000);
            s3.setColumnWidth(2, 5000);

            Row h3 = s3.createRow(0);
            String[] headers3 = {"Month", "Payments Count", "Amount Collected (RM)"};
            for (int i = 0; i < headers3.length; i++) {
                Cell c = h3.createCell(i);
                c.setCellValue(headers3[i]);
                c.setCellStyle(headerStyle);
            }

            int rrr = 1;
            double grandTotal = 0;
            int grandCount = 0;
            for (Map<String, String> row : monthlyPayments) {
                Row dataRow = s3.createRow(rrr++);
                int m  = Integer.parseInt(row.get("month"));
                int cnt= Integer.parseInt(row.get("totalPayments"));
                double amt = Double.parseDouble(row.get("totalCollected"));
                dataRow.createCell(0).setCellValue(MONTH_NAMES[m]);
                dataRow.createCell(1).setCellValue(cnt);
                Cell amtCell = dataRow.createCell(2);
                amtCell.setCellValue(amt);
                amtCell.setCellStyle(amtStyle);
                grandTotal += amt; grandCount += cnt;
            }
            Row totalRow3 = s3.createRow(rrr);
            totalRow3.createCell(0).setCellValue("TOTAL");
            totalRow3.getCell(0).setCellStyle(subTitleStyle);
            totalRow3.createCell(1).setCellValue(grandCount);
            Cell gtCell = totalRow3.createCell(2);
            gtCell.setCellValue(grandTotal);
            gtCell.setCellStyle(amtStyle);

            // ══════════════════════════════════════════════════
            // SHEET 4 — Hotspots
            // ══════════════════════════════════════════════════
            Sheet s4 = wb.createSheet("Hotspots");
            s4.setColumnWidth(0, 300); // rank
            s4.setColumnWidth(1, 8000);
            s4.setColumnWidth(2, 4000);

            Row h4 = s4.createRow(0);
            String[] headers4 = {"Rank", "Location", "Total Offenses"};
            for (int i = 0; i < headers4.length; i++) {
                Cell c = h4.createCell(i);
                c.setCellValue(headers4[i]);
                c.setCellStyle(headerStyle);
            }
            int rank = 1;
            for (Map<String, String> row : hotspots) {
                Row dataRow = s4.createRow(rank);
                dataRow.createCell(0).setCellValue(rank);
                dataRow.createCell(1).setCellValue(row.get("location"));
                dataRow.createCell(2).setCellValue(Integer.parseInt(row.get("count")));
                rank++;
            }

            // ══════════════════════════════════════════════════
            // SHEET 5 — Monthly Detail (if month selected)
            // ══════════════════════════════════════════════════
            if (!detail.isEmpty()) {
                String sheetName = MONTH_NAMES[month] + " " + year + " Detail";
                Sheet s5 = wb.createSheet(sheetName);
                s5.setColumnWidth(0, 3000);
                s5.setColumnWidth(1, 3500);
                s5.setColumnWidth(2, 4000);
                s5.setColumnWidth(3, 5000);
                s5.setColumnWidth(4, 4000);
                s5.setColumnWidth(5, 3000);
                s5.setColumnWidth(6, 3000);
                s5.setColumnWidth(7, 5000);
                s5.setColumnWidth(8, 3500);
                s5.setColumnWidth(9, 3500);
                s5.setColumnWidth(10, 4000);
                s5.setColumnWidth(11, 3500);

                Row h5 = s5.createRow(0);
                String[] headers5 = {
                    "Summons ID","Date","Type","Offense","Location",
                    "Amount","Status","Student","Matric","Paid Amount","Method","Pay Date"
                };
                for (int i = 0; i < headers5.length; i++) {
                    Cell c = h5.createCell(i);
                    c.setCellValue(headers5[i]);
                    c.setCellStyle(headerStyle);
                }
                int rd = 1;
                for (Map<String, String> row : detail) {
                    Row dataRow = s5.createRow(rd++);
                    dataRow.createCell(0).setCellValue(row.get("summonsId"));
                    dataRow.createCell(1).setCellValue(row.get("summonsDate"));
                    dataRow.createCell(2).setCellValue(row.get("summonsType"));
                    dataRow.createCell(3).setCellValue(row.get("offenseName"));
                    dataRow.createCell(4).setCellValue(row.get("location"));
                    dataRow.createCell(5).setCellValue(Double.parseDouble(row.get("amount")));
                    dataRow.createCell(6).setCellValue(row.get("status"));
                    dataRow.createCell(7).setCellValue(row.get("studentName"));
                    dataRow.createCell(8).setCellValue(row.get("matricNo"));
                    dataRow.createCell(9).setCellValue(Double.parseDouble(row.get("paymentAmount")));
                    dataRow.createCell(10).setCellValue(row.get("paymentMethod"));
                    dataRow.createCell(11).setCellValue(row.get("paymentDate"));
                }
            }

            wb.write(out);
            return out.toByteArray();
        }
    }
}
