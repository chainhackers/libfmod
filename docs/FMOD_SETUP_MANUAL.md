# FMOD Setup Manual for libfmod

Quick guide for setting up FMOD libraries to test libfmod on Linux and macOS.

## Step 1: Download FMOD SDK

1. Go to https://www.fmod.com/download
2. Create an account and sign in
3. Download FMOD Engine 2.03.09 for your platform:
   - Linux: `fmodstudioapi20309linux.tar.gz`
   - macOS: `fmodstudioapi20309mac-installer.dmg`

## Step 2: Extract/Install FMOD

### Linux

```bash
cd libfmod/libfmod-gen
mkdir -p fmod/20309
tar -xzf ~/Downloads/fmodstudioapi20309linux.tar.gz -C fmod/20309 --strip-components=1
```

### macOS

```bash
# Mount the DMG and extract the SDK
hdiutil attach ~/Downloads/fmodstudioapi20309mac-installer.dmg
cd libfmod/libfmod-gen
mkdir -p fmod/20309

# Copy the SDK files (adjust path if needed)
cp -r /Volumes/FMOD\ Programmers\ API/FMOD\ Programmers\ API/* fmod/20309/

# Unmount
hdiutil detach /Volumes/FMOD\ Programmers\ API/
```

## Step 3: Run Examples

### Linux

```bash
cd libfmod/libfmod

# Test FMOD version
./run_fmod.sh verify_203

# Play a sound
./run_fmod.sh play_sound /usr/share/sounds/freedesktop/stereo/bell.oga

# Test Studio features
./run_fmod.sh studio_banks_test
```

### macOS

```bash
cd libfmod/libfmod

# Build with library paths
RUSTFLAGS="-L ../libfmod-gen/fmod/20309/api/core/lib -L ../libfmod-gen/fmod/20309/api/studio/lib" \
cargo build --example verify_203

# Run with library path
DYLD_LIBRARY_PATH="../libfmod-gen/fmod/20309/api/core/lib:../libfmod-gen/fmod/20309/api/studio/lib" \
./target/debug/examples/verify_203

# Play a sound (use macOS system sound)
DYLD_LIBRARY_PATH="../libfmod-gen/fmod/20309/api/core/lib:../libfmod-gen/fmod/20309/api/studio/lib" \
./target/debug/examples/play_sound /System/Library/Sounds/Glass.aiff
```

## Directory Structure After Setup

```
libfmod-gen/fmod/20309/
├── api/
│   ├── core/
│   │   ├── inc/        # Headers
│   │   └── lib/        # Libraries
│   │       ├── x86_64/ # Linux
│   │       └── *.dylib # macOS
│   └── studio/
│       └── examples/
│           └── media/  # Sample banks
└── doc/
```

## Troubleshooting

### Linux: "libraries not found"
```bash
export LD_LIBRARY_PATH="../libfmod-gen/fmod/20309/api/core/lib/x86_64:../libfmod-gen/fmod/20309/api/studio/lib/x86_64:$LD_LIBRARY_PATH"
```

### macOS: "dylib not found"
```bash
export DYLD_LIBRARY_PATH="../libfmod-gen/fmod/20309/api/core/lib:../libfmod-gen/fmod/20309/api/studio/lib:$DYLD_LIBRARY_PATH"
```

### macOS: Security warnings
If macOS blocks the libraries:
```bash
# Remove quarantine attribute
xattr -d com.apple.quarantine libfmod-gen/fmod/20309/api/core/lib/*.dylib
xattr -d com.apple.quarantine libfmod-gen/fmod/20309/api/studio/lib/*.dylib
```