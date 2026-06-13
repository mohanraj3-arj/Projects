<%-- 
    Document   : LoginPage
    Created on : 20 Dec 2025, 12:09:14 pm
    Author     : arjun
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login Page</title>
        <link rel="stylesheet" href="style.css">

    </head>
    <body>
        <form method="post">
        <label for="loginname">Enter User Name</label>
        <input type="text" name="loginname"><br>
        
        <label for="loginpassword">Enter User Password</label>
        <input type="password" name="loginpassword"><br>
        
        <button type="submit" name="loginbutton">Login</button>
        </form>
        
        <%
            
            if(request.getParameter("loginbutton") != null){
            try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection myconnection = DriverManager.getConnection("jdbc:mysql://localhost:3306/Management", "root", "mysql");
            String Username = (String)request.getParameter("loginname");
            String UserPassword = (String)request.getParameter("loginpassword");
            
            String UserSearch = "select Roles from UserManagement where UserName = '"+Username+"' and UserPassword = '"+UserPassword+"';";
            
            Statement stmt = myconnection.createStatement();
            ResultSet res = stmt.executeQuery(UserSearch);
            
            if (res.next()){
            String roles = res.getString("Roles");
            
            if("ADMIN".equals(roles)){
            response.sendRedirect("AdminDashboard.jsp");
            return;
            }
            else if("USER".equals(roles)){
            response.sendRedirect("UserDashboard.jsp");
            return;
            }
            
            }
            out.println("<h2> Access Denied! Unauthorized User </h2>");
            
            myconnection.close();
            }
            
            
            catch(ClassNotFoundException ex){
            out.println(ex.getMessage());
            }
            catch(SQLException ex){
            out.println(ex.getMessage());
            }
            }

            %>
        
        
    </body>
</html>
