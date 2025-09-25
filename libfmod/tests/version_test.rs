// Phase 3.2: Test Version API for FMOD 2.03.09

use libfmod::{System, Error};

#[test]
fn test_get_version_new_api() {
    let system = System::create().unwrap();
    let result = system.get_version();

    assert!(result.is_ok(), "get_version failed: {:?}", result);

    let (version, build) = result.unwrap();
    println!("FMOD version: 0x{:08x}, build: {}", version, build);

    // Verify we got 2.03.x
    let major = (version >> 16) & 0xFF;
    let minor = (version >> 8) & 0xFF;
    let patch = version & 0xFF;

    assert_eq!(major, 2, "Expected major version 2, got {}", major);
    assert_eq!(minor, 3, "Expected minor version 3, got {}", minor);

    println!("✓ Version API works: {}.{}.{} (build {})", major, minor, patch, build);
}