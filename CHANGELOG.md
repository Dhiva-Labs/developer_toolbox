# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-10-16

### Added
- Linux arm64 and Windows arm64 builds, next to the x64 ones. Releases carry
  `developer-toolbox_<version>_amd64.deb`, `developer-toolbox_<version>_arm64.deb`,
  `developer-toolbox-<version>-windows-x64.zip` and
  `developer-toolbox-<version>-windows-arm64.zip`. Every package is built, tested
  and started on a runner of its own architecture.
- Windows zip packages (x64 and arm64).
- Releases are completed by CI: publishing a release attaches the desktop
  packages, leaving alone any file name already on the release. The Android
  APKs are still attached by hand because they are signed with the debug key.

### Changed
- `jni` is updated to 1.0.3, which compiles on Linux arm64.
- The Android app is unchanged since 1.0.0.

## [1.0.0] - 2026-07-13

- Initial release: text, JSON, security, web, design and utility tools, with
  Android APKs and a Linux amd64 `.deb`.
