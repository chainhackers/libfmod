# Changelog

## [Unreleased] - 2025-11-06

### Added
- Support for FMOD 2.03.09
- Parser grammar support for variadic macros with `##__VA_ARGS__`
- Integration test for macro parsing

### Changed
- `System::getVersion()` returns `(version, buildnumber)` tuple
- Generator uses patching system for removed/renamed structure fields

### Breaking Changes
- `System::getVersion()` signature changed
- `FMOD_ADVANCEDSETTINGS.commandQueueSize` removed
- Requires FMOD 2.03.09 SDK