String mapAuthErrorToMessage(dynamic error) {
  final errorStr = error.toString();

  if (errorStr.contains('employee-access-denied')) {
    return 'Access denied. This account is registered as an employee.';
  } else if (errorStr.contains('not-company')) {
    return 'This account is not registered as a company.';
  } else if (errorStr.contains('user-not-found')) {
    return 'No user found with this email.';
  } else if (errorStr.contains('wrong-password')) {
    return 'Incorrect password.';
  } else if (errorStr.contains('invalid-email')) {
    return 'Invalid email address.';
  }

  return 'An error occurred during login.';
}
