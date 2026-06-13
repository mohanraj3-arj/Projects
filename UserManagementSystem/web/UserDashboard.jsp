<%-- 
    Document   : UserDashboard
    Created on : 20 Dec 2025, 12:07:21 pm
    Author     : arjun
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>User Profile</title>
        <link rel="stylesheet" href="style.css">

    </head>
    <body>
        <form method="post">
            <button type="submit" name="submitbutton">View Profile</button>
        </form>
        
        
        
        <%
if(request.getParameter("submitbutton") != null){
    try{
        String username = (String)session.getAttribute("username");
        String useremail = (String)session.getAttribute("useremail");

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/Management", "root", "mysql");

        String select = "select * from UserManagement where UserName='"+username+"' and Email='"+useremail+"'";

        Statement stmt = conn.createStatement();
        ResultSet res1 = stmt.executeQuery(select);

        out.println("<h2 class='page-title'>User Profile Details</h2>");

        out.println("<div class='table-container'>");

        out.println("<div class='table-header'>"
                + "<div>Field</div>"
                + "<div>Value</div>"
                + "</div>");

        while(res1.next()){
            out.println("<div class='table-row'>");
            out.println("<div>User Name</div>");
            out.println("<div>" + res1.getString("UserName") + "</div>");
            out.println("</div>");

            out.println("<div class='table-row'>");
            out.println("<div>Email</div>");
            out.println("<div>" + res1.getString("Email") + "</div>");
            out.println("</div>");
        }

        out.println("</div>");
        conn.close();
    }
    catch(Exception ex){
        out.println(ex.getMessage());
    }
}
%>

        
        
        
    </body>
</html>
