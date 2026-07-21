// Test Fixture: Magic Numbers (Code Smell)
// Expected: smell.md agent should flag as Medium

function calculateDiscount(price, userType) {
  // VULNERABILITY: Magic numbers without named constants
  if (userType === 'premium') {
    return price * 0.15; // What does 0.15 mean?
  } else if (userType === 'vip') {
    return price * 0.25; // What does 0.25 mean?
  }
  
  // More magic numbers
  if (price > 100) {
    return price * 0.05; // And 0.05?
  }
  
  // Timeout magic number
  setTimeout(() => {
    console.log('Processing complete');
  }, 3600000); // What is 3600000 ms?
  
  return 0;
}

module.exports = { calculateDiscount };
