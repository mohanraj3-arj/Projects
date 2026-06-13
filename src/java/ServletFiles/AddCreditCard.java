/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package ServletFiles;

import util.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;  
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.*;

/**
 *
 * @author arjun
 */
public class AddCreditCard extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try (Connection myconnection = DBConnection.getConnection()) {
            
            String CardName = (String)request.getParameter("CardName");
            int CardDigit = Integer.parseInt(request.getParameter("CardDigit"));
            
            int CardCvv = Integer.parseInt(request.getParameter("CardCvv"));
            
            
            int CardLimit = Integer.parseInt(request.getParameter("CardLimit"));
            
            
            
                        String CardExpiry = request.getParameter("CardExpiry");
            if (CardExpiry == null || CardExpiry.trim().isEmpty()) {
                CardExpiry = "12/25";  // Default if missing
            }
            
            
            
            
            
            
            
            
            HttpSession session = request.getSession();
            
            int userid = ((Integer)session.getAttribute("userId")).intValue();
            
            String inser_query = "INSERT into credit_cards(user_id, card_name, card_last4, Card_CVV, Expiry_date, credit_limit) values ('"+userid+"', '"+CardName+"', '"+CardDigit+"', '"+CardCvv+"', '"+CardExpiry+"', '"+CardLimit+"')";
          
            Statement stmt = myconnection.createStatement();
            int result = stmt.executeUpdate(inser_query);
            
            if(result > 0){
            response.sendRedirect("Dashboard.jsp");
            }
            else{
            response.sendRedirect(" **INVALID CARD DETAILS** ");
            }
            
               
            myconnection.close();
            
    }
        
        catch(Exception ex){
        out.println(ex.getMessage());
        }
    }
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
