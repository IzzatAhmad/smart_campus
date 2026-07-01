package controller;

import dao.VehicleDAO;
import model.Student;
import model.Vehicle;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.*;

@WebServlet("/student/vehicle/register")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class StudentVehicleRegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.getRequestDispatcher("/student/vehicle_register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            String type  = req.getParameter("vehicleType");
            String plate = req.getParameter("plateNumber");
            String brand = req.getParameter("brand");
            String color = req.getParameter("color");
            String cc    = req.getParameter("engineCC");

            Part grantPart = req.getPart("grantImage");

            if (type == null || plate == null || brand == null || color == null || cc == null ||
                type.isBlank() || plate.isBlank() || brand.isBlank() || color.isBlank() || cc.isBlank() ||
                grantPart == null || grantPart.getSize() == 0) {

                req.setAttribute("error", "Please fill in all fields and upload grant image.");
                doGet(req, resp);
                return;
            }

            // ✅ Save under the deployed webapp's real path (works on any OS/server,
            //    not just the original dev machine)
            String uploadDir = getServletContext().getRealPath("")
                                + File.separator + "uploads"
                                + File.separator + "grants";
            Path uploadPath = Paths.get(uploadDir);
            Files.createDirectories(uploadPath);

            // ✅ Get file extension
            String original = Paths.get(grantPart.getSubmittedFileName()).getFileName().toString();
            String ext = "";
            int dot = original.lastIndexOf('.');
            if (dot >= 0) ext = original.substring(dot).toLowerCase();

            // Optional safety check
            if (!(ext.equals(".jpg") || ext.equals(".jpeg") || ext.equals(".png"))) {
                req.setAttribute("error", "Grant image must be JPG or PNG.");
                doGet(req, resp);
                return;
            }

            // ✅ Unique filename
            String fileName = "GRANT_" + s.getStudentId() + "_" + System.currentTimeMillis() + ext;
            Path filePath = uploadPath.resolve(fileName);

            // ✅ SAVE FILE (THIS IS THE KEY LINE)
            try (InputStream in = grantPart.getInputStream()) {
                Files.copy(in, filePath, StandardCopyOption.REPLACE_EXISTING);
            }

            System.out.println("IMAGE SAVED TO: " + filePath.toAbsolutePath());

            // ✅ Save only relative path for JSP usage
            Vehicle v = new Vehicle();
            v.setStudentId(s.getStudentId());
            v.setVehicleType(type.toUpperCase());
            v.setPlateNumber(plate.trim().toUpperCase());
            v.setBrand(brand.trim());
            v.setColor(color.trim());
            v.setEngineCC(cc.trim());
            v.setGrantImagePath("uploads/grants/" + fileName);
            v.setStatus("PENDING");

            new VehicleDAO().create(v);

            resp.sendRedirect(req.getContextPath() + "/student/vehicles");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Register vehicle error: " + e.getMessage());
            doGet(req, resp);
        }
    }
}