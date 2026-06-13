package ServletFiles;

import util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/RegisterPage")
public class RegisterPage extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String username = request.getParameter("UserName");
        String useremail = request.getParameter("UserEmail");
        String userpassword = request.getParameter("UserPassword");
        
        try (Connection myconnection = DBConnection.getConnection()) {
            
            String checkQuery = "SELECT email FROM users WHERE email = ?";
            PreparedStatement checkStmt = myconnection.prepareStatement(checkQuery);
            checkStmt.setString(1, useremail);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                response.sendRedirect("RegisterPage.jsp?msg=exists");
                return;
            }
            
            String hashedPassword = BCrypt.hashpw(userpassword, BCrypt.gensalt(12));
            
            String insertQuery = "INSERT INTO users(full_name, email, password) VALUES (?, ?, ?)";
            PreparedStatement insertStmt = myconnection.prepareStatement(insertQuery);
            insertStmt.setString(1, username);
            insertStmt.setString(2, useremail);
            insertStmt.setString(3, hashedPassword);
            
            int result = insertStmt.executeUpdate();
            
            if (result > 0) {
                response.sendRedirect("LoginPage.jsp?msg=registered");
            } else {
                response.sendRedirect("RegisterPage.jsp?msg=failed");
            }
            
        } catch (Exception ex) {
            ex.printStackTrace();
            out.println("Error: " + ex.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Secure Registration with BCrypt password hashing";
    }
}