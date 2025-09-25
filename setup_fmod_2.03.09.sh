#!/bin/bash

# FMOD 2.03.09 Setup Script
# This script helps set up the FMOD SDK for the libfmod migration

echo "=== FMOD 2.03.09 Setup Script ==="
echo

# Check if we're in the right directory
if [ ! -f "libfmod-gen/Cargo.toml" ]; then
    echo "Error: Please run this script from the libfmod root directory"
    exit 1
fi

# Create fmod directory if it doesn't exist
mkdir -p libfmod-gen/fmod

echo "IMPORTANT: FMOD SDK requires manual download from https://www.fmod.com"
echo "Please follow these steps:"
echo
echo "1. Go to https://www.fmod.com/download"
echo "2. Register/login to your FMOD account"
echo "3. Download 'FMOD Engine' version 2.03.09 for Linux"
echo "   File: fmodstudioapi20309linux.tar.gz"
echo "4. Place the downloaded file in: $(pwd)/libfmod-gen/fmod/"
echo
echo "Press Enter when you've placed the file there..."
read

# Check if the file exists
FMOD_ARCHIVE="libfmod-gen/fmod/fmodstudioapi20309linux.tar.gz"
if [ ! -f "$FMOD_ARCHIVE" ]; then
    echo "Error: File not found: $FMOD_ARCHIVE"
    echo "Please download and place the file there first."
    exit 1
fi

echo "Found FMOD archive. Extracting..."
cd libfmod-gen/fmod
tar -xzf fmodstudioapi20309linux.tar.gz
mv fmodstudioapi20309linux 20309
cd ../..

echo
echo "Verifying installation..."
echo

# Phase 1 TEST 1.1: Verify FMOD Installation
FMOD_SDK_PATH="$(pwd)/libfmod-gen/fmod/20309"
export FMOD_SDK_PATH

echo "📝 TEST 1.1: Verify FMOD Installation"
echo "----------------------------------------"

# Check headers exist
echo -n "Checking core header... "
if [ -f "$FMOD_SDK_PATH/api/core/inc/fmod.h" ]; then
    echo "✓"
else
    echo "✗ Missing"
    exit 1
fi

echo -n "Checking studio header... "
if [ -f "$FMOD_SDK_PATH/api/studio/inc/fmod_studio.h" ]; then
    echo "✓"
else
    echo "✗ Missing"
    exit 1
fi

# Verify version in header
echo -n "Checking FMOD version... "
VERSION=$(grep "#define FMOD_VERSION" "$FMOD_SDK_PATH/api/core/inc/fmod.h" | awk '{print $3}')
if [ "$VERSION" = "0x00020309" ]; then
    echo "✓ Version: $VERSION (2.03.09)"
else
    echo "✗ Unexpected version: $VERSION"
    echo "   Expected: 0x00020309"
    exit 1
fi

# Check libraries
echo -n "Checking libraries... "
if [ -f "$FMOD_SDK_PATH/api/core/lib/x86_64/libfmod.so" ] && \
   [ -f "$FMOD_SDK_PATH/api/core/lib/x86_64/libfmodL.so" ]; then
    echo "✓"
else
    echo "✗ Missing libraries"
    exit 1
fi

# Test library loading
echo -n "Testing library dependencies... "
LDD_OUTPUT=$(ldd "$FMOD_SDK_PATH/api/core/lib/x86_64/libfmod.so" 2>&1)
if echo "$LDD_OUTPUT" | grep -q "not found"; then
    echo "✗ Missing dependencies:"
    echo "$LDD_OUTPUT" | grep "not found"
    exit 1
else
    echo "✓"
fi

echo
echo "========================================="
echo "✅ FMOD 2.03.09 SDK setup complete!"
echo "========================================="
echo
echo "SDK Path: $FMOD_SDK_PATH"
echo
echo "To use in your shell session:"
echo "  export FMOD_SDK_PATH=\"$FMOD_SDK_PATH\""
echo "  export LD_LIBRARY_PATH=\"\$FMOD_SDK_PATH/api/core/lib/x86_64:\$LD_LIBRARY_PATH\""
echo
echo "Next step: Run Phase 2 - Fix libfmod-gen breaking changes"