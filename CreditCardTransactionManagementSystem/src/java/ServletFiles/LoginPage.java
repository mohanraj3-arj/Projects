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
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginPage")
public class LoginPage extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String useremail = request.getParameter("UserEmail");
        String userpassword = request.getParameter("UserPassword");
        
        try (Connection myconnection = DBConnection.getConnection()) {
            
            String searchQuery = "SELECT * FROM users WHERE email = ?";
            PreparedStatement stmt = myconnection.prepareStatement(searchQuery);
            stmt.setString(1, useremail);
            ResultSet result = stmt.executeQuery();
            
            if (result.next()) {
                String hashedPasswordFromDB = result.getString("password");
                boolean passwordMatches = BCrypt.checkpw(userpassword, hashedPasswordFromDB);
                
                if (passwordMatches) {
                    HttpSession session = request.getSession();
                    session.setAttribute("userId", result.getInt("user_id"));
                    session.setAttribute("userName", result.getString("full_name"));
                    session.setAttribute("userEmail", result.getString("email"));
                    
                    response.sendRedirect("Dashboard.jsp");
                } else {
                    response.sendRedirect("LoginPage.jsp?msg=invalid");
                }
            } else {
                response.sendRedirect("LoginPage.jsp?msg=invalid");
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
        return "Secure Login with BCrypt password verification";
    }
}