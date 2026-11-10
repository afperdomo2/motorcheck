#!/usr/bin/env bash
# Instala MotorCheck en el perfil del usuario actual a partir del bundle de
# release.
#
#   ./scripts/install-linux.sh              # instalar o actualizar
#   ./scripts/install-linux.sh --uninstall  # desinstalar
#
# Antes hay que compilar:
#   flutter build linux --release --no-tree-shake-icons
#
# Destinos:
#   ~/.local/opt/motorcheck         binario + data/ + lib/
#   ~/.local/bin/motorcheck         symlink en el PATH del usuario
#   ~/.local/share/applications/    entrada de menú (.desktop)
#   ~/.local/share/icons/hicolor/   icono de 256x256
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_DIR="$REPO_ROOT/build/linux/x64/release/bundle"
INSTALL_DIR="${MOTORCHECK_INSTALL_DIR:-$HOME/.local/opt/motorcheck}"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
DESKTOP_PATH="$APPS_DIR/motorcheck.desktop"
ICON_PATH="$ICON_DIR/motorcheck.png"
ICON_SRC="$REPO_ROOT/linux/motorcheck.png"
DESKTOP_SRC="$REPO_ROOT/linux/motorcheck.desktop"
EXECUTABLE="$INSTALL_DIR/motorcheck"

info() { printf '  %s\n' "$*"; }

refresh_caches() {
  command -v update-desktop-database >/dev/null 2>&1 &&
    update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
  command -v gtk-update-icon-cache >/dev/null 2>&1 &&
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true
}

install_app() {
  if [[ ! -x "$BUNDLE_DIR/motorcheck" ]]; then
    echo "✗ No encuentro el build de release en:" >&2
    echo "    $BUNDLE_DIR" >&2
    echo "  Compilá primero con: flutter build linux --release --no-tree-shake-icons" >&2
    exit 1
  fi

  echo "→ Instalando MotorCheck en $INSTALL_DIR"
  rm -rf "$INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  cp -a "$BUNDLE_DIR/." "$INSTALL_DIR/"

  mkdir -p "$BIN_DIR"
  ln -sfn "$EXECUTABLE" "$BIN_DIR/motorcheck"
  info "$BIN_DIR/motorcheck → $EXECUTABLE"

  mkdir -p "$ICON_DIR"
  cp -f "$ICON_SRC" "$ICON_PATH"
  info "$ICON_PATH"

  mkdir -p "$APPS_DIR"
  sed "s|@EXEC@|$EXECUTABLE|g" "$DESKTOP_SRC" > "$DESKTOP_PATH"
  chmod 644 "$DESKTOP_PATH"
  info "$DESKTOP_PATH"

  refresh_caches

  case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
      echo
      echo "⚠ $BIN_DIR no está en tu PATH. Agregalo a ~/.bashrc para lanzar"
      echo "  'motorcheck' desde la terminal:"
      echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
      ;;
  esac

  echo
  echo "✓ Listo. Buscá \"MotorCheck\" en el menú de aplicaciones o ejecutá: motorcheck"
}

uninstall_app() {
  echo "→ Desinstalando MotorCheck"
  rm -rf "$INSTALL_DIR"
  rm -f "$BIN_DIR/motorcheck" "$DESKTOP_PATH" "$ICON_PATH"
  refresh_caches
  echo "✓ Listo."
}

case "${1:-}" in
  "") install_app ;;
  -u|--uninstall) uninstall_app ;;
  *)
    echo "Uso: $(basename "$0") [--uninstall]" >&2
    exit 2
    ;;
esac
