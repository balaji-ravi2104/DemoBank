<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="java.util.List"%>
<%@ page import="com.banking.utils.CustomException"%>
<%@ page import="com.banking.model.Account"%>
<%@ page import="com.banking.controller.AccountController"%>
<%@ page import="com.banking.utils.CookieEncryption"%>
<%@ page import="com.banking.model.User"%>
<%@ page import="com.banking.model.UserType"%>
<%@ page import="com.banking.controller.UserController"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>JI Bank</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
	<%-- <%
	response.setHeader("Cache-Control", "no-cache,no-store,must-revalidate");
	response.setHeader("Pragma", "no-cache");

	if (session.getAttribute("user") == null) {
		response.sendRedirect(request.getContextPath() + "/bank/login");
	}
	%> --%>
	<%
	response.setHeader("Cache-Control", "no-cache,no-store,must-revalidate");
	response.setHeader("Pragma", "no-cache");
	String UserId = null;
	Cookie[] cookies = request.getCookies();
	if (cookies != null) {
		for (Cookie cookie : cookies) {
			if (cookie.getName().equals("userId")) {
		UserId = cookie.getValue();
			}
		}
	}
	List<Account> accountsList = null;
	if (UserId == null) {
		response.sendRedirect(request.getContextPath() + "/bank/login");
	} else {
		try {
			String decryptUserId = CookieEncryption.decrypt(UserId);
			if (decryptUserId == null) {
				response.sendRedirect(request.getContextPath() + "/bank/logout");
			}
			int userId = Integer.parseInt(decryptUserId);
			UserController userController = new UserController();
			User user = userController.getCustomerDetailsById(userId);
			if(user.getTypeOfUser() != UserType.CUSTOMER){
				response.sendRedirect(request.getContextPath() + "/bank/404");
			}
			AccountController accountController = new AccountController();
			accountsList = accountController.getAccountsOfCustomer(userId);
		} catch (CustomException e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/bank/logout");
		}
	}
	%>
	<div class="navbar-home">
		<div class="logo">
			<img src="<%=request.getContextPath()%>/images/logo.png" alt="logo">
		</div>
		<div>
			<li><a
				href="<%=request.getContextPath()%>/bank/customer/account"
				class="active">Accounts</a></li>
			<li><a
				href="<%=request.getContextPath()%>/bank/customer/transaction">Transactions</a></li>
			<li><a
				href="<%=request.getContextPath()%>/bank/customer/Statement">Statements</a></li>
			<li><a
				href="<%=request.getContextPath()%>/bank/customer/profile">Profile</a></li>
			<li>
				<form id="logoutForm"
					action="<%=request.getContextPath()%>/bank/logout" method="post">
					<button type="submit"
						style="border: none; background: none; cursor: pointer;">
						<i class="fa fa-sign-out" aria-hidden="true"
							style="font-size: 25px"></i>
					</button>
				</form>
			</li>
		</div>
	</div>
	<div class="switchaccount-container">
		<c:set var="accountNumber" value="1" />
		<c:forEach var="accounts" items="<%=accountsList%>">
			<div class="account-details"
				onclick="submitForm('${accounts.accountNumber}')">
				<h3>Account ${accountNumber}</h3>
				<div class="account-logo">
					<img src="<%=request.getContextPath()%>/images/AccountLogo.png"
						alt="Account Logo">
				</div>
				<table>
					<tr>
						<th>Account Id</th>
						<td>${accounts.accountId}</td>
					</tr>
					<tr>
						<th>Account Number</th>
						<td>${accounts.accountNumber}</td>
					</tr>
					<tr>
						<th>Branch Id</th>
						<td>${accounts.branchId}</td>
					</tr>
					<tr>
						<th>Account Type</th>
						<td>${accounts.accountType}</td>
					</tr>
					<tr>
						<th>Balance</th>
						<td>${accounts.balance}</td>
					</tr>
					<tr>
						<th>Primary Account</th>
						<td>${accounts.primaryAccount ?'Yes' :'No'}</td>
					</tr>
					<tr>
						<th>Account Status</th>
						<td>${accounts.accountStatus}</td>
					</tr>
				</table>
				<form id="form${accounts.accountNumber}"
					action="<%=request.getContextPath()%>/bank/changeAccount"
					method="post">
					<input type="hidden" name="accountNumber"
						value="${accounts.accountNumber}">
				</form>
			</div>
			<c:set var="accountNumber" value="${accountNumber + 1}" />
		</c:forEach>
	</div>
	<script>
		function submitForm(accountNumber) {
			var form = document.getElementById('form' + accountNumber);
			if (form) {
				form.submit();
			}
		}
	</script>
</body>
</html>