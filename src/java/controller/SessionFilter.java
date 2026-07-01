/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import model.Student;
import model.PatrolStaff;
import model.ClericalStaff;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

@WebFilter(urlPatterns = {
    "/student/*",
    "/patrol/*",
    "/clerical/*"
})
public class SessionFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();

        // ── Skip filter for login and logout URLs ──
        if (path.endsWith("/login") || path.endsWith("/logout")) {
            chain.doFilter(request, response);
            return;
        }

        // ── No-cache headers on every protected response ──
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        HttpSession session = req.getSession(false);
        boolean loggedIn = false;

        if (path.startsWith("/student/")) {
            loggedIn = session != null && session.getAttribute("student") instanceof Student;
        } else if (path.startsWith("/patrol/")) {
            loggedIn = session != null && session.getAttribute("patrol") instanceof PatrolStaff;
        } else if (path.startsWith("/clerical/")) {
            loggedIn = session != null && session.getAttribute("clerical") instanceof ClericalStaff;
        }

        if (!loggedIn) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}