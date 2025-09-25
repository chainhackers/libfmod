#!/bin/bash

# Convenience script to run FMOD 2.03.09 examples with correct library paths

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set FMOD library paths
FMOD_CORE_LIB="$SCRIPT_DIR/../libfmod-gen/fmod/20309/api/core/lib/x86_64"
FMOD_STUDIO_LIB="$SCRIPT_DIR/../libfmod-gen/fmod/20309/api/studio/lib/x86_64"

# Check if libraries exist
if [ ! -d "$FMOD_CORE_LIB" ]; then
    echo -e "${RED}❌ FMOD libraries not found at: $FMOD_CORE_LIB${NC}"
    echo "Please ensure FMOD 2.03.09 SDK is installed in libfmod-gen/fmod/20309/"
    exit 1
fi

# Check if any argument was provided
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}FMOD 2.03.09 Runner${NC}"
    echo ""
    echo "Usage: $0 <example_name> [arguments...]"
    echo ""
    echo "Available examples:"
    echo "  play_sound <audio_file>  - Play an audio file"
    echo "  verify_203               - Verify FMOD 2.03.09 is working"
    echo "  quick_test               - Run comprehensive test"
    echo ""
    echo "Examples:"
    echo "  $0 play_sound /usr/share/sounds/freedesktop/stereo/bell.oga"
    echo "  $0 play_sound ~/Music/song.mp3"
    echo "  $0 verify_203"
    echo ""
    echo "Quick test sounds:"
    for sound in /usr/share/sounds/freedesktop/stereo/*.oga; do
        if [ -f "$sound" ]; then
            echo "  $0 play_sound $sound"
            break
        fi
    done
    exit 0
fi

EXAMPLE_NAME=$1
shift  # Remove first argument, keep the rest for the example

# Check if the example exists
EXAMPLE_PATH="$SCRIPT_DIR/target/debug/examples/$EXAMPLE_NAME"
if [ ! -f "$EXAMPLE_PATH" ]; then
    echo -e "${YELLOW}Example '$EXAMPLE_NAME' not found. Building it...${NC}"

    # Build the example
    cd "$SCRIPT_DIR"
    RUSTFLAGS="-L $FMOD_CORE_LIB -L $FMOD_STUDIO_LIB" cargo build --example "$EXAMPLE_NAME"

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to build example '$EXAMPLE_NAME'${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Built successfully${NC}"
fi

# Set library path and run
echo -e "${GREEN}Running FMOD 2.03.09 example: $EXAMPLE_NAME${NC}"
echo "----------------------------------------"

export LD_LIBRARY_PATH="$FMOD_CORE_LIB:$FMOD_STUDIO_LIB:$LD_LIBRARY_PATH"
"$EXAMPLE_PATH" "$@"

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Example completed successfully${NC}"
else
    echo ""
    echo -e "${RED}❌ Example exited with error${NC}"
fi