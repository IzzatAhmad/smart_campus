package controller;

import dao.StudentDAO;
import model.Student;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class StudentRegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        //match your UI input names
        String name = req.getParameter("name");              // full name
        String matric = req.getParameter("matric");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String faculty = req.getParameter("faculty");        
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword"); 

        // Basic validation
        if (name == null || matric == null || email == null || phone == null || faculty == null ||
            password == null || confirmPassword == null ||
            name.isBlank() || matric.isBlank() || email.isBlank() || phone.isBlank() || faculty.isBlank() ||
            password.isBlank() || confirmPassword.isBlank()) {

            req.setAttribute("error", "Please fill in all fields.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        //Confirm password validation
        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Password and Confirm Password do not match.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        // Optional: enforce UMT email
        // If you don't want this rule yet, you can delete this block.
        if (!email.trim().toLowerCase().endsWith("@ocean.umt.edu.my")) {
            req.setAttribute("error", "Please use your UMT email (example: matric@ocean.umt.edu.my).");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        try {
            Student s = new Student();
            s.setStudentName(name.trim());
            s.setMatricNo(matric.trim());
            s.setEmail(email.trim());
            s.setPhoneNumber(phone.trim());
            s.setFaculty(faculty.trim()); // ✅ NEW
            s.setPassword(password);      // plain text for now

            Student created = new StudentDAO().register(s);

            if (created == null) {
                req.setAttribute("error", "Email or Matric No already exists.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }

            //auto login after register
            req.getSession().setAttribute("student", created);
            resp.sendRedirect(req.getContextPath() + "/login");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Register failed.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        }
    }
}

