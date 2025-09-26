#!/usr/bin/env bash

# macOS runner for FMOD 2.03.09 examples
# Usage:
#   ./run_fmod_mac.sh <example_name> [args...]
# Examples:
#   ./run_fmod_mac.sh verify_203
#   ./run_fmod_mac.sh play_sound /System/Library/Sounds/Ping.aiff
#   ./run_fmod_mac.sh quick_test

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR"
REPO_ROOT="$( cd "$PROJECT_DIR/.." && pwd )"

# Resolve FMOD library locations
CORE_SYMLINK="$REPO_ROOT/.fmod203/core"
STUDIO_SYMLINK="$REPO_ROOT/.fmod203/studio"
CORE_FROM_SDK="$REPO_ROOT/FMOD Programmers API/api/core/lib"
STUDIO_FROM_SDK="$REPO_ROOT/FMOD Programmers API/api/studio/lib"

if [[ -d "$CORE_SYMLINK" && -d "$STUDIO_SYMLINK" ]]; then
  FMOD_CORE_LIB="$CORE_SYMLINK"
  FMOD_STUDIO_LIB="$STUDIO_SYMLINK"
elif [[ -d "$CORE_FROM_SDK" && -d "$STUDIO_FROM_SDK" ]]; then
  FMOD_CORE_LIB="$CORE_FROM_SDK"
  FMOD_STUDIO_LIB="$STUDIO_FROM_SDK"
else
  echo -e "${RED}❌ FMOD libraries not found.${NC}"
  echo "Expected either:"
  echo "  $CORE_SYMLINK and $STUDIO_SYMLINK"
  echo "or"
  echo "  $CORE_FROM_SDK and $STUDIO_FROM_SDK"
  echo
  echo "Tip: create convenient links (already done earlier):"
  echo "  ln -sfn \"$CORE_FROM_SDK\" \"$CORE_SYMLINK\""
  echo "  ln -sfn \"$STUDIO_FROM_SDK\" \"$STUDIO_SYMLINK\""
  exit 1
fi

# Basic validation of dylibs
if [[ ! -f "$FMOD_CORE_LIB/libfmod.dylib" ]] || [[ ! -f "$FMOD_STUDIO_LIB/libfmodstudio.dylib" ]]; then
  echo -e "${RED}❌ Missing libfmod.dylib or libfmodstudio.dylib${NC}"
  echo "Core:   $FMOD_CORE_LIB"
  echo "Studio: $FMOD_STUDIO_LIB"
  exit 1
fi

# Usage
if [[ $# -eq 0 ]]; then
  echo -e "${YELLOW}FMOD 2.03.09 Runner (macOS)${NC}"
  echo
  echo "Usage: $0 <example_name> [arguments...]"
  echo
  echo "Available examples:"
  echo "  play_sound <audio_file>  - Play an audio file"
  echo "  verify_203               - Verify FMOD 2.03.09 is working"
  echo "  quick_test               - Run comprehensive test"
  echo
  echo "Examples:"
  echo "  $0 play_sound /System/Library/Sounds/Ping.aiff"
  echo "  $0 verify_203"
  echo "  $0 quick_test"
  exit 0
fi

EXAMPLE_NAME="$1"
shift || true
EXAMPLE_PATH="$PROJECT_DIR/target/debug/examples/$EXAMPLE_NAME"

# Build example if needed
if [[ ! -f "$EXAMPLE_PATH" ]]; then
  echo -e "${YELLOW}Building example '$EXAMPLE_NAME'...${NC}"
  ( cd "$PROJECT_DIR" && RUSTFLAGS="-L $FMOD_CORE_LIB -L $FMOD_STUDIO_LIB" cargo build --example "$EXAMPLE_NAME" )
  echo -e "${GREEN}✅ Built successfully${NC}"
fi

# Run with correct dynamic library path
export DYLD_LIBRARY_PATH="$FMOD_CORE_LIB:$FMOD_STUDIO_LIB:${DYLD_LIBRARY_PATH:-}"

echo -e "${GREEN}Running example: $EXAMPLE_NAME${NC}"
echo "----------------------------------------"
# Ensure relative paths inside examples resolve from the project dir
(
  cd "$PROJECT_DIR" && "$EXAMPLE_PATH" "$@"
)
EXIT_CODE=$?

echo
if [[ $EXIT_CODE -eq 0 ]]; then
  echo -e "${GREEN}✅ Example completed successfully${NC}"
else
  echo -e "${RED}❌ Example exited with error ($EXIT_CODE)${NC}"
  # Helpful hint for quarantine issues
  if command -v xattr >/dev/null 2>&1; then
    if xattr -p com.apple.quarantine "$FMOD_CORE_LIB/libfmod.dylib" >/dev/null 2>&1; then
      echo -e "${YELLOW}Hint:${NC} The FMOD SDK may be quarantined by macOS Gatekeeper. You can clear it with:"
      echo "  xattr -dr com.apple.quarantine \"$REPO_ROOT/FMOD Programmers API\""
    fi
  fi
fi

exit $EXIT_CODE
