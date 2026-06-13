<%-- 
    Document   : RegistrationPage
    Created on : 20 Dec 2025, 12:09:00 pm
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
        <label for="username">Enter User Name </label>
        <input type="text" name="username"><br>
        
        <label for="userpassword">Enter User Password</label>
        <input type="password" name="userpassword"><br>
        
        <label for="useremail">Enter User Email ID </label>
        <input type="email" name="useremail"><br>
        
        <button type="submit" name="submitbutton"> Register </button>
    </form>
        
        
        <%
        if(request.getParameter("submitbutton") != null){
       try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/Management", "root", "mysql");
        
        String username = (String)request.getParameter("username");
        
        String userpassword = (String)request.getParameter("userpassword");
        String useremail = (String)request.getParameter("useremail");
        

        String insertdata = "insert into UserManagement(UserName, UserPassword, Email) values('"+username+"', '"+userpassword+"', '"+useremail+"');";
        
        Statement stmt = conn.createStatement();
        int res1 = stmt.executeUpdate(insertdata);
        
        String selectdata = "select * from UserManagement where UserName = '"+username+"' and UserPassword = '"+userpassword+"' and Email = '"+useremail+"'; ";
        
        ResultSet res2 = stmt.executeQuery(selectdata);
        
        if(res2.next()){
            session.setAttribute("username", username);
            session.setAttribute("useremail", useremail);
            
        response.sendRedirect("UserDashboard.jsp");
        }
        else{
        out.println("<h2> access denied!</h2>");
        }
        conn.close();
            
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
