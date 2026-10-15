#!/usr/bin/env bash
# Build a .deb for Developer Toolbox from the Flutter Linux release bundle.
# Usage: tools/build_deb.sh [out-dir]    (default out-dir: out)
#
# The package architecture comes from the machine this runs on (amd64 or
# arm64), because Flutter builds for the host. The output is
# <out-dir>/developer-toolbox_<version>_<arch>.deb, with the version taken from
# pubspec.yaml.
set -euo pipefail

cd "$(dirname "$0")/.."
OUT_DIR="${1:-out}"
PKGNAME="developer-toolbox"
VERSION="$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)"

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  amd64) FLUTTER_ARCH=x64 ;;
  arm64) FLUTTER_ARCH=arm64 ;;
  *)
    echo "error: unsupported architecture '$ARCH' (amd64 or arm64)" >&2
    exit 1
    ;;
esac

BUNDLE="build/linux/$FLUTTER_ARCH/release/bundle"
[ -x "$BUNDLE/developer_toolbox" ] || {
  echo "error: $BUNDLE/developer_toolbox not found; run 'flutter build linux --release' first" >&2
  exit 1
}

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
PKG="$STAGE/${PKGNAME}_${VERSION}_${ARCH}"

mkdir -p "$PKG/DEBIAN" "$PKG/usr/lib/$PKGNAME" "$PKG/usr/bin" \
  "$PKG/usr/share/applications" \
  "$PKG/usr/share/icons/hicolor/256x256/apps" \
  "$PKG/usr/share/icons/hicolor/512x512/apps"

cp -r "$BUNDLE"/. "$PKG/usr/lib/$PKGNAME/"
ln -s "/usr/lib/$PKGNAME/developer_toolbox" "$PKG/usr/bin/$PKGNAME"
cp assets/icon/icon_256.png "$PKG/usr/share/icons/hicolor/256x256/apps/$PKGNAME.png"
cp assets/icon/icon_512.png "$PKG/usr/share/icons/hicolor/512x512/apps/$PKGNAME.png"

cat > "$PKG/usr/share/applications/$PKGNAME.desktop" <<DESKTOP
[Desktop Entry]
Name=Developer Toolbox
Comment=Offline-first collection of developer tools
Exec=$PKGNAME
Icon=$PKGNAME
Terminal=false
Type=Application
Categories=Development;Utility;
Keywords=json;base64;regex;uuid;hash;jwt;qr;developer;
DESKTOP

find "$PKG/usr" -type d -exec chmod 0755 {} \;
chmod 0755 "$PKG/usr/lib/$PKGNAME/developer_toolbox"

cat > "$PKG/DEBIAN/control" <<CONTROL
Package: $PKGNAME
Version: $VERSION
Architecture: $ARCH
Maintainer: Dhivakar <dhivakar1010@gmail.com>
Installed-Size: $(du -sk "$PKG/usr" | cut -f1)
Depends: libgtk-3-0, libglib2.0-0, libstdc++6
Section: devel
Priority: optional
Homepage: https://github.com/dhivadhiva
Description: Offline-first collection of developer tools
 21 developer tools in one app: JSON formatter/validator, Base64 and
 URL encoding, regex tester, JWT decoder, UUID and password generators,
 hash generator, color tools, QR codes, timestamp converter and more.
 Built with Flutter, Material 3, fully offline.
CONTROL

mkdir -p "$OUT_DIR"
dpkg-deb --build --root-owner-group "$PKG" "$OUT_DIR/${PKGNAME}_${VERSION}_${ARCH}.deb"
echo "Built: $OUT_DIR/${PKGNAME}_${VERSION}_${ARCH}.deb"
