#!/usr/bin/env bash
# yuleshow-cover installer
# Supports macOS (Homebrew) and Linux (apt / dnf / pacman).
#
# Usage:
#   ./install.sh              # install everything
#   ./install.sh --no-system  # skip system package installation
#   ./install.sh --uninstall  # remove installed wrapper and venv
#
# Environment overrides:
#   PREFIX=/custom/prefix     # default: $HOME/.local

set -euo pipefail

# ---------- Paths ----------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_SRC="$REPO_DIR/yuleshow-cover"
FONTS_DIR="$REPO_DIR/fonts"

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
APP_DIR="$PREFIX/share/yuleshow-cover"
VENV_DIR="$APP_DIR/venv"

SKIP_SYSTEM=0
UNINSTALL=0

for arg in "$@"; do
    case "$arg" in
        --no-system) SKIP_SYSTEM=1 ;;
        --uninstall) UNINSTALL=1 ;;
        -h|--help)
            sed -n '2,12p' "$0"; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

# ---------- Helpers ----------
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
die()  { printf '\033[1;31mXX\033[0m  %s\n' "$*" >&2; exit 1; }

detect_os() {
    case "$(uname -s)" in
        Darwin) OS=macos ;;
        Linux)  OS=linux ;;
        *) die "Unsupported OS: $(uname -s)" ;;
    esac
}

# ---------- Uninstall ----------
uninstall() {
    local target="$BIN_DIR/yuleshow-cover"
    if [ -f "$target" ] && grep -q "yuleshow-cover wrapper" "$target" 2>/dev/null; then
        rm -f "$target"
        echo "  removed $target"
    fi
    if [ -d "$APP_DIR" ]; then
        log "Removing $APP_DIR"
        rm -rf "$APP_DIR"
    fi
    log "Uninstall complete."
}

# ---------- System deps ----------
install_system_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        die "Homebrew not found. Install from https://brew.sh and re-run."
    fi
    log "Installing system packages via Homebrew"
    brew install --quiet python@3.13 || warn "python@3.13 may already be installed."
}

install_system_linux() {
    SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            SUDO=sudo
        else
            warn "Not root and sudo not available; skipping system package install."
            return 0
        fi
    fi

    if command -v apt-get >/dev/null 2>&1; then
        log "Installing system packages via apt-get"
        $SUDO apt-get update
        $SUDO apt-get install -y \
            python3 python3-venv python3-pip python3-dev \
            build-essential
    elif command -v dnf >/dev/null 2>&1; then
        log "Installing system packages via dnf"
        $SUDO dnf install -y \
            python3 python3-virtualenv python3-pip python3-devel \
            gcc gcc-c++ make
    elif command -v pacman >/dev/null 2>&1; then
        log "Installing system packages via pacman"
        $SUDO pacman -S --needed --noconfirm \
            python python-pip base-devel
    else
        warn "Unsupported Linux distro. Install manually: python3."
    fi
}

# ---------- Python venv ----------
setup_venv() {
    log "Creating Python virtualenv at $VENV_DIR"
    mkdir -p "$APP_DIR"
    if [ ! -x "$VENV_DIR/bin/python3" ]; then
        python3 -m venv "$VENV_DIR"
    fi
    "$VENV_DIR/bin/pip" install --upgrade pip wheel setuptools >/dev/null

    log "Installing Python packages"
    "$VENV_DIR/bin/pip" install \
        Pillow \
        opencc-python-reimplemented
}

# ---------- Fonts ----------
REQUIRED_FONTS=(
    NotoSansTC-Bold.ttf
    NotoSansSC-Bold.ttf
    NotoSerifTC-Black.ttf
    NotoSerifSC-Black.ttf
    NotoSansTC-Black.ttf
    NotoSansSC-Black.ttf
    Cinzel-Regular.ttf
    Sanchez-Regular.ttf
    SentyWen.ttf
    Arial-Bold.ttf
)

check_fonts() {
    [ -d "$FONTS_DIR" ] || die "Fonts dir not found: $FONTS_DIR"
    local missing=()
    for f in "${REQUIRED_FONTS[@]}"; do
        [ -f "$FONTS_DIR/$f" ] || missing+=("$f")
    done
    if [ "${#missing[@]}" -ne 0 ]; then
        warn "Missing required font(s) in $FONTS_DIR:"
        for f in "${missing[@]}"; do echo "    - $f"; done
        die "Please place the above font files into $FONTS_DIR and re-run."
    fi
    log "Fonts verified in $FONTS_DIR"
}

# ---------- Wrapper ----------
install_wrapper() {
    [ -f "$SCRIPT_SRC" ] || die "Script not found: $SCRIPT_SRC"
    log "Installing wrapper into $BIN_DIR"
    mkdir -p "$BIN_DIR"
    local target="$BIN_DIR/yuleshow-cover"
    cat > "$target" <<EOF
#!/usr/bin/env bash
# yuleshow-cover wrapper (python)
export YULESHOW_COVER_FONTS="$FONTS_DIR"
exec "$VENV_DIR/bin/python3" "$SCRIPT_SRC" "\$@"
EOF
    chmod +x "$target"
    chmod +x "$SCRIPT_SRC" 2>/dev/null || true
    echo "  installed $target"
}

# ---------- Post-install hints ----------
post_install_notes() {
    echo
    log "Installation complete."
    echo "    Wrapper : $BIN_DIR/yuleshow-cover"
    echo "    venv    : $VENV_DIR"
    echo "    fonts   : $FONTS_DIR"
    echo "    source  : $SCRIPT_SRC"

    case ":$PATH:" in
        *":$BIN_DIR:"*) ;;
        *)
            echo
            warn "$BIN_DIR is not in your PATH."
            echo "    Add this line to ~/.zshrc or ~/.bashrc:"
            echo "        export PATH=\"$BIN_DIR:\$PATH\""
            ;;
    esac

}

# ---------- Main ----------
main() {
    detect_os
    log "Detected OS: $OS"
    log "Install prefix: $PREFIX"

    if [ "$UNINSTALL" -eq 1 ]; then
        uninstall
        exit 0
    fi

    if [ "$SKIP_SYSTEM" -eq 0 ]; then
        if [ "$OS" = "macos" ]; then
            install_system_macos
        else
            install_system_linux
        fi
    else
        log "Skipping system package installation (--no-system)"
    fi

    setup_venv
    check_fonts
    install_wrapper
    post_install_notes
}

main
