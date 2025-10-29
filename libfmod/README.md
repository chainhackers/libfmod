# libfmod Examples

## Quick Start

```bash
# Run examples using the helper script
./run_fmod.sh <example_name> [args]
```

## Available Examples

### Basic Audio
- `play_sound <file>` - Play an audio file
- `verify_203` - Verify FMOD 2.03.09 installation

### Studio Examples
- `harness_demo [demo]` - Non-interactive demos of FMOD Studio features
  - `explosion` - Simple event playback
  - `spatial` - 3D spatial audio with stereo panning
  - `rpm` - Real-time parameter control
  - `footsteps` - Multiple event instances
  - `all` (default) - Run all demos

- `interactive_harness` - Interactive 3D audio testing
  - Keys 1-6: Play/stop events
  - WASD/QE: Move sound source in 3D space
  - Space: Stop all events
  - H: Show help

### Test Suites
- `studio_banks_test` - Test bank loading
- `studio_events_test` - Test event system
- `studio_parameters_test` - Test parameter control
- `quick_test` - Comprehensive test suite

## Requirements

FMOD libraries must be installed. The script expects them at:
- Core: `../libfmod-gen/fmod/20309/api/core/lib/x86_64/`
- Studio: `../libfmod-gen/fmod/20309/api/studio/lib/x86_64/`

## Testing

For running tests, create `.cargo/config.toml` with library paths:

```toml
[build]
rustflags = [
    "-L", "../fmodstudioapi20310linux/api/core/lib/x86_64",
    "-L", "../fmodstudioapi20310linux/api/studio/lib/x86_64",
]
```

Then run tests:

```bash
cargo test --test version_test --test init_test --test system_test -- --test-threads=1
```

## Manual Execution

```bash
# Set library paths
export LD_LIBRARY_PATH="../libfmod-gen/fmod/20309/api/core/lib/x86_64:../libfmod-gen/fmod/20309/api/studio/lib/x86_64:$LD_LIBRARY_PATH"

# Build and run
cargo build --example harness_demo
./target/debug/examples/harness_demo
```