package ServletFiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

import java.io.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Properties;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

// FIX: ByteArrayDataSource lives in jakarta.mail.util — NOT jakarta.activation
import jakarta.mail.*;
import jakarta.mail.internet.*;
import jakarta.mail.util.ByteArrayDataSource;

@WebServlet("/MonthlyReport")
public class MonthlyReportServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // SMTP config — shared with MonthlyReportScheduler
    static final String SMTP_FROM     = "arjunmohanraj143@gmail.com";
    static final String SMTP_APP_PASS = "cnjiucsmvafkikhq";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session guard
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("LoginPage.jsp");
            return;
        }

        Integer userId   = (Integer) session.getAttribute("userId");
        String  userName = (String)  session.getAttribute("userName");

        if (userId == null) {
            response.sendRedirect("LoginPage.jsp");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            // Get user email from DB
            String userEmail = getUserEmail(con, userId);
            if (userEmail == null) {
                showError(response, "Your email address was not found. Please check your account.");
                return;
            }

            // Build PDF in memory
            LocalDate today    = LocalDate.now();
            byte[]    pdfBytes = buildMonthlyPdf(con, userId, userName, today, false);

            String monthLabel = today.format(DateTimeFormatter.ofPattern("MMMM yyyy"));
            String filename   = "CardManager_Report_" +
                                today.format(DateTimeFormatter.ofPattern("MMMM_yyyy")) + ".pdf";

            // 1. Stream PDF to browser → user downloads immediately
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition",
                    "attachment; filename=\"" + filename + "\"");
            response.setContentLength(pdfBytes.length);
            response.getOutputStream().write(pdfBytes);
            response.getOutputStream().flush();

            // 2. Email PDF in background thread — doesn't delay the download
            final String emailCopy = userEmail;
            final String nameCopy  = userName;
            final byte[] pdfCopy   = pdfBytes;
            final String fileCopy  = filename;
            final String lblCopy   = monthLabel;

            new Thread(() -> {
                try {
                    sendReportEmail(emailCopy, nameCopy, lblCopy, pdfCopy, fileCopy);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }, "cardmanager-email-sender").start();

        } catch (Exception e) {
            e.printStackTrace();
            showError(response, "Report generation failed: " + e.getMessage());
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  PDF BUILDER
    //  public static — called by this servlet AND MonthlyReportScheduler
    // ════════════════════════════════════════════════════════════════════════

    public static byte[] buildMonthlyPdf(Connection con, int userId,
            String userName, LocalDate reportDate, boolean isAuto) throws Exception {

        String monthYear = reportDate.format(DateTimeFormatter.ofPattern("MMMM yyyy"));

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Document doc = new Document(PageSize.A4.rotate());
        PdfWriter.getInstance(doc, baos);
        doc.open();

        // Fonts
        Font titleFont   = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
        Font labelFont   = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL);
        Font noteFont    = new Font(Font.FontFamily.HELVETICA,  9, Font.ITALIC,
                                    new BaseColor(120, 120, 120));
        Font headFont    = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD,
                                    BaseColor.WHITE);
        Font rowFont     = new Font(Font.FontFamily.HELVETICA, 10);
        Font totalFont   = new Font(Font.FontFamily.HELVETICA, 13, Font.BOLD);
        Font summaryFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL);

        // PDF Header
        doc.add(new Paragraph("MONTHLY CREDIT CARD REPORT", titleFont));
        doc.add(new Paragraph("User  : " + userName, labelFont));
        doc.add(new Paragraph("Month : " + monthYear, labelFont));
        if (isAuto) {
            doc.add(new Paragraph(
                    "This report was auto-generated at month-end.", noteFont));
        }
        doc.add(new Paragraph(
                "Generated on : " + LocalDate.now()
                        .format(DateTimeFormatter.ofPattern("dd MMM yyyy")), noteFont));
        doc.add(new Paragraph(" "));

        // Table
        PdfPTable table = new PdfPTable(6);
        table.setWidthPercentage(100);
        table.setWidths(new int[]{2, 5, 4, 5, 3, 3});

        BaseColor navyBg = new BaseColor(15, 23, 42);
        String[] heads = {"#", "Card", "Category", "Merchant", "Amount (\u20b9)", "Date"};
        for (String h : heads) {
            PdfPCell cell = new PdfPCell(new Phrase(h, headFont));
            cell.setHorizontalAlignment(Element.ALIGN_CENTER);
            cell.setBackgroundColor(navyBg);
            cell.setPadding(7);
            table.addCell(cell);
        }

        // Fetch transactions for target month
        PreparedStatement ps = con.prepareStatement(
            "SELECT t.transaction_id, c.card_name, c.card_last4, " +
            "cat.category_name, t.merchant_name, t.amount, t.transaction_date " +
            "FROM transactions t " +
            "JOIN credit_cards c  ON t.card_id     = c.card_id " +
            "JOIN categories  cat ON t.category_id = cat.category_id " +
            "WHERE c.user_id = ? " +
            "AND MONTH(t.transaction_date) = ? " +
            "AND YEAR(t.transaction_date)  = ? " +
            "ORDER BY t.transaction_date ASC, t.transaction_id ASC");

        ps.setInt(1, userId);
        ps.setInt(2, reportDate.getMonthValue());
        ps.setInt(3, reportDate.getYear());
        ResultSet rs = ps.executeQuery();

        BigDecimal total    = BigDecimal.ZERO;
        int        rowCount = 0;
        boolean    altRow   = false;

        int[] aligns = {
            Element.ALIGN_CENTER,  // #
            Element.ALIGN_LEFT,    // Card
            Element.ALIGN_CENTER,  // Category
            Element.ALIGN_LEFT,    // Merchant
            Element.ALIGN_RIGHT,   // Amount
            Element.ALIGN_CENTER   // Date
        };

        while (rs.next()) {
            BigDecimal amount = BigDecimal.valueOf(rs.getDouble("amount"))
                                          .setScale(2, RoundingMode.HALF_UP);
            String merchant = rs.getString("merchant_name");

            BaseColor rowBg = altRow
                    ? new BaseColor(241, 245, 249)
                    : BaseColor.WHITE;
            altRow = !altRow;
            rowCount++;

            String[] cells = {
                String.valueOf(rowCount),
                rs.getString("card_name") + " (****" + rs.getString("card_last4") + ")",
                rs.getString("category_name"),
                merchant != null ? merchant : "\u2014",
                String.format("%.2f", amount),
                rs.getDate("transaction_date").toString()
            };

            for (int i = 0; i < cells.length; i++) {
                PdfPCell c = new PdfPCell(new Phrase(cells[i], rowFont));
                c.setHorizontalAlignment(aligns[i]);
                c.setBackgroundColor(rowBg);
                c.setBorderColor(new BaseColor(226, 232, 240));
                c.setPadding(5);
                table.addCell(c);
            }

            total = total.add(amount);
        }
        rs.close();
        ps.close();

        // Empty month row
        if (rowCount == 0) {
            PdfPCell empty = new PdfPCell(
                    new Phrase("No transactions found for " + monthYear + ".", rowFont));
            empty.setColspan(6);
            empty.setHorizontalAlignment(Element.ALIGN_CENTER);
            empty.setPadding(14);
            table.addCell(empty);
        }

        doc.add(table);
        doc.add(new Paragraph(" "));

        // Totals
        doc.add(new Paragraph(
                "TOTAL MONTHLY SPENDING :  \u20b9 " + String.format("%.2f", total),
                totalFont));

        if (rowCount > 0) {
            doc.add(new Paragraph(" "));
            BigDecimal avg = total.divide(
                    BigDecimal.valueOf(rowCount), 2, RoundingMode.HALF_UP);
            doc.add(new Paragraph(
                    "Total Transactions          : " + rowCount, summaryFont));
            doc.add(new Paragraph(
                    "Average per Transaction : \u20b9 " +
                    String.format("%.2f", avg), summaryFont));
        }

        doc.close();
        return baos.toByteArray();
    }

    // ════════════════════════════════════════════════════════════════════════
    //  EMAIL SENDER
    //  public static — called by this servlet AND MonthlyReportScheduler
    // ════════════════════════════════════════════════════════════════════════

    public static void sendReportEmail(String toEmail, String toName,
            String monthLabel, byte[] pdfBytes, String filename) throws Exception {

        Properties props = new Properties();
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session mailSession = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_FROM, SMTP_APP_PASS);
            }
        });

        Message msg = new MimeMessage(mailSession);
        msg.setFrom(new InternetAddress(SMTP_FROM, "CardManager"));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        msg.setSubject("Your Monthly Spending Report \u2013 " + monthLabel);

        // Email body
        MimeBodyPart textPart = new MimeBodyPart();
        textPart.setText(
            "Hi " + toName + ",\n\n" +
            "Your credit card spending report for " + monthLabel + " is attached.\n\n" +
            "You can also download it anytime from the CardManager dashboard " +
            "by clicking \"Send PDF\".\n\n" +
            "Best regards,\n" +
            "CardManager");

        // FIX: ByteArrayDataSource from jakarta.mail.util (correct package)
        MimeBodyPart attachPart = new MimeBodyPart();
        ByteArrayDataSource bads = new ByteArrayDataSource(pdfBytes, "application/pdf");
        attachPart.setDataHandler(new jakarta.activation.DataHandler(bads));
        attachPart.setFileName(filename);

        Multipart mp = new MimeMultipart();
        mp.addBodyPart(textPart);
        mp.addBodyPart(attachPart);
        msg.setContent(mp);

        Transport.send(msg);
        System.out.println("[CardManager] Report emailed to: " + toEmail);
    }

    // ════════════════════════════════════════════════════════════════════════
    //  DB HELPER
    //  public static — called by MonthlyReportScheduler too
    // ════════════════════════════════════════════════════════════════════════

    public static String getUserEmail(Connection con, int userId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT email FROM users WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("email") : null;
            }
        }
    }

    // Error page helper
    private void showError(HttpServletResponse response, String msg)
            throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html><html><head>" +
            "<meta charset='UTF-8'>" +
            "<style>" +
            "body{font-family:Outfit,sans-serif;padding:40px;background:#f1f5f9}" +
            ".box{background:#fff;border-radius:14px;padding:32px;max-width:500px;" +
            "margin:0 auto;border:1px solid #e2e8f0;box-shadow:0 4px 16px rgba(0,0,0,.08)}" +
            "h2{color:#ef4444}a{color:#3b82f6;text-decoration:none;font-weight:600}" +
            "</style></head><body>" +
            "<div class='box'><h2>&#9888; Report Error</h2>" +
            "<p style='color:#64748b'>" + msg + "</p>" +
            "<a href='Dashboard.jsp'>&#8592; Back to Dashboard</a>" +
            "</div></body></html>");
    }
}