<%-- 
    Document   : searchuser
    Created on : 21 Dec 2025, 12:02:08 am
    Author     : arjun
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <link rel="stylesheet" href="style.css">

    </head>
    <body>
        <form method="post">
            
       
            
            <label for="showid">Enter a User ID To Search</label>
            <input type="number" name="text2"><br>
            
            <button type="submit" name="searchbutton">search</button>
            
        </form>
        
        
        
        
        <%
if(request.getParameter("searchbutton") != null){
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection myconn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/Management", "root", "mysql");

        int userid = Integer.parseInt(request.getParameter("text2"));

        String query = "select User_ID, UserName, Email, Roles, Created_At "
                     + "from UserManagement where User_ID = '"+userid+"'";

        Statement state = myconn.createStatement();
        ResultSet result1 = state.executeQuery(query);

        out.println("<h2 class='page-title'>Search Result</h2>");
        out.println("<div class='table-container'>");

        out.println("<div class='table-header'>"
                + "<div>ID</div>"
                + "<div>User Name</div>"
                + "<div>Email</div>"
                + "<div>Role</div>"
                + "<div>Created At</div>"
                + "</div>");

        boolean found = false;

        while(result1.next()){
            found = true;
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

        if(!found){
            out.println("<div class='no-data'>No user found for this ID</div>");
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
