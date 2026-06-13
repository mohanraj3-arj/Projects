<%-- 
    Document   : updateuser
    Created on : 21 Dec 2025, 12:02:54 am
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
            
            
           
            
            <label for="oldid">Enter old User ID </label>
            <input type="number" name="existID"><br>
            
            <label for="showname">Enter New User Name</label>
            <input type="text" name="newname"><br>
            
            <label for="showgenre">Enter New User Password </label>
            <input type="Password" name="userpassword"><br>
            
            <label for="showplatform">Enter New User Email</label>
            <input type="email" name="useremail"><br>
            
            
            
            <button type="submit" name="FormSubmit">Update User</button>
            
            
        </form>

     <%
if(request.getParameter("FormSubmit") != null){
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection myconn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/Management", "root", "mysql");

        int oldID = Integer.parseInt(request.getParameter("existID"));
        String newname = request.getParameter("newname");
        String newpassword = request.getParameter("userpassword");
        String newemail = request.getParameter("useremail");

        Statement state = myconn.createStatement();

        String updateQuery =
            "UPDATE UserManagement SET " +
            "UserName='"+newname+"', " +
            "UserPassword='"+newpassword+"', " +
            "Email='"+newemail+"' " +
            "WHERE User_ID='"+oldID+"'";

        state.executeUpdate(updateQuery);

        String selectQuery =
            "SELECT User_ID, UserName, Email, Roles, Created_At FROM UserManagement";
        ResultSet result2 = state.executeQuery(selectQuery);

        out.println("<h2 class='success-msg'>User Updated Successfully</h2>");
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
