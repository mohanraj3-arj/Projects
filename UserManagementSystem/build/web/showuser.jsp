<%-- 
    Document   : showuser
    Created on : 21 Dec 2025, 12:03:33 am
    Author     : arjun
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Show All Users</title>
        <link rel="stylesheet" href="style.css">

    </head>
    <body>
        <form method="post">
            <button type="submit" name="showbutton">show</button>
        </form>
        
        <%
if(request.getParameter("showbutton") != null){
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");

        Connection myconn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/Management", "root", "mysql");

        String query = "select User_ID, UserName, Email, Roles, Created_At from UserManagement;";
        Statement state = myconn.createStatement();
        ResultSet result1 = state.executeQuery(query);

        out.println("<h2 class='page-title'>All Registered Users</h2>");
        out.println("<div class='table-container'>");

        out.println("<div class='table-header'>"
                + "<div>ID</div>"
                + "<div>User Name</div>"
                + "<div>Email</div>"
                + "<div>Role</div>"
                + "<div>Created At</div>"
                + "</div>");

        while(result1.next()){
            String role = result1.getString("Roles");

            out.println("<div class='table-row'>");
            out.println("<div>" + result1.getInt("User_ID") + "</div>");
            out.println("<div>" + result1.getString("UserName") + "</div>");
            out.println("<div>" + result1.getString("Email") + "</div>");

            if("ADMIN".equals(role)){
                out.println("<div><span class='badge-admin'>ADMIN</span></div>");
            } else {
                out.println("<div><span class='badge-user'>USER</span></div>");
            }

            out.println("<div class='date-time'>" + result1.getString("Created_At") + "</div>");
            out.println("</div>");
        }

        out.println("</div>");
        myconn.close();
    }
    catch(Exception ex){
        out.println(ex.getMessage());
    }
}
%>

    </body>
</html>
