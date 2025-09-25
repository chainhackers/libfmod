# How to Run FMOD 2.03.09 Examples

## Quick Start (Copy & Paste)

From the `libfmod` directory, run:

```bash
# Set library path and run
export LD_LIBRARY_PATH="../libfmod-gen/fmod/20309/api/core/lib/x86_64:../libfmod-gen/fmod/20309/api/studio/lib/x86_64:$LD_LIBRARY_PATH"
./target/debug/examples/play_sound /usr/share/sounds/freedesktop/stereo/bell.oga
```

## The Problem

The error `libfmod.so.14: cannot open shared object file` happens because Linux can't find the FMOD 2.03.09 libraries. They're in `libfmod-gen/fmod/20309/` but the system doesn't know that.

## Solution 1: Set LD_LIBRARY_PATH (Temporary)

Every time you open a new terminal, run:

```bash
cd ~/devenv/gamedev/dg/src/libfmod/libfmod
export LD_LIBRARY_PATH="../libfmod-gen/fmod/20309/api/core/lib/x86_64:../libfmod-gen/fmod/20309/api/studio/lib/x86_64:$LD_LIBRARY_PATH"
```

Then you can run examples:
```bash
./target/debug/examples/play_sound /usr/share/sounds/freedesktop/stereo/bell.oga
./target/debug/examples/verify_203
```

## Solution 2: Use the Run Script (Easier!)

Use the provided script that sets everything up:

```bash
cd ~/devenv/gamedev/dg/src/libfmod/libfmod
./run_fmod.sh play_sound /usr/share/sounds/freedesktop/stereo/bell.oga
./run_fmod.sh verify_203
```

## Solution 3: Install Libraries (Permanent)

To avoid setting paths every time:

```bash
# Copy to user library directory (no sudo needed)
mkdir -p ~/lib
cp ../libfmod-gen/fmod/20309/api/core/lib/x86_64/*.so* ~/lib/
cp ../libfmod-gen/fmod/20309/api/studio/lib/x86_64/*.so* ~/lib/

# Add to .bashrc or .zshrc
echo 'export LD_LIBRARY_PATH="$HOME/lib:$LD_LIBRARY_PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Building Examples

When building, you need to tell Rust where the libraries are:

```bash
cd ~/devenv/gamedev/dg/src/libfmod/libfmod
RUSTFLAGS="-L $(pwd)/../libfmod-gen/fmod/20309/api/core/lib/x86_64 -L $(pwd)/../libfmod-gen/fmod/20309/api/studio/lib/x86_64" cargo build --example play_sound
```

## Available Examples

1. **play_sound** - Play any audio file
   ```bash
   ./run_fmod.sh play_sound ~/Music/song.mp3
   ```

2. **verify_203** - Quick version check
   ```bash
   ./run_fmod.sh verify_203
   ```

3. **quick_test** - Comprehensive test
   ```bash
   ./run_fmod.sh quick_test
   ```

## Common Audio Files to Test

```bash
# System sounds (usually available)
/usr/share/sounds/freedesktop/stereo/bell.oga
/usr/share/sounds/freedesktop/stereo/complete.oga
/usr/share/sounds/freedesktop/stereo/message.oga

# Your own files
~/Music/*.mp3
~/Music/*.wav
~/Downloads/*.ogg
```

## Troubleshooting

If you still get library errors:

1. **Check libraries exist:**
   ```bash
   ls ../libfmod-gen/fmod/20309/api/core/lib/x86_64/
   ```
   Should show: libfmod.so, libfmod.so.14, libfmod.so.14.9

2. **Check current LD_LIBRARY_PATH:**
   ```bash
   echo $LD_LIBRARY_PATH
   ```

3. **Check what libraries the program needs:**
   ```bash
   ldd ./target/debug/examples/play_sound
   ```

4. **Full path approach:**
   ```bash
   LD_LIBRARY_PATH=/full/path/to/fmod/libs:$LD_LIBRARY_PATH ./target/debug/examples/play_sound
   ```