#!/usr/bin/env bash
set -euo pipefail

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; C='\033[0;36m'; N='\033[0m'
REPO="DevAnimecx/DeepSight"
BRANCH="main"
VERSION="v0.1.1"
DIR="${1:-$HOME/.agents/skills/deepsight}"

if [[ "$(uname)" == "Darwin" ]]; then
  DESKTOP_DIR="$HOME/Library/Application Support/Claude/agents/skills/deepsight"
else
  DESKTOP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Claude/agents/skills/deepsight"
fi

echo -e "${C}"
cat << "EOF"
╔═══════════════════════════════════════════╗
║        DeepSight v0.1.1 Installer         ║
║     AI-Powered Code Review — Free         ║
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
    mkdir -p "$DIR" "$DESKTOP_DIR"
    cp -r "$TMPDIR/repo/"* "$DIR/"
    cp -r "$TMPDIR/repo/"* "$DESKTOP_DIR/" 2>/dev/null || true
    rm -rf "$TMPDIR/repo"
  else
    echo -e "${R}Install failed. No git available.${N}"
    exit 1
  fi
else
  echo -e "${B}Extracting...${N}"
  mkdir -p "$DIR" "$DESKTOP_DIR"
  tar xzf "$TMPDIR/repo.tar.gz" --strip=1 -C "$DIR"
  cp -r "$DIR/"* "$DESKTOP_DIR/" 2>/dev/null || true
fi

chmod +x "$DIR/scripts"/*.sh "$DIR/scripts"/*.py 2>/dev/null || true
chmod +x "$DESKTOP_DIR/scripts"/*.sh "$DESKTOP_DIR/scripts"/*.py 2>/dev/null || true

echo ""
echo -e "${G}✓ DeepSight $VERSION installed${N}"
echo -e "${G}  → $DIR${N}"
echo -e "${G}  → $DESKTOP_DIR${N}"
echo ""
echo -e "${C}Quick Start:${N}"
echo "  /review this PR"
echo "  /audit security of src/"
echo ""
echo -e "${Y}One-liner:${N}"
echo "  bash <(curl -fsSL https://raw.githubusercontent.com/DevAnimecx/DeepSight/$BRANCH/install.sh)"
echo ""
