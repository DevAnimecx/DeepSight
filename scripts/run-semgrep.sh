#!/usr/bin/env bash
# Layer 1: Deterministic Guardrails
# Runs Semgrep + regex checks against changed files.
# Zero LLM tokens. Outputs JSON for Layer 2 consumption.

set -euo pipefail

# --- Config ---
SEMGREP_CONFIGS="${SEMGREP_CONFIGS:-p/security-audit p/owasp-top-ten}"
TARGET_DIR="${1:-.}"
MAX_FINDINGS="${MAX_FINDINGS:-50}"

# --- Colors ---
if [ -t 1 ]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; NC=''
fi

# --- Regex checks (always run, no deps needed) ---
run_regex_checks() {
    local target="$1"
    local findings="[]"

    # eval() calls
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        file=$(echo "$line" | cut -d: -f1)
        lineno=$(echo "$line" | cut -d: -f2)
        findings=$(echo "$findings" | jq --arg f "$file" --argjson l "$lineno" --arg r "eval() usage — arbitrary code execution" '. + [{"file":$f,"line":$l,"rule":"eval","severity":"critical","message":$r}]')
    done < <(grep -rn --include="*.js" --include="*.ts" --include="*.py" --include="*.php" --include="*.rb" --include="*.go" -E '\beval\s*\(' "$target" 2>/dev/null | grep -vE 'node_modules|vendor|\.git|test/|__tests__|\.spec\.' | head -20 || true)

    # Hardcoded secrets
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        file=$(echo "$line" | cut -d: -f1)
        lineno=$(echo "$line" | cut -d: -f2)
        findings=$(echo "$findings" | jq --arg f "$file" --argjson l "$lineno" --arg r "Hardcoded secret/credential in source" '. + [{"file":$f,"line":$l,"rule":"hardcoded-secret","severity":"critical","message":$r}]')
    done < <(grep -rn --include="*.js" --include="*.ts" --include="*.py" --include="*.env*" --include="*.json" -E '(api[_-]?key|apikey|secret|password|token|credential)\s*[:=]\s*["\x27][^"\x27]{8,}["\x27]' "$target" 2>/dev/null | grep -vE 'node_modules|vendor|\.git|example|test/|__tests__|\.spec\.|placeholder|dummy|sample' | head -20 || true)

    # SQL injection (string concat in queries)
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        file=$(echo "$line" | cut -d: -f1)
        lineno=$(echo "$line" | cut -d: -f2)
        findings=$(echo "$findings" | jq --arg f "$file" --argjson l "$lineno" --arg r "Potential SQL injection via string concatenation" '. + [{"file":$f,"line":$l,"rule":"sqli-concat","severity":"high","message":$r}]')
    done < <(grep -rn --include="*.js" --include="*.ts" --include="*.py" --include="*.php" -E '(SELECT|INSERT|UPDATE|DELETE|execute|query)\s*\(.*\+' "$target" 2>/dev/null | grep -vE 'node_modules|vendor|\.git|test/|__tests__|\.spec\.' | head -20 || true)

    echo "$findings"
}

# --- Semgrep (if available) ---
run_semgrep() {
    if ! command -v semgrep &>/dev/null; then
        echo '{"results":[],"errors":["semgrep not installed"]}'
        return
    fi

    local output
    output=$(semgrep --json --config="$SEMGREP_CONFIGS" "$TARGET_DIR" 2>&1) || true

    # semgrep may emit warnings to stderr mixed into stdout;
    # extract just the JSON results array
    echo "$output" | jq -r 'if type=="array" then . else .results // [] end' 2>/dev/null || echo '{"results":[],"errors":["semgrep parse error"]}'
}

# --- Main ---
echo "=== DeepSight Layer 1: Deterministic Guardrails ==="
echo "Target: $TARGET_DIR"
echo ""

# Regex findings
regex_json=$(run_regex_checks "$TARGET_DIR")
regex_count=$(echo "$regex_json" | jq 'length' 2>/dev/null || echo 0)
echo "Regex findings: $regex_count"

# Semgrep findings
semgrep_json=$(run_semgrep "$TARGET_DIR")
semgrep_count=$(echo "$semgrep_json" | jq '.results // [] | length' 2>/dev/null || echo 0)
echo "Semgrep findings: $semgrep_count"

# Combine
total=$(echo "$regex_count + $semgrep_count" | bc 2>/dev/null || python3 -c "print($regex_count + $semgrep_count)")
echo ""
echo "Total findings: $total"

if [ "$total" -gt "$MAX_FINDINGS" ]; then
    echo -e "${RED}FAIL — $total findings exceed threshold ($MAX_FINDINGS)${NC}"
    echo '{"status":"fail","findings":'$total',"threshold":'$MAX_FINDINGS'}'
    exit 1
elif [ "$total" -gt 0 ]; then
    echo -e "${YELLOW}PASS WITH FINDINGS — $total issues detected${NC}"
    echo '{"status":"pass_findings","findings":'$total',"regex":'$regex_json',"semgrep":'$semgrep_json'}'
    exit 0
else
    echo -e "${GREEN}PASS — No critical issues detected${NC}"
    echo '{"status":"pass","findings":0}'
    exit 0
fi


