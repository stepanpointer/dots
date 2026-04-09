#!/usr/bin/env bash
# install.sh — bootstrap this rice on a fresh Debian + Sway system
# Run as a regular user (sudo will be called where needed)

set -euo pipefail

# ── colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "${GREEN}[✓]${NC} $*"; }
info() { echo -e "${CYAN}[→]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
die()  { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── helpers ───────────────────────────────────────────────────────────────────
has() { command -v "$1" &>/dev/null; }

apt_install() {
    info "apt: $*"
    sudo apt-get install -y --no-install-recommends --fix-missing "$@"
}

# ── 1. system update ──────────────────────────────────────────────────────────
info "Updating package lists…"
sudo apt-get update -qq
sudo dpkg --configure -a
sudo apt-get install -f -y
sudo apt-get autoremove -y

# ── 2. enable non-free for unrar ──────────────────────────────────────────────
if ! grep -q "non-free" /etc/apt/sources.list 2>/dev/null && \
   ! grep -rq "non-free" /etc/apt/sources.list.d/ 2>/dev/null; then
    warn "Enabling non-free repo for unrar…"
    sudo sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list
    sudo apt-get update -qq
fi

# ── 3. core apt packages ──────────────────────────────────────────────────────
info "Installing core packages…"
apt_install \
    sway swayidle swaylock \
    waybar \
    rofi \
    dunst \
    kitty \
    ranger \
    btop \
    thunar \
    fzf \
    copyq \
    syncthing \
    flameshot \
    grim slurp \
    wl-clipboard \
    brightnessctl \
    pavucontrol \
    lm-sensors \
    xdg-utils \
    xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    libnotify-bin \
    pipewire pipewire-pulse wireplumber \
    python3 python3-pip python3-pil \
    imagemagick \
    libarchive-tools \
    p7zip-full \
    poppler-utils \
    jq \
    mediainfo \
    highlight \
    w3m \
    curl wget git \
    fonts-jetbrains-mono

ok "Core packages installed"


# unrar: try proprietary first, fall back to free alternative
if sudo apt-get install -y --no-install-recommends unrar 2>/dev/null; then
    ok "unrar (non-free) installed"
elif sudo apt-get install -y --no-install-recommends unrar-free 2>/dev/null; then
    ok "unrar-free installed"
else
    warn "Neither unrar nor unrar-free found — RAR preview in ranger won't work"
fi

# ── 4. neovim (Debian ships an old version, grab latest .deb from GitHub) ─────
if ! has nvim || [[ "$(nvim --version | head -1 | grep -oP '\d+\.\d+')" < "0.9" ]]; then
    info "Installing neovim from GitHub releases…"
    NVIM_URL=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
        | grep "browser_download_url.*nvim-linux-x86_64.deb" \
        | cut -d '"' -f 4)
    TMP=$(mktemp -d)
    wget -q --show-progress -O "$TMP/nvim.deb" "$NVIM_URL"
    sudo apt-get install -y "$TMP/nvim.deb"
    rm -rf "$TMP"
    ok "neovim installed ($(nvim --version | head -1))"
else
    ok "neovim already up-to-date"
fi

# ── 5. fastfetch ──────────────────────────────────────────────────────────────
if ! has fastfetch; then
    info "Installing fastfetch from GitHub releases…"
    FF_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
        | grep "browser_download_url.*linux-amd64.deb" \
        | cut -d '"' -f 4)
    TMP=$(mktemp -d)
    wget -q --show-progress -O "$TMP/fastfetch.deb" "$FF_URL"
    sudo apt-get install -y "$TMP/fastfetch.deb"
    rm -rf "$TMP"
    ok "fastfetch installed"
else
    ok "fastfetch already installed"
fi

# ── 6. firefox ────────────────────────────────────────────────────────────────
if ! has firefox && ! has firefox-esr; then
    apt_install firefox-esr
fi
ok "Firefox installed"

# ── 7. pip packages ───────────────────────────────────────────────────────────
info "Installing pip packages…"
pip3 install pywal --break-system-packages
pip3 install i3-autolayout --break-system-packages   # provides i3a-master-stack, i3a-swap
ok "pip packages installed"

# ── 8. JetBrainsMono Nerd Font ────────────────────────────────────────────────
FONT_DIR="$HOME/.local/share/fonts"
if ! fc-list | grep -q "JetBrainsMono.*NF"; then
    info "Installing JetBrainsMono Nerd Font…"
    mkdir -p "$FONT_DIR"
    TMP=$(mktemp -d)
    NF_URL=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
        | grep "browser_download_url.*JetBrainsMono.tar.xz" \
        | cut -d '"' -f 4)
    wget -q --show-progress -O "$TMP/JetBrainsMono.tar.xz" "$NF_URL"
    tar -xf "$TMP/JetBrainsMono.tar.xz" -C "$FONT_DIR"
    fc-cache -f
    rm -rf "$TMP"
    ok "JetBrainsMono Nerd Font installed"
else
    ok "JetBrainsMono Nerd Font already installed"
fi

