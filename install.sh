#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/niegusss/claude.git"
TARGET="$HOME/.claude"

# Items to install. Anything not in this list is ignored.
INSTALL_ITEMS=(
  "skills"
  "agents"
  "docs"
  "MANIFEST.md"
  "SKILLS_AND_AGENTS.md"
  "SECURITY.md"
)

# --- Colors (with fallback) ---
if command -v tput &>/dev/null && [ -t 1 ]; then
  BOLD=$(tput bold 2>/dev/null || true)
  GREEN=$(tput setaf 2 2>/dev/null || true)
  RED=$(tput setaf 1 2>/dev/null || true)
  YELLOW=$(tput setaf 3 2>/dev/null || true)
  RESET=$(tput sgr0 2>/dev/null || true)
else
  BOLD="" GREEN="" RED="" YELLOW="" RESET=""
fi

# --- Pre-flight checks ---
if ! command -v git &>/dev/null; then
  echo "${RED}Error: git is not installed or not in PATH.${RESET}"
  echo "Install git: https://git-scm.com/downloads"
  exit 1
fi

# --- Temp dir + cleanup trap ---
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# --- Clone (shallow, single branch) ---
echo "${BOLD}Fetching latest skills, agents, and docs...${RESET}"
if ! git clone --depth 1 --single-branch "$REPO" "$TEMP_DIR"; then
  echo ""
  echo "${RED}Error: Failed to clone $REPO${RESET}"
  echo ""
  echo "This is a private repository. Make sure you are authenticated:"
  echo "  - GitHub CLI:  gh auth login"
  echo "  - SSH key:     https://docs.github.com/en/authentication"
  echo "  - Credential:  git credential-manager"
  exit 1
fi

# --- Ensure target exists ---
mkdir -p "$TARGET"

# --- Copy whitelisted items only ---
copied=()
missing=()

for name in "${INSTALL_ITEMS[@]}"; do
  src="$TEMP_DIR/$name"
  if [ -e "$src" ]; then
    cp -a "$src" "$TARGET/"
    copied+=("$name")
  else
    missing+=("$name")
  fi
done

# --- Summary ---
echo ""
echo "${GREEN}${BOLD}Done${RESET} — ${TARGET}/ updated."

if [ ${#copied[@]} -gt 0 ]; then
  echo ""
  echo "Installed:"
  for name in "${copied[@]}"; do
    if [ -d "$TARGET/$name" ]; then
      count=$(find "$TARGET/$name" -type f | wc -l | tr -d ' ')
      echo "  $name/ ($count files)"
    else
      echo "  $name"
    fi
  done
fi

if [ ${#missing[@]} -gt 0 ]; then
  echo ""
  echo "${YELLOW}Skipped (not in source):${RESET}"
  for name in "${missing[@]}"; do
    echo "  $name"
  done
fi

echo ""
echo "${BOLD}Next:${RESET} restart Claude Code so the new skills load."
echo "Usage (mac/linux):  curl -fsSL https://raw.githubusercontent.com/niegusss/claude/main/install.sh | bash"
echo "Usage (Windows):    irm https://raw.githubusercontent.com/niegusss/claude/main/install.ps1 | iex"
