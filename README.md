# Developer Toolbox

[![ARM64 builds](https://github.com/Dhiva-Labs/developer_toolbox/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/Dhiva-Labs/developer_toolbox/actions/workflows/build.yml)
![Linux x64 | arm64](https://img.shields.io/badge/Linux-x64%20%7C%20arm64-informational?logo=linux&logoColor=white)
![Windows x64 | arm64](https://img.shields.io/badge/Windows-x64%20%7C%20arm64-informational?logo=windows&logoColor=white)
![Linux: deb | rpm | Arch | AppImage | Flatpak](https://img.shields.io/badge/Linux-deb%20%7C%20rpm%20%7C%20Arch%20%7C%20AppImage%20%7C%20Flatpak-informational?logo=linux&logoColor=white)

A clean, offline-first collection of developer tools built with Flutter.
One codebase, runs on **Windows, Linux, and Android**.

## Tools

| Category | Tools |
|---|---|
| Text | Case Converter, Word & Character Counter, Remove Duplicate Lines, Base64 Encode/Decode, URL Encode/Decode |
| JSON | Formatter, Minifier, Validator (with line/column errors) |
| Security | JWT Decoder, UUID Generator (v1/v4/v7), Password Generator, Hash Generator (MD5/SHA-1/SHA-256/SHA-512) |
| Web | Regex Tester (live highlight + groups), HTTP Status Code Reference, URL Parser |
| Design | Color Picker, HEX ↔ RGB Converter, CSS Gradient Generator |
| Utilities | QR Code Generator, QR Code Scanner (Android), Unix Timestamp Converter |

## Features

- Material 3 with light / dark / system theme (persisted)
- Search bar and category filters to find tools quickly
- Star tools as favorites (persisted with Hive)
- Responsive: grid scales from 1 column on phones to 4 on wide desktops

## Architecture

Tools are registered in [`lib/core/registry.dart`](lib/core/registry.dart).
Adding a tool is two steps:

1. Build a widget for it (see `lib/tools/` — use the shared `ToolPage`,
   `ToolInput`, and `ToolOutput` widgets from `lib/widgets/tool_widgets.dart`).
2. Append a `Tool(...)` entry to `allTools` with an id, name, description,
   icon, category, and search keywords.

State management is Riverpod; persistence (theme + favorites) is Hive.

## Install

Every release carries the desktop builds for x64 and arm64, next to the Android
APKs:

| Platform | Architecture | Asset |
|---|---|---|
| Linux (Debian, Ubuntu) | x64 | `developer-toolbox_<version>_amd64.deb` |
| Linux (Debian, Ubuntu) | arm64 | `developer-toolbox_<version>_arm64.deb` |
| Windows | x64 | `developer-toolbox-<version>-windows-x64.zip` |
| Windows | arm64 | `developer-toolbox-<version>-windows-arm64.zip` |

```sh
sudo apt install ./developer-toolbox_<version>_arm64.deb   # or _amd64.deb
```

On Windows, unzip and run `developer_toolbox.exe`.

### Other Linux distributions

From the next release on, releases also carry packages for other
distributions, built from the same binaries as the `.deb` (`x86_64` and
`aarch64`):

| Distribution | Asset | Install |
|---|---|---|
| Fedora, RHEL/Rocky/Alma | `developer-toolbox-<version>-1.<arch>.rpm` | `sudo dnf install ./developer-toolbox-<version>-1.<arch>.rpm` |
| openSUSE Tumbleweed | `developer-toolbox-<version>-1.<arch>.rpm` | `sudo zypper install --allow-unsigned-rpm ./developer-toolbox-<version>-1.<arch>.rpm` |
| Arch, Manjaro, EndeavourOS | `developer-toolbox-<version>-1-<arch>.pkg.tar.zst` | `sudo pacman -U ./developer-toolbox-<version>-1-<arch>.pkg.tar.zst` |
| Any (AppImage) | `DeveloperToolbox-<version>-<arch>.AppImage` | `chmod +x DeveloperToolbox-<version>-<arch>.AppImage && ./DeveloperToolbox-<version>-<arch>.AppImage` |
| Any (Flatpak) | `developer-toolbox-<version>-<arch>.flatpak` | `flatpak install --user ./developer-toolbox-<version>-<arch>.flatpak` |

- The binaries are built on Ubuntu 24.04, so they need glibc 2.39 or newer:
  Fedora 40+, openSUSE Tumbleweed and current Arch, but not openSUSE Leap 15
  or RHEL 9. The AppImage uses the system's GTK 3, and `xdg-user-dir`
  (xdg-user-dirs, on every desktop) to find the Documents folder its
  settings live in.
- The `.rpm` files are unsigned (hence `--allow-unsigned-rpm` on openSUSE).
- The Flatpak bundle uses the GNOME 51 runtime from Flathub: add the Flathub
  remote first (`flatpak remote-add --user --if-not-exists flathub
  https://dl.flathub.org/repo/flathub.flatpakrepo`). Its only permission
  beyond the display is the Documents folder, where the settings are kept.
- Arch users can build `developer-toolbox-bin` from the AUR recipe attached
  to each release (`developer-toolbox-bin-<version>-aur.tar.gz`: PKGBUILD
  and .SRCINFO).

The [Build releases](.github/workflows/build.yml) workflow builds, tests and
starts the packaged app on Linux and Windows, x64 and arm64, on every push.
The `.rpm` is installed and run on Fedora and openSUSE Tumbleweed, the Arch
package on Arch Linux (x64; arm64 gets a static check, as there is no official
Arch Linux ARM image), the AppImage on Fedora, and the Flatpak in its
sandbox.

## Building

```sh
flutter pub get
flutter run                  # current desktop platform
flutter build linux --release
flutter build windows --release   # on Windows
flutter build apk --release
tools/build_deb.sh                # Linux .deb for this machine's architecture (amd64 or arm64)
```

Flutter builds for the machine it runs on, so the arm64 builds come from an arm64
Linux or Windows machine.

QR scanning uses the device camera and is available on Android only;
desktop builds show a friendly notice instead.

## Sponsors

Dhiva Labs is an independent, self-funded lab. [Sponsorships](https://github.com/sponsors/Dhiva-Labs) help bring this project and the rest of Dhiva Labs to every platform, iPhone and Mac included.

[![Sponsor Dhiva Labs](https://img.shields.io/badge/Sponsor-Dhiva%20Labs-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/Dhiva-Labs)

Monthly sponsors at $10 and up are listed here:

<!-- sponsors -->
*Be the first: [sponsor Dhiva Labs](https://github.com/sponsors/Dhiva-Labs).*
<!-- sponsors -->

# developer_toolbox
