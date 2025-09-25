# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

libfmod is a Rust bindings library for FMOD Engine audio middleware. The project consists of two main components:
- **libfmod-gen**: A code generator that parses FMOD C headers and generates Rust FFI bindings
- **libfmod**: The main library providing safe Rust wrappers around FMOD's C API

**Current Focus**: Migrating from FMOD 2.02.22 to 2.03.09 (see docs/ folder for detailed plans)

## Build Commands

### Building the main library
```bash
cd libfmod
cargo build
cargo build --features logging  # Build with FMOD logging libraries
```

### Running the generator
```bash
cd libfmod-gen
cargo run -- [fmod_sdk_path] [output_dir]
# Default: cargo run -- ./fmod/20222 ../libfmod
```

### Testing
```bash
# Run library tests (requires FMOD libraries installed)
cd libfmod
export LD_LIBRARY_PATH=$FMOD_SDK_PATH/api/core/lib/x86_64:$LD_LIBRARY_PATH
cargo test -- --test-threads=1

# Run specific test
cargo test test_name -- --nocapture

# Run manual tests
cargo test --test manual -- --ignored
```

### Code formatting and linting
```bash
cargo fmt
cargo clippy
```

## Architecture

### Code Generation Pipeline
1. **Parser** (libfmod-gen/src/parsers/): Uses pest grammar to parse FMOD C headers
   - Extracts structures, functions, enums, callbacks, constants
   - Parses documentation from HTML files for parameter modifiers

2. **Patching** (libfmod-gen/src/patching/): Applies manual corrections to parsed data
   - Fixes FFI type mappings
   - Handles special cases and FMOD-specific patterns

3. **Generator** (libfmod-gen/src/generators/): Creates Rust code from parsed API
   - `ffi.rs`: Raw FFI bindings
   - `lib.rs`: Safe Rust wrappers
   - `flags.rs`: Bitflags for FMOD flags
   - `errors.rs`: Error type definitions

### Key Components

**libfmod-gen/src/main.rs**: Entry point that orchestrates the generation process
- Reads FMOD headers from SDK
- Invokes parsers for each header file
- Patches the combined API model
- Generates Rust files

**libfmod/build.rs**: Build script that links appropriate FMOD libraries based on platform and features

## Important Implementation Details

- The library uses dynamic linking only (FMOD doesn't support static linking)
- String ownership is managed by moving String fields to C when passing structures
- The generator automatically runs `cargo fmt` after generating code
- Test files require FMOD development libraries to be installed as per README

## FMOD 2.03.09 Migration (Current Focus)

### Critical Breaking Changes
- **No ABI compatibility** between FMOD 2.02 and 2.03
- `System::getVersion` signature changed (adds buildnumber parameter)
- `FMOD_ADVANCEDSETTINGS.commandQueueSize` field removed
- `FMOD_STUDIO_ADVANCEDSETTINGS.encryptionkey` field added
- `FMOD_OUTPUT_DESCRIPTION.polling` renamed to `method`

### Migration Phases (see docs/fmod-update-plan.md)
1. **Setup**: Download and verify FMOD 2.03.09 SDK
2. **Generator Updates**: Fix breaking changes in libfmod-gen
3. **Core libfmod**: Update system, studio, and event APIs
4. **Test Harness**: Interactive testing tool
5. **bevy_fmod**: Minimal Bevy plugin implementation
6. **Validation**: Complete test suite

### Test-Driven Approach
Each migration step has specific tests to verify correctness before proceeding. Run tests after any changes:
```bash
# After libfmod-gen changes
cd libfmod-gen && cargo test

# After libfmod changes
cd libfmod && cargo test -- --test-threads=1

# Interactive testing
cargo run --example test_harness
```

## Quick Reference

### Common Issues
- **Dangling pointer warnings**: Temporary Vec issues in FFI code (needs fixing)
- **Missing FMOD libraries**: Follow README installation instructions
- **Test failures**: Ensure FMOD libraries are in LD_LIBRARY_PATH

### File Locations
- Generated FFI: `libfmod/src/ffi.rs`
- Safe wrappers: `libfmod/src/lib.rs`
- Parser grammar: `libfmod-gen/src/parsers/*.rs`
- Patching rules: `libfmod-gen/src/patching/`
- Migration docs: `docs/fmod-*.md`