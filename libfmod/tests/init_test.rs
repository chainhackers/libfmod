// Phase 3.3: Test System Initialization for FMOD 2.03.09

use libfmod::{Init, System};

#[test]
fn test_system_init() {
    let system = System::create().unwrap();
    let result = system.init(512, Init::NORMAL, None);

    assert!(result.is_ok(), "Init failed: {:?}", result);
    println!("✓ System initialized with 512 channels");

    system.release().ok();
}

#[test]
fn test_minimal_init() {
    let system = System::create().unwrap();
    let result = system.init(32, Init::NORMAL, None); // Minimal channels

    assert!(result.is_ok(), "Minimal init failed: {:?}", result);
    println!("✓ Minimal system works");

    system.release().ok();
}