# ── 9. Nordzy cursor & icon theme ─────────────────────────────────────────────
if [ ! -d "/usr/share/icons/Nordzy-cursors" ] && [ ! -d "$HOME/.local/share/icons/Nordzy-cursors" ]; then
    info "Installing Nordzy cursor theme…"
    TMP=$(mktemp -d)
    git clone --depth=1 https://github.com/alvatip/Nordzy-cursors.git "$TMP/Nordzy-cursors"
    mkdir -p "$HOME/.local/share/icons"
    cp -r "$TMP/Nordzy-cursors/themes/Nordzy-cursors" "$HOME/.local/share/icons/"
    rm -rf "$TMP"
    ok "Nordzy cursors installed"
else
    ok "Nordzy cursors already installed"
fi

if [ ! -d "/usr/share/icons/Nordzy-dark" ] && [ ! -d "$HOME/.local/share/icons/Nordzy-dark" ]; then
    info "Installing Nordzy icon theme (for dunst)…"
    TMP=$(mktemp -d)
    git clone --depth=1 https://github.com/alvatip/Nordzy-icon.git "$TMP/Nordzy-icon"
    mkdir -p "$HOME/.local/share/icons"
    cp -r "$TMP/Nordzy-icon/Nordzy-dark" "$HOME/.local/share/icons/"
    rm -rf "$TMP"
    ok "Nordzy icons installed"
else
    ok "Nordzy icons already installed"
fi

# ── 10. symlink dotfiles ──────────────────────────────────────────────────────
info "Symlinking dotfiles to ~/.config/…"
CONFIGS=(sway waybar ranger btop fastfetch)

for d in "${CONFIGS[@]}"; do
    TARGET="$HOME/.config/$d"
    SOURCE="$DOTFILES/$d"
    if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
        warn "~/.config/$d exists and is not a symlink — backing up to ~/.config/${d}.bak"
        mv "$TARGET" "$TARGET.bak"
    fi
    ln -sfn "$SOURCE" "$TARGET"
    ok "~/.config/$d → $SOURCE"
done

# extra dirs that need to exist for pywal script
mkdir -p \
    "$HOME/.config/rofi/colors" \
    "$HOME/.config/rofi/scripts" \
    "$HOME/.config/dunst" \
    "$HOME/.config/swaylock" \
    "$HOME/.config/copyq/themes" \
    "$HOME/.config/flameshot" \
    "$HOME/.config/qimgv" \
    "$HOME/.config/Kvantum" \
    "$HOME/.local/bin"

# ── 11. install pywal templates ───────────────────────────────────────────────
info "Copying pywal templates to ~/.config/wal/templates/…"
mkdir -p "$HOME/.config/wal/templates"
cp -f "$DOTFILES"/wal/templates/* "$HOME/.config/wal/templates/"

# install the post-wal hook script
cp -f "$DOTFILES/wal/scripts/pywal" "$HOME/.local/bin/pywal-post"
chmod +x "$HOME/.local/bin/pywal-post"
ok "pywal templates installed"

# ── 12. initial pywal run (needs a wallpaper) ─────────────────────────────────
WALLPAPER="$DOTFILES/bg/30.Rembrandt_-_Aristotle_with_a_Bust_of_Homer_-_WGA19232.jpg"
if [ -f "$WALLPAPER" ]; then
    info "Running pywal with the bundled wallpaper…"
    wal -i "$WALLPAPER" --backend haishoku 2>/dev/null \
        || wal -i "$WALLPAPER" 2>/dev/null \
        || warn "wal failed — run 'wal -i <wallpaper>' manually after reboot"
    # run the post-wal symlink script
    "$HOME/.local/bin/pywal-post" 2>/dev/null || true
    ok "pywal colorscheme generated"
else
    warn "Wallpaper not found at $WALLPAPER — run 'wal -i <image>' manually"
fi

# ── 13. rofi config (needs scripts from another source) ───────────────────────
warn "rofi launcher/powermenu scripts are NOT in this repo."
warn "The sway config calls:"
warn "  ~/.config/rofi/scripts/launcher_t1"
warn "  ~/.config/rofi/scripts/powermenu_t1"
warn "Get them from: https://github.com/adi1090x/rofi"
warn "  cd /tmp && git clone --depth=1 https://github.com/adi1090x/rofi.git"
warn "  cp -r /tmp/rofi/files/* ~/.config/rofi/"

# ── 14. done ──────────────────────────────────────────────────────────────────
echo
echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}  Installation complete!${NC}"
echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
echo
echo -e "  ${CYAN}Next steps:${NC}"
echo -e "  1. Log out and select ${BOLD}Sway${NC} in the display manager"
echo -e "  2. If rofi scripts missing — see warning above"
echo -e "  3. Press ${BOLD}Alt+Shift${NC} to switch keyboard layout (us ↔ ru)"
echo -e "  4. Run ${BOLD}wal -i <wallpaper>${NC} to regenerate the colorscheme"
echo -e "  5. After wal, run ${BOLD}pywal-post${NC} to apply colors to all apps"
echo
