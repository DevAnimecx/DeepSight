# OWASP Top 10 (2021) — DeepSight Reference Rules

## A01: Broken Access Control
- Verify every route/endpoint checks user permissions
- IDOR: Ensure resource IDs are scoped to the authenticated user
- CORS: Validate allowed origins, don't use `*` with credentials
- Directory listing: Ensure static file serving has path traversal protection

## A02: Cryptographic Failures
- No sensitive data in URLs (query params logged in access logs)
- TLS 1.2+ only, no TLS 1.0/1.1
- Passwords hashed with bcrypt/argon2, never MD5/SHA1
- Secrets in env vars or vault, never in code

## A03: Injection
- Parameterized queries for all SQL (never string concat)
- Input validation at the boundary, not deep in business logic
- Output encoding at the rendering layer (context-aware)
- No `eval()`, `Function()`, `exec()` on user input

## A04: Insecure Design
- Rate limiting on auth endpoints
- Account lockout after failed attempts
- Separate admin/user token formats/lifespans
- Defense in depth: don't rely on client-side validation

## A05: Security Misconfiguration
- No default credentials
- Stack traces hidden in production
- Security headers: CSP, HSTS, X-Frame-Options
- Unnecessary features/components disabled

## A06: Vulnerable Components
- Dependency scanning in CI (npm audit, pip-audit, etc.)
- Pinned dependency versions (not floating ranges)
- Regular update cadence (at least monthly)

## A07: Auth Failures
- MFA available for sensitive operations
- Session tokens rotated after login
- Password reset tokens single-use and time-limited
- No sensitive operations via GET requests

## A08: Data Integrity Failures
- Signed JWTs (HS256/RS256), never `alg: none`
- CI/CD pipeline integrity verification
- No unsigned/unverified deserialization

## A09: Logging & Monitoring Failures
- Auth events logged (login, logout, failed attempts)
- Sensitive data NOT logged (passwords, tokens, PII)
- Log injection prevention (sanitize log input)

## A10: SSRF
- URL allowlists for outbound requests
- Internal IPs blocked (10.x, 172.16.x, 192.168.x, 169.254.x)
- Redirect validation on client-side requests


