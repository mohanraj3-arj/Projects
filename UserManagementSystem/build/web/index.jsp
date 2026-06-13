<%-- 
    Document   : index
    Created on : 20 Dec 2025, 12:06:52 pm
    Author     : arjun
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Home Page</title>
        <link rel="stylesheet" href="style.css">

    </head>
    <body>
        
<!--        <a href="RegistrationPage.jsp">Register For New User</a><br>
        <a href="LoginPage.jsp">Login For Admin</a>-->

<form action="RegistrationPage.jsp">
    <button type="submit" name="registration">Register</button>
</form>
<br><!-- comment -->

<form action="LoginPage.jsp">
    <button type="submit" name="Login">Login</button>
    
    
</form>












<script src="https://accounts.google.com/gsi/client" async defer></script>

<div id="g_id_onload"
     data-client_id="YOUR_CLIENT_ID_HERE"
     data-callback="handleCredentialResponse">
</div>

<div class="g_id_signin"></div>

<script>
function handleCredentialResponse(response) {
    fetch("GoogleLoginServlet.java", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: "credential=" + response.credential
    })
    .then(() => window.location.href = "dashboard.jsp");
}
</script>










        
    </body>
</html>
