/// Integration test: Verify that the parser can handle FMOD 2.03.09 variadic macros
/// with line continuations and token pasting operators (##__VA_ARGS__)
///
/// This test addresses PR #23 feedback: macro handling must be in parser grammar, not bash scripts.
/// Before the fix, these macros would cause parsing errors at the ## token.

use std::path::Path;
use std::process::Command;

#[test]
fn test_parse_original_fmod_headers() {
    let sdk_path = Path::new("./fmod/20309");

    // Skip test if FMOD SDK not present
    if !sdk_path.exists() {
        eprintln!("Skipping test: FMOD SDK not found at {:?}", sdk_path);
        return;
    }

    // Run the generator - it should succeed without preprocessing
    let output = Command::new("cargo")
        .arg("run")
        .arg("--")
        .arg(sdk_path)
        .arg("/tmp/test_parser_output")
        .output()
        .expect("Failed to execute generator");

    // Check if the command succeeded
    assert!(
        output.status.success(),
        "Generator failed to parse original FMOD headers.\n\
         This likely means variadic macros with ##__VA_ARGS__ are not being handled correctly.\n\
         stdout: {}\n\
         stderr: {}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );

    // Verify we see the expected parsing output
    let stdout = String::from_utf8_lossy(&output.stdout);

    // Should see successful parsing stats
    assert!(
        stdout.contains("Opaque Types:"),
        "Expected to see parsing statistics in output"
    );

    assert!(
        stdout.contains("Structures:"),
        "Expected to see structure count in output"
    );

    // Should NOT see pest parsing errors about ##__VA_ARGS__
    assert!(
        !stdout.contains("##__VA_ARGS__"),
        "Parser should handle ##__VA_ARGS__ macros without error"
    );
}
