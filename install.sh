#!/usr/bin/env bash
set -euo pipefail

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; C='\033[0;36m'; N='\033[0m'
REPO="DevAnimecx/DeepSight"
BRANCH="main"
VERSION="v0.2.1"
DIR="${1:-$HOME/.agents/skills/deepsight}"

if [[ "$(uname)" == "Darwin" ]]; then
  DESKTOP_DIR="$HOME/Library/Application Support/Claude/agents/skills/deepsight"
  CLAUDE_CODE_DIR="$HOME/.agents/skills/deepsight"
else
  DESKTOP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Claude/agents/skills/deepsight"
  CLAUDE_CODE_DIR="$HOME/.agents/skills/deepsight"
fi

echo -e "${C}"
cat << "EOF"
╔═══════════════════════════════════════════╗
║    DeepSight v0.2.1 Universal Installer   ║
║   AI-Powered Code Review - Free           ║
║   Supports: Claude, Codex CLI, GPT        ║
╚═══════════════════════════════════════════╝
EOF
echo -e "${N}"

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

if command -v curl &>/dev/null; then
  echo -e "${B}Downloading DeepSight...${N}"
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" -o "$TMPDIR/repo.tar.gz"
elif command -v wget &>/dev/null; then
  echo -e "${B}Downloading DeepSight...${N}"
  wget -q "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" -O "$TMPDIR/repo.tar.gz"
else
  echo -e "${R}Need curl, wget, or git. Install one and try again.${N}"
  exit 1
fi

if [ ! -s "$TMPDIR/repo.tar.gz" ]; then
  echo -e "${Y}Download failed. Trying git clone...${N}"
  if command -v git &>/dev/null; then
    git clone --depth 1 "https://github.com/$REPO.git" "$TMPDIR/repo"
    SRC="$TMPDIR/repo"
  else
    echo -e "${R}Install failed. No git available.${N}"
    exit 1
  fi
else
  echo -e "${B}Extracting...${N}"
  mkdir -p "$TMPDIR/repo"
  tar xzf "$TMPDIR/repo.tar.gz" --strip=1 -C "$TMPDIR/repo"
  SRC="$TMPDIR/repo"
fi

# Detect platforms
echo -e "${B}Detecting AI platforms...${N}"

CLAUDE_DESKTOP=false
CLAUDE_CODE=false
CODEX=false
GPT=false

# Check Claude Desktop
if [[ -d "$DESKTOP_DIR" ]] || [[ -d "$(dirname "$DESKTOP_DIR")" ]]; then
  CLAUDE_DESKTOP=true
fi

# Check Claude Code
if command -v claude &>/dev/null; then
  CLAUDE_CODE=true
fi

# Check for Node.js (for Codex + GPT detections)
if command -v node &>/dev/null; then
  if [[ -f "$SRC/detect-platform.js" ]]; then
    node "$SRC/detect-platform.js"
  fi
fi

# Check Codex CLI config
if [[ -f "$HOME/.config/codex/codex.json" ]]; then
  CODEX=true
fi
if [[ -n "${OPENAI_API_KEY:-}" ]]; then
  GPT=true
fi

# Install destinations
DESTINATIONS=()

if [[ "$CLAUDE_DESKTOP" == "true" ]]; then
  DESTINATIONS+=("$DESKTOP_DIR")
  echo -e "${G}  Found Claude Desktop${N}"
fi

if [[ "$CLAUDE_CODE" == "true" ]]; then
  DESTINATIONS+=("$CLAUDE_CODE_DIR")
  echo -e "${G}  Found Claude Code${N}"
fi

# Always install to user-specified or default dir
DESTINATIONS+=("$DIR")

# Copy files to all destinations
for dest in "${DESTINATIONS[@]}"; do
  echo -e "${B}Installing to: $dest${N}"
  mkdir -p "$dest"
  cp -r "$SRC/"* "$dest/"
  chmod +x "$dest/scripts"/*.sh "$dest/scripts"/*.py 2>/dev/null || true
  echo -e "${G}  OK${N}"
done

echo ""
echo -e "${G}DeepSight $VERSION installed!${N}"
echo ""

echo -e "${C}Platform-Specific Setup:${N}"
echo ""

if [[ "$CLAUDE_DESKTOP" == "true" ]] || [[ "$CLAUDE_CODE" == "true" ]]; then
  echo -e "${B}Claude:${N}"
  echo "  Next review: /review this PR"
  echo "  Audit:       /audit security of src/"
  echo ""
fi

if [[ "$CODEX" == "true" ]]; then
  echo -e "${B}OpenAI Codex CLI:${N}"
  echo "  Read instructions at: _platforms/openai/codex-instructions.md"
  echo ""
fi

if [[ "$GPT" == "true" ]]; then
  echo -e "${B}ChatGPT Custom GPT:${N}"
  echo "  Read instructions at: _platforms/openai/gpt-instructions.md"
  echo ""
fi

echo -e "${Y}Quick Install One-Liners:${N}"
echo "  macOS/Linux: bash <(curl -fsSL https://raw.githubusercontent.com/DevAnimecx/DeepSight/$BRANCH/install.sh)"
echo "  Windows:     iwr -useb https://raw.githubusercontent.com/DevAnimecx/DeepSight/$BRANCH/install.ps1 | iex"
echo ""
echo -e "${C}New to v0.2.1: Universal AI Skill Platform${N}"
echo "  - Works with Claude Desktop, Claude Code, OpenAI Codex CLI, Custom GPT"
echo "  - 10 agents including new Dependency Auditor"
echo "  - Auto-detect your AI platforms with: node detect-platform.js"
echo ""