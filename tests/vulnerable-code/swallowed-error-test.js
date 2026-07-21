// Test Fixture: Swallowed Exception (Reliability Issue)
// Expected: error.md agent should flag as High

async function fetchUserData(userId) {
  try {
    const response = await fetch(`/api/users/${userId}`);
    const data = await response.json();
    return data;
  } catch (error) {
    // VULNERABILITY: Swallowed exception, no logging or handling
    // Application silently fails, user gets no feedback
  }
}

// Another example with empty catch
function processPayment(amount) {
  try {
    chargeCard(amount);
  } catch (e) {
    // Empty catch block
  }
}

module.exports = { fetchUserData, processPayment };
