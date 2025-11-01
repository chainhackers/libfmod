// Phase 3.1: Test System Creation for FMOD 2.03.09

use libfmod::{Error, System};

#[test]
fn test_system_create() {
    let system = System::create();
    assert!(system.is_ok(), "System creation failed: {:?}", system);
    println!("✓ System created successfully");
}

#[test]
fn test_system_create_and_release() {
    let system = System::create().unwrap();
    let result = system.release();
    assert!(result.is_ok(), "System release failed: {:?}", result);
    println!("✓ System lifecycle works");
}
