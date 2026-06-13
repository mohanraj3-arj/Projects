package ServletFiles;

import util.DBConnection;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.*;

public class DeleteCards extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("LoginPage.jsp");
            return;
        }

        int cardid = Integer.parseInt(request.getParameter("cardId"));

        try (Connection con = DBConnection.getConnection()) {

            /* Step 1 – Delete dependent transactions first */
            String deleteTransactions =
                "DELETE FROM transactions WHERE card_id = ?";
            PreparedStatement ps1 = con.prepareStatement(deleteTransactions);
            ps1.setInt(1, cardid);
            ps1.executeUpdate();

            /* Step 2 – Delete the card only for this user */
            String deleteCard =
                "DELETE FROM credit_cards WHERE card_id = ? AND user_id = ?";
            PreparedStatement ps2 = con.prepareStatement(deleteCard);
            ps2.setInt(1, cardid);
            ps2.setInt(2, userId);

            int result = ps2.executeUpdate();

            if (result > 0) {
                response.sendRedirect("Mycards.jsp");
            } else {
                response.getWriter().println("Unable to delete card.");
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            response.getWriter().println("Error: " + ex.getMessage());
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
}
