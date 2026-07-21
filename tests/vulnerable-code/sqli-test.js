// Test Fixture: SQL Injection vulnerability
// Expected: security.md agent should flag this as Critical with PoC

const express = require('express');
const router = express.Router();

router.get('/users', (req, res) => {
  const userId = req.query.id;
  // VULNERABILITY: SQL injection via string concatenation
  const query = "SELECT * FROM users WHERE id = " + userId;
  db.query(query, (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      res.json(results);
    }
  });
});

module.exports = router;
