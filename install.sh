#!/usr/bin/env bash
# DeepSight — Quick Download Installer
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/DevAnimecx/deepsight/main/install.sh)
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
REPO="DevAnimecx/deepsight"
BRANCH="main"
DEFAULT_DIR="$HOME/.agents/skills/deepsight"
INSTALL_DIR="${1:-$DEFAULT_DIR}"

echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════╗
║         DeepSight v0.1.1 Installer           ║
║     Agentic Code Intelligence Platform      ║
╚══════════════════════════════════════════════╝
EOF
echo -e "${NC}"

mkdir -p "$INSTALL_DIR" && cd "$INSTALL_DIR"

if command -v curl &>/dev/null; then
  echo -e "${BLUE}⏳ Downloading DeepSight...${NC}"
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar xz --strip=1 -C "$INSTALL_DIR" 2>/dev/null || {
    echo -e "${YELLOW}⚠  Download failed. Trying git clone as fallback...${NC}"
    cd .. && rm -rf "$INSTALL_DIR"
    git clone --depth 1 "https://github.com/$REPO.git" "$INSTALL_DIR" 2>/dev/null || {
      echo -e "${RED}✖ Install failed. Ensure curl or git is available.${NC}"; exit 1
    }
  }
elif command -v wget &>/dev/null; then
  echo -e "${BLUE}⏳ Downloading DeepSight...${NC}"
  wget -qO- "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar xz --strip=1 -C "$INSTALL_DIR" 2>/dev/null || {
    echo -e "${YELLOW}⚠  Download failed. Trying git clone as fallback...${NC}"
    cd .. && rm -rf "$INSTALL_DIR"
    git clone --depth 1 "https://github.com/$REPO.git" "$INSTALL_DIR" 2>/dev/null || {
      echo -e "${RED}✖ Install failed. Ensure wget or git is available.${NC}"; exit 1
    }
  }
elif command -v git &>/dev/null; then
  echo -e "${BLUE}⏳ Cloning DeepSight...${NC}"
  git clone --depth 1 "https://github.com/$REPO.git" "$INSTALL_DIR"
else
  echo -e "${RED}✖ Need curl, wget, or git. Install one and retry.${NC}"; exit 1
fi

chmod +x "$INSTALL_DIR/scripts"/*.sh "$INSTALL_DIR/scripts"/*.py 2>/dev/null || true

echo ""
echo -e "${GREEN}✓ DeepSight v0.1.1 installed to: $INSTALL_DIR${NC}"
echo ""
echo -e "${CYAN}Quick Start:${NC}"
echo "  /review this PR"
echo "  /audit security of src/"
echo "  bash $INSTALL_DIR/scripts/run-semgrep.sh path/to/code"
echo ""
echo -e "${YELLOW}💡 One-liner install:${NC}"
echo "  bash <(curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/install.sh)"
echo ""
