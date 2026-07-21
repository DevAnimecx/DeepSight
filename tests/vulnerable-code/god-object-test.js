# Test Fixture: God Object (Architecture Violation)
# Expected: architecture.md agent should flag as High (>500 LOC, >20 methods)

class UserService {
  // Authentication methods (5)
  login(username, password) { }
  logout(token) { }
  resetPassword(email) { }
  changePassword(oldPass, newPass) { }
  validateToken(token) { }

  // User CRUD methods (6)
  createUser(data) { }
  getUser(id) { }
  updateUser(id, data) { }
  deleteUser(id) { }
  listUsers(filters) { }
  searchUsers(query) { }

  // Email methods (5)
  sendWelcomeEmail(user) { }
  sendPasswordReset(user) { }
  sendNotification(user, msg) { }
  validateEmail(email) { }
  parseEmailTemplate(template, data) { }

  // Payment methods (4)
  processPayment(user, amount) { }
  refundPayment(transactionId) { }
  getPaymentHistory(user) { }
  validateCard(cardInfo) { }

  // Analytics methods (3)
  trackLogin(user) { }
  trackActivity(user, action) { }
  generateReport(user) { }

  // ... more methods to exceed 500 LOC and 20 methods
  // This class violates SRP and should be split into:
  // - AuthService
  // - UserService (CRUD only)
  // - EmailService
  // - PaymentService
  // - AnalyticsService
}

module.exports = UserService;
