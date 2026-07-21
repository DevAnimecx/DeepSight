#!/usr/bin/env bash
set -euo pipefail

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; C='\033[0;36m'; N='\033[0m'
REPO="DevAnimecx/DeepSight"
BRANCH="main"
DIR="${1:-$HOME/.agents/skills/deepsight}"

echo -e "${C}"
cat << "EOF"
╔═══════════════════════════════════════════╗
║        DeepSight v0.1.1 Installer         ║
║     AI-Powered Code Review — Free         ║
╚═══════════════════════════════════════════╝
EOF
echo -e "${N}"

mkdir -p "$DIR"

if command -v curl &>/dev/null; then
  echo -e "${B}Downloading DeepSight...${N}"
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar xz --strip=1 -C "$DIR" 2>/dev/null && OK=1
elif command -v wget &>/dev/null; then
  echo -e "${B}Downloading DeepSight...${N}"
  wget -qO- "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar xz --strip=1 -C "$DIR" 2>/dev/null && OK=1
fi

if [ -z "${OK:-}" ]; then
  if command -v git &>/dev/null; then
    echo -e "${Y}Download failed. Cloning instead...${N}"
    rm -rf "$DIR"
    git clone --depth 1 "https://github.com/$REPO.git" "$DIR"
  else
    echo -e "${R}Install failed. Need curl, wget, or git.${N}"
    exit 1
  fi
fi

chmod +x "$DIR/scripts"/*.sh "$DIR/scripts"/*.py 2>/dev/null || true

echo ""
echo -e "${G}✓ DeepSight v0.1.1 installed to: $DIR${N}"
echo ""
echo -e "${C}Quick Start:${N}"
echo "  /review this PR"
echo "  /audit security of src/"
echo ""
echo -e "${Y}One-liner:${N}"
echo "  bash <(curl -fsSL https://raw.githubusercontent.com/DevAnimecx/deepsight/$BRANCH/install.sh)"
echo ""
