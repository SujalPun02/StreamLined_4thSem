<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.StreamLined.model.User" %>

<%
    User user = (User) session.getAttribute("user");

    if (user != null) {
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin");
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/login");
    }

    return;
%>