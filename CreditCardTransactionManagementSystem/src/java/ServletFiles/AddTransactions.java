package ServletFiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;
import java.io.IOException;
import java.sql.*;

@WebServlet("/AddTransactions")
public class AddTransactions extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection con = DBConnection.getConnection()) {

            int cardId = Integer.parseInt(request.getParameter("card_id"));
            int categoryId = Integer.parseInt(request.getParameter("category_id"));
            double amount = Double.parseDouble(request.getParameter("amount"));
            String merchant = request.getParameter("merchant");
            String tdate = request.getParameter("tdate");

           
            Date sqlDate = Date.valueOf(tdate);

            String sql = "INSERT INTO transactions " +
                         "(card_id, category_id, amount, merchant_name, transaction_date, entry_type) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, cardId);
            ps.setInt(2, categoryId);
            ps.setDouble(3, amount);
            ps.setString(4, merchant);
            ps.setDate(5, sqlDate);
            ps.setString(6, "MANUAL");

            ps.executeUpdate();

            response.sendRedirect("Dashboard.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}
