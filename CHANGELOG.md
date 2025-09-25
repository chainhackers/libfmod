# Changelog

## [Unreleased] - 2024-09-25

### Added
- Support for FMOD 2.03.09
- `play_sound` example with progress tracking
- `run_fmod.sh` convenience script

### Changed
- `System::getVersion()` returns `(version, buildnumber)` tuple
- Field filtering for removed/renamed structure fields

### Breaking Changes
- `System::getVersion()` signature changed
- `FMOD_ADVANCEDSETTINGS.commandQueueSize` removed
- Requires FMOD 2.03.09 SDK