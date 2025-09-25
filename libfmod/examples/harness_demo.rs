// Demo version of the interactive harness - shows functionality without terminal interaction
// Run with: ./run_fmod.sh harness_demo

use libfmod::{Studio, StudioInit, Init, LoadBank, StopMode, Vector, Attributes3d};
use std::{thread, time::Duration};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n╔══════════════════════════════════════════════════════════╗");
    println!("║     FMOD Interactive Harness Demo (Non-Interactive)       ║");
    println!("╚══════════════════════════════════════════════════════════╝\n");

    // Initialize Studio
    let studio = Studio::create()?;
    studio.initialize(1024, StudioInit::NORMAL, Init::NORMAL, None)?;

    // Load banks
    let bank_dir = "../libfmod-gen/fmod/20309/api/studio/examples/media/";
    let master = studio.load_bank_file(&format!("{}/Master.bank", bank_dir), LoadBank::NORMAL)?;
    let strings = studio.load_bank_file(&format!("{}/Master.strings.bank", bank_dir), LoadBank::NORMAL)?;
    let sfx = studio.load_bank_file(&format!("{}/SFX.bank", bank_dir), LoadBank::NORMAL)?;
    let vehicles = studio.load_bank_file(&format!("{}/Vehicles.bank", bank_dir), LoadBank::NORMAL)?;

    println!("✓ Banks loaded: Master, SFX, Vehicles\n");

    // Demo 1: Event Playback
    println!("📌 DEMO 1: Event Playback");
    println!("─────────────────────────");

    let explosion_desc = studio.get_event("event:/Weapons/Explosion")?;
    let explosion = explosion_desc.create_instance()?;

    println!("Playing explosion...");
    explosion.start()?;

    for _ in 0..30 {
        studio.update()?;
        thread::sleep(Duration::from_millis(50));
    }
    explosion.release()?;
    println!("✓ Explosion complete\n");

    // Demo 2: 3D Spatial Audio
    println!("📌 DEMO 2: 3D Spatial Audio Movement");
    println!("────────────────────────────────────");

    let vehicle_desc = studio.get_event("event:/Vehicles/Ride-on Mower")?;
    let vehicle = vehicle_desc.create_instance()?;

    println!("Starting vehicle engine...");
    vehicle.start()?;

    // Move the vehicle in 3D space
    println!("Moving vehicle from left to right:");

    for i in 0..40 {
        let x = (i as f32 - 20.0) * 0.5;
        let z = -5.0 + (i as f32 * 0.1).sin() * 2.0;

        let attributes = Attributes3d {
            position: Vector { x, y: 0.0, z },
            velocity: Vector { x: 1.0, y: 0.0, z: 0.0 },
            forward: Vector { x: 1.0, y: 0.0, z: 0.0 },
            up: Vector { x: 0.0, y: 1.0, z: 0.0 },
        };

        vehicle.set_3d_attributes(attributes).ok();

        // Visual position indicator
        let visual_pos = ((x + 10.0) * 2.0) as usize;
        let line = format!("{:>width$}●", "", width = visual_pos.min(40));
        print!("\r  [{:<40}] X:{:5.1} Z:{:5.1}", line, x, z);
        use std::io::{self, Write};
        io::stdout().flush()?;

        studio.update()?;
        thread::sleep(Duration::from_millis(50));
    }

    println!("\nStopping vehicle...");
    vehicle.stop(StopMode::AllowFadeout)?;

    for _ in 0..20 {
        studio.update()?;
        thread::sleep(Duration::from_millis(50));
    }
    vehicle.release()?;
    println!("✓ 3D movement complete\n");

    // Demo 3: Parameter Control
    println!("📌 DEMO 3: Real-time Parameter Control");
    println!("───────────────────────────────────────");

    let vehicle2 = vehicle_desc.create_instance()?;
    vehicle2.start()?;

    println!("Adjusting vehicle RPM:");

    for rpm_level in [0.0, 1000.0, 2000.0, 3000.0, 4000.0, 2000.0, 0.0] {
        print!("  RPM: {:4.0} ", rpm_level);

        // Visual RPM meter
        let bar_length = (rpm_level / 200.0) as usize;
        for i in 0..20 {
            if i < bar_length {
                print!("█");
            } else {
                print!("░");
            }
        }
        println!();

        vehicle2.set_parameter_by_name("RPM", rpm_level, false).ok();
        vehicle2.set_parameter_by_name("rpm", rpm_level, false).ok();

        for _ in 0..15 {
            studio.update()?;
            thread::sleep(Duration::from_millis(50));
        }
    }

    vehicle2.stop(StopMode::AllowFadeout)?;
    for _ in 0..20 {
        studio.update()?;
        thread::sleep(Duration::from_millis(50));
    }
    vehicle2.release()?;
    println!("✓ Parameter control complete\n");

    // Demo 4: Multiple Instances
    println!("📌 DEMO 4: Multiple Simultaneous Events");
    println!("────────────────────────────────────────");

    let footstep_desc = studio.get_event("event:/Character/Player Footsteps")?;

    println!("Playing footsteps pattern:");
    print!("  ");

    for step in 1..=10 {
        print!("👟 ");
        use std::io::{self, Write};
        io::stdout().flush()?;

        let footstep = footstep_desc.create_instance()?;
        footstep.set_parameter_by_name("Surface", (step % 3) as f32, false).ok();
        footstep.start()?;
        footstep.release()?;

        for _ in 0..5 {
            studio.update()?;
            thread::sleep(Duration::from_millis(50));
        }
    }
    println!("\n✓ Multiple instances complete\n");

    // Summary
    println!("╔══════════════════════════════════════════════════════════╗");
    println!("║                    DEMO COMPLETE!                         ║");
    println!("╟────────────────────────────────────────────────────────────╢");
    println!("║ The interactive harness supports:                         ║");
    println!("║   • Real-time keyboard control                            ║");
    println!("║   • 3D spatial positioning (WASD + QE)                    ║");
    println!("║   • Parameter adjustment (+/-)                            ║");
    println!("║   • Multiple event instances                              ║");
    println!("║   • Visual feedback and status display                    ║");
    println!("║                                                            ║");
    println!("║ To use the full interactive version, run:                 ║");
    println!("║   ./target/debug/examples/interactive_harness             ║");
    println!("║ in a proper terminal with keyboard support                ║");
    println!("╚══════════════════════════════════════════════════════════╝");

    // Cleanup
    vehicles.unload()?;
    sfx.unload()?;
    strings.unload()?;
    master.unload()?;
    studio.release()?;

    Ok(())
}