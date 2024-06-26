<%@page import="com.banking.model.Customer"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="com.banking.model.User"%>
<%@ page import="com.banking.model.UserType"%>
<%@ page import="com.banking.utils.CustomException"%>
<%@ page import="com.banking.controller.UserController"%>
<%@ page import="com.banking.utils.CookieEncryption"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
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
	} else {
		/* int userId = (int) session.getAttribute("currentUserId"); */
		try {
			String decryptUserId = CookieEncryption.decrypt(UserId);
			if (decryptUserId == null) {
		response.sendRedirect(request.getContextPath() + "/bank/logout");
			}
			int userId = Integer.parseInt(decryptUserId);
			UserController userController = new UserController();
			User user = userController.getCustomerDetailsById(userId);
			request.setAttribute("user", user);
			if (user.getTypeOfUser() != UserType.EMPLOYEE && user.getTypeOfUser() != UserType.ADMIN) {
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
				href="<%=request.getContextPath()%>/bank/employee/customer"
				class="active">Users</a></li>
			<li><a
				href="<%=request.getContextPath()%>/bank/employee/account">Accounts</a></li>
			<li><a
				href="<%=request.getContextPath()%>/bank/employee/transaction">Transactions</a></li>
			<c:if test="${user.getTypeOfUser() == UserType.ADMIN}">
				<li><a
					href="<%=request.getContextPath()%>/bank/employee/apiservice">API
						Service</a></li>
			</c:if>
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

	<div class="container-create-customer">
		<div class="create-customer-content">
			<div class="create-customer-image">
				<img src="<%=request.getContextPath()%>/images/createCustomer.png"
					alt="Customer Creation Image">
			</div>
			<div id="form">
				<form class="customer-form" id="customerForm" method="post"
					action="${not empty customerDetails ? updateAction : createAction}">
					<c:if test="${not empty userCreationSuccess}">
						<div class="usercreation-message success">
							<i class="fa-solid fa-thumbs-up"></i>
							<p>${userCreationSuccess}</p>
						</div>
					</c:if>
					<c:if test="${not empty userCreationFailed}">
						<div class="usercreation-message failed">
							<i class="fa-solid fa-thumbs-down"></i>
							<p>${userCreationFailed}</p>
						</div>
					</c:if>
					<c:if test="${not empty customerExists}">
						<div class="invalid-userid-error">
							<i class="fa-solid fa-triangle-exclamation"></i>
							<p>${customerExists}</p>
						</div>
					</c:if>
					<div class="form-row">
						<div class="form-group wider">
							<label for="firstname">First Name</label>
							<c:choose>
								<c:when test="${not empty userCreationSuccess}">
									<input type="text" name="firstname"
										placeholder="Enter the First Name" value="" required>
								</c:when>
								<c:otherwise>
									<input type="text" name="firstname"
										placeholder="Enter the First Name"
										value="${empty param.firstname ? (not empty customerDetails ? customerDetails.firstName : '') : param.firstname}"
										required>
								</c:otherwise>
							</c:choose>
							<c:if test="${not empty invalidFirstName}">
								<div class="customer-form-error">
									<p>${invalidFirstName}</p>
								</div>
							</c:if>
						</div>
						<div class="form-group">
							<label for="lastname">Last Name</label>
							<c:choose>
								<c:when test="${not empty userCreationSuccess}">
									<input type="text" name="lastname"
										placeholder="Enter the Last Name" value="" required>
								</c:when>
								<c:otherwise>
									<input type="text" name="lastname"
										placeholder="Enter the Last Name"
										value="${empty param.lastname ? (not empty customerDetails ? customerDetails.lastName : '') : param.lastname}"
										required>
								</c:otherwise>
							</c:choose>
							<c:if test="${not empty invalidLastName}">
								<div class="customer-form-error">
									<p>${invalidLastName}</p>
								</div>
							</c:if>
						</div>
					</div>
					<div class="form-row">
						<div class="form-group wider">
							<label for="email">Email</label>
							<c:choose>
								<c:when test="${not empty userCreationSuccess}">
									<input type="email" name="email" placeholder="Enter the Email"
										value="" required>
								</c:when>
								<c:otherwise>
									<input type="email" name="email" placeholder="Enter the Email"
										value="${empty param.email ? (not empty customerDetails ? customerDetails.email : '') : param.email}"
										required>
								</c:otherwise>
							</c:choose>
						</div>
						<div class="form-group">
							<label for="gender">Gender</label> <select id="gender"
								name="gender" required>
								<option value="male"
									${empty param.gender ? (not empty customerDetails && customerDetails.gender == 'male' ? 'selected' : '') : (param.gender == 'male' ? 'selected' : '')}>Male</option>
								<option value="female"
									${empty param.gender ? (not empty customerDetails && customerDetails.gender == 'female' ? 'selected' : '') : (param.gender == 'female' ? 'selected' : '')}>Female</option>
								<option value="other"
									${empty param.gender ? (not empty customerDetails && customerDetails.gender == 'other' ? 'selected' : '') : (param.gender == 'other' ? 'selected' : '')}>Other</option>
							</select>
						</div>
					</div>
					<c:if test="${not empty invalidEmail}">
						<div class="customer-form-error">
							<p>${invalidEmail}</p>
						</div>
					</c:if>
					<div class="form-row">
						<div class="form-group wider">
							<label for="contactnumber">Contact Number</label>
							<c:choose>
								<c:when test="${not empty userCreationSuccess}">
									<input type="number" name="contactnumber"
										placeholder="Enter the Contact Number" value="" required>
								</c:when>
								<c:otherwise>
									<input type="number" name="contactnumber"
										placeholder="Enter the Contact Number"
										value="${empty param.contactnumber ? (not empty customerDetails ? customerDetails.contactNumber : '') : param.contactnumber}"
										required>
								</c:otherwise>
							</c:choose>
							<c:if test="${not empty invalidMobile}">
								<div class="customer-form-error">
									<p>${invalidMobile}</p>
								</div>
							</c:if>
						</div>
						<div class="form-group">
							<label for="dateOfBirth">Date of Birth</label>
							<c:choose>
								<c:when test="${not empty userCreationSuccess}">
									<input type="date" id="dateOfBirth" name="dateOfBirth" value=""
										required>
								</c:when>
								<c:otherwise>
									<input type="date" id="dateOfBirth" name="dateOfBirth"
										<%-- value="${empty param.dateOfBirth ? (not empty customerDetails ? DOB : '') : DOB}" --%>
										value="${DOB}"
										required>
								</c:otherwise>
							</c:choose>
							<c:if test="${not empty invalidDOB}">
								<div class="customer-form-error">
									<p>${invalidDOB}</p>
								</div>
							</c:if>
						</div>
					</div>
					<%-- <c:if test="${not empty invalidMobile}">
						<div class="customer-form-error">
							<p>${invalidMobile}</p>
						</div>
					</c:if> --%>
					<%-- <c:if test="${not empty invalidDOB}">
						<div class="customer-form-error">
							<p>${invalidDOB}</p>
						</div>
					</c:if> --%>
					<c:if test="${not empty customerDetails}">
						<div class="form-row">
							<div class="form-group wider">
								<label for="userId">User Id</label> <input type="number"
									name="userId"
									value="${not empty customerDetails ? customerDetails.userId : ''}"
									readonly>
							</div>
							<div class="form-group">
								<label for="status">Account Status</label> <select id="gender"
									name="status" required>
									<option value="1"
										${not empty customerDetails && customerDetails.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
									<option value="2"
										${not empty customerDetails && customerDetails.status == 'INACTIVE' ? 'selected' : ''}>InActive</option>
								</select>
							</div>
						</div>
					</c:if>

					<label for="address">Address</label>
					<c:choose>
						<c:when test="${not empty userCreationSuccess}">
							<textarea name="address" placeholder="Enter the Address" rows="2"
								cols="50" required style="text-align: left;"></textarea>
						</c:when>
						<c:otherwise>
							<textarea name="address" placeholder="Enter the Address" rows="2"
								cols="50" required style="text-align: left;">${empty param.address ? (not empty customerDetails ? customerDetails.address : '') : param.address}</textarea>
						</c:otherwise>
					</c:choose>

					<c:if test="${customer}">
						<label for="pannumber">Pan Number</label>
						<input type="text" name="pannumber"
							placeholder="Enter the PAN Number"
							value="<c:choose><c:when test='${not empty userCreationSuccess}'>${''}</c:when><c:otherwise>${empty param.pannumber ? '' : param.pannumber}</c:otherwise></c:choose>"
							required>
						<c:if test="${not empty invalidPAN}">
							<div class="customer-form-error">
								<p>${invalidPAN}</p>
							</div>
						</c:if>
						<label for="aadharnumber">Aadhar Number</label>
						<input type="text" name="aadharnumber"
							placeholder="Enter the Aadhar Number" pattern="\d{12}"
							maxlength="12"
							value="<c:choose><c:when test='${not empty userCreationSuccess}'>${''}</c:when><c:otherwise>${empty param.aadharnumber ? '' : param.aadharnumber}</c:otherwise></c:choose>"
							required>
						<c:if test="${not empty invalidAadhar}">
							<div class="customer-form-error">
								<p>${invalidAadhar}</p>
							</div>
						</c:if>
					</c:if>
					<c:if test="${employee}">
						<label for="branchId">Branch</label>
						<select class="employee-branch" id="branchId" name="branchId"
							required>
							<option value="3007"
								${param.branchId == '3007' ? 'selected' : ''}>Coimbatore</option>
							<option value="3008"
								${param.branchId == '3008' ? 'selected' : ''}>Chennai</option>
							<option value="3009"
								${param.branchId == '3009' ? 'selected' : ''}>Madurai</option>
							<option value="3010"
								${param.branchId == '3010' ? 'selected' : ''}>Trichy</option>
							<option value="3011"
								${param.branchId == '3011' ? 'selected' : ''}>Salem</option>
						</select>

					</c:if>
					<input type="submit"
						value="${not empty customerDetails ? 'Update' : 'Create'}">
				</form>
			</div>
		</div>
	</div>
	<script>
		var today = new Date();
		var minDate = new Date(today.getFullYear() - 150, today.getMonth(),
				today.getDate());
		var maxDate = new Date(today.getFullYear() - 18, today.getMonth(),
				today.getDate());

		document.getElementById('dateOfBirth').setAttribute('min',
				minDate.toISOString().split('T')[0]);
		document.getElementById('dateOfBirth').setAttribute('max',
				maxDate.toISOString().split('T')[0]);
	</script>

</body>
</html>