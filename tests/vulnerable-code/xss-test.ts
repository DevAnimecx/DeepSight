// Test Fixture: XSS vulnerability
// Expected: security.md agent should flag this as Critical with PoC

import express from 'express';
const router = express.Router();

router.post('/comment', (req, res) => {
  const { user, text } = req.body;
  // VULNERABILITY: No output encoding, reflected XSS
  res.send(`<div class="comment">
    <strong>${user}</strong>
    <p>${text}</p>
  </div>`);
});

export default router;
