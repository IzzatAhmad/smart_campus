/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.*;

@WebServlet("/grant/image")
public class GrantImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String fileName = req.getParameter("file");

        if (fileName == null || fileName.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // MUST match the upload path used by StudentVehicleRegisterServlet
        String uploadDir = getServletContext().getRealPath("")
                            + File.separator + "uploads"
                            + File.separator + "grants";
        Path filePath = Paths.get(uploadDir, fileName);

        if (!Files.exists(filePath)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Detect content type
        String contentType = Files.probeContentType(filePath);
        if (contentType == null) {
            contentType = "application/octet-stream";
        }

        resp.setContentType(contentType);
        resp.setContentLengthLong(Files.size(filePath));

        try (InputStream in = Files.newInputStream(filePath);
             OutputStream out = resp.getOutputStream()) {
            in.transferTo(out);
        }
    }
}