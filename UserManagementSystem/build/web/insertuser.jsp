<%-- 
    Document   : insertuser
    Created on : 21 Dec 2025, 12:02:39 am
    Author     : arjun
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Add User</title>
        <link rel="stylesheet" href="style.css">

    </head>
    <body>
        <form method="post">
            <label for="name">Enter a User Name</label>
            <input type="text" name="username"><br>
            
            <label for="password">Enter a User Password</label>
            <input type="password" name="userpass"><br>
            
            <label for="email">Enter a Email</label>
            <input type="email" name="email"><br>
            
           
            
            
            
            <button type="submit" name="SubmitDetails">ADD User</button>
            
        </form>
        
        
        <%
if(request.getParameter("SubmitDetails") != null){
    try{
        String userName = request.getParameter("username");
        String userpass = request.getParameter("userpass");
        String email = request.getParameter("email");

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection myconn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/Management", "root", "mysql");

        Statement state = myconn.createStatement();

        String query = "insert into UserManagement (UserName, UserPassword, Email) "
                     + "values('"+userName+"', '"+userpass+"', '"+email+"')";
        state.executeUpdate(query);

        String query1 = "select User_ID, UserName, Email, Roles, Created_At from UserManagement";
        ResultSet result2 = state.executeQuery(query1);

        out.println("<h2 class='success-msg'>User Added Successfully</h2>");
        out.println("<h2 class='page-title'>All Users</h2>");

        out.println("<div class='table-container'>");
        out.println("<div class='table-header'>"
                + "<div>ID</div>"
                + "<div>User Name</div>"
                + "<div>Email</div>"
                + "<div>Role</div>"
                + "<div>Created At</div>"
                + "</div>");

        while(result2.next()){
            String role = result2.getString("Roles");

            out.println("<div class='table-row'>");
            out.println("<div>" + result2.getInt("User_ID") + "</div>");
            out.println("<div>" + result2.getString("UserName") + "</div>");
            out.println("<div>" + result2.getString("Email") + "</div>");

            if("ADMIN".equals(role)){
                out.println("<div><span class='badge-admin'>ADMIN</span></div>");
            } else {
                out.println("<div><span class='badge-user'>USER</span></div>");
            }

            out.println("<div class='date-time'>" + result2.getString("Created_At") + "</div>");
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
