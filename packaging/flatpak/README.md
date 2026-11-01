# Flatpak

`com.dhivalabs.developer_toolbox.yml` packages the files the `.deb` installs
as a Flatpak on the GNOME 51 runtime, so the Flatpak runs the same binary as
every other Linux format.

## How CI builds it

The `flatpak` job in `.github/workflows/build.yml`, on x86_64 and aarch64:

1. takes the installed tree of that architecture's `.deb` from the `distros`
   job and unpacks it into `packaging/flatpak/tree/` (ignored by git);
2. builds the manifest with `flatpak/flatpak-github-actions/flatpak-builder`
   in Flathub's builder image and exports
   `developer-toolbox-<version>-<arch>.flatpak`, with Flathub as the runtime
   repo;
3. runs `smoke.sh`: installs the bundle with `flatpak install --user`, runs
   ldd on every ELF file inside the sandbox, then starts the app with a home
   directory laid out like a desktop's and checks that it created its Hive
   settings box in `~/Documents` and drew its window (colours in Xvfb's
   framebuffer, read by `xwd-colours.py`).

The bundle is attached to releases next to the other packages. Install it
with:

```sh
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user ./developer-toolbox-<version>-<arch>.flatpak
flatpak run com.dhivalabs.developer_toolbox
```

## Permissions

- `--filesystem=xdg-documents`: Hive stores the settings (theme, favourites)
  in the Documents folder (`getApplicationDocumentsDirectory`), as every
  other Linux build does.
- No network: the tools are offline. Clipboard access goes through the
  display server.

## Submitting to Flathub

Not done; the user decides. A Flathub submission would differ:

- the `tree` dir source becomes the release `.deb` of each architecture (a
  `type: file` source with `only-arches`, url and sha256, unpacked with
  `bsdtar` in the build commands), or a build from source with the Flutter
  SDK as a module;
- the repository needs a licence (the metainfo says
  `LicenseRef-proprietary` because there is none), `<releases>` must list
  each new version, and Flathub wants screenshots.
