<%-- 
    Document   : deleteuser
    Created on : 21 Dec 2025, 12:02:24 am
    Author     : arjun
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Delete User</title>
        <link rel="stylesheet" href="style.css">

    </head>
    <body>
         <form method="post">
            <label for="userid">Enter User ID to Delete </label>
            <input type="number" name="userid"><br>
            
           
            
            <button type="submit" name="valueSubmit">Delete User</button>
         </form>
              
    <%
if(request.getParameter("valueSubmit") != null){
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/Management", "root", "mysql");

        int UserID = Integer.parseInt(request.getParameter("userid"));

        Statement stmt = conn.createStatement();

        String delete_query = "delete from UserManagement where User_ID = '"+UserID+"'";
        int re = stmt.executeUpdate(delete_query);

        out.println("<h2 class='success-msg'>User Deleted Successfully</h2>");

        String select1 = "select User_ID, UserName, Email, Roles, Created_At from UserManagement";
        ResultSet res = stmt.executeQuery(select1);

        out.println("<h2 class='page-title'>Updated User List</h2>");
        out.println("<div class='table-container'>");

        out.println("<div class='table-header'>"
                + "<div>ID</div>"
                + "<div>User Name</div>"
                + "<div>Email</div>"
                + "<div>Role</div>"
                + "<div>Created At</div>"
                + "</div>");

        while(res.next()){
            String role = res.getString("Roles");

            out.println("<div class='table-row'>");
            out.println("<div>" + res.getInt("User_ID") + "</div>");
            out.println("<div>" + res.getString("UserName") + "</div>");
            out.println("<div>" + res.getString("Email") + "</div>");

            if("ADMIN".equals(role)){
                out.println("<div><span class='badge-admin'>ADMIN</span></div>");
            } else {
                out.println("<div><span class='badge-user'>USER</span></div>");
            }

            out.println("<div class='date-time'>" + res.getString("Created_At") + "</div>");
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

         
                
        </form>    
        
        
    </body>
</html>
