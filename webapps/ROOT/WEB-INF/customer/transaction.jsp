<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="com.banking.model.UserType"%>
<%@ page import="com.banking.model.User"%>
<%@ page import="com.banking.utils.CustomException"%>
<%@ page import="com.banking.controller.UserController"%>
<%@ page import="com.banking.utils.CookieEncryption"%>
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
	if (UserId == null) {
		response.sendRedirect(request.getContextPath() + "/bank/login");
	}else {
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
				href="<%=request.getContextPath()%>/bank/customer/account">Accounts</a></li>
			<li><a
				href="<%=request.getContextPath()%>/bank/customer/transaction"
				class="active">Transactions</a></li>
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
	<div class="transfer-change-button">
		<c:if test="${not outSideBank}">
			<form action="<%=request.getContextPath()%>/bank/transferOutSideBank"
				method="post">
				<button>Transfer Out Side Bank</button>
			</form>
		</c:if>
		<c:if test="${outSideBank}">
			<form action="<%=request.getContextPath()%>/bank/transferInBank"
				method="post">
				<button>Transfer With in Bank</button>
			</form>
		</c:if>
	</div>
	<div id="transfer-container">
		<div class="deposit-content" id="transfer-content">
			<div class="deposit-image">
				<img src="<%=request.getContextPath()%>/images/Payment.png"
					alt="Withdraw Image" id="transfer-image">
			</div>
			<div id="form">
				<form class="input-form" id="transfer-form" method="post"
					action="${not outSideBank ? withinBank: otherBank}">
					<c:if test="${not empty inactiveAccount}">
						<div id="invalid-account-error"
							class="invalid-accountnumber-error">
							<i class="fa-solid fa-triangle-exclamation"></i>
							<p>${inactiveAccount}</p>
						</div>
					</c:if>
					<c:if test="${not empty success}">
						<div class="usercreation-message success"
							id="usercreation-message">
							<i class="fa-solid fa-thumbs-up"></i>
							<p>${success}</p>
						</div>
					</c:if>
					<c:if test="${not empty failed}">
						<div class="usercreation-message failed" id="usercreation-message">
							<i class="fa-solid fa-thumbs-down"></i>
							<p>${failed}</p>
						</div>
					</c:if>
					<label for="account-number">Account Number</label>
					<c:choose>
						<c:when test="${not empty success}">
							<input type="text" name="accountNumber" pattern="\d{12}"
								maxlength="12" placeholder="Enter the Account Number" value=""
								required>
						</c:when>
						<c:otherwise>
							<input type="text" name="accountNumber" pattern="\d{12}"
								maxlength="12" placeholder="Enter the Account Number"
								value="${param.accountNumber}" required>
						</c:otherwise>
					</c:choose>
					<c:if test="${not empty invalidAccount}">
						<div id="invalid-account-error"
							class="invalid-accountnumber-error transfer">
							<i class="fa-solid fa-triangle-exclamation"></i>
							<p>${invalidAccount}</p>
						</div>
					</c:if>
					<c:if test="${outSideBank}">
						<label for="ifsc">IFSC Code</label>
						<input type="text" name="ifsc" placeholder="Enter the IFSC Code"
							required>
					</c:if>
					<label for="amount">Transfer Amount</label>
					<c:choose>
						<c:when test="${not empty success}">
							<input type="number" name="amount" step="0.01"
								placeholder="Enter Amount to Transfer" value="" required>
						</c:when>
						<c:otherwise>
							<input type="number" name="amount" step="0.01"
								placeholder="Enter Amount to Transfer" value="${param.amount}"
								required>
						</c:otherwise>
					</c:choose>
					<c:if test="${not empty invalidBalance}">
						<div id="invalid-account-error"
							class="invalid-accountnumber-error transfer">
							<i class="fa-solid fa-triangle-exclamation"></i>
							<p>${invalidBalance}</p>
						</div>
					</c:if>
					<label for="description">Small Description</label>
					<c:choose>
						<c:when test="${not empty success}">
							<textarea id="message" name="message" rows="2" cols="50"
								placeholder="Enter Your  Description" required></textarea>
						</c:when>
						<c:otherwise>
							<textarea id="message" name="message" rows="2" cols="50"
								placeholder="Enter Your  Description" required>${param.message}</textarea>
						</c:otherwise>
					</c:choose>
					<input type="submit" value="Transfer">
				</form>
			</div>
		</div>
	</div>
	<%-- <div class="transfer-change-button">
		<c:if test="${not outSideBank}">
			<form action="<%=request.getContextPath()%>/transferOutSideBank"
				method="post">
				<button>Transfer Out Side Bank</button>
			</form>
		</c:if>
		<c:if test="${outSideBank}">
			<form action="<%=request.getContextPath()%>/transferInBank"
				method="post">
				<button>Transfer With in Bank</button>
			</form>
		</c:if>
	</div> --%>
</body>
</html>