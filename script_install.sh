#!/usr/bin/env bash
set -euo pipefail

# Variables
POLYBAR_DIR="$HOME/.config/polybar"
PICOM_DIR="$HOME/.config/picom"
ROFI_DIR="$HOME/.config/rofi"
BSPWM_DIR="$HOME/.config/bspwm"
SXHKD_DIR="$HOME/.config/sxhkd"
STARSHIP_DIR="$HOME/.config/starship"

# 1. Actualizar e instalar paquetes base
sudo apt update
sudo apt install -y \
  xfce4-core lightdm \
  bspwm sxhkd lemonbar \
  polybar picom rofi \
  zsh curl git wget build-essential net-tools \
  nmap wireshark john hashcat binwalk \
  python3 python3-pip openvpn jq fzf tmux \
  network-manager

# 2. Habilitar NetworkManager
sudo systemctl enable --now NetworkManager

# 3. Zsh + Starship
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi
chsh -s "$(which zsh)" || true

# 4. Crear config dirs
mkdir -p "$POLYBAR_DIR" "$PICOM_DIR" "$ROFI_DIR" \
         "$BSPWM_DIR" "$SXHKD_DIR" "$STARSHIP_DIR"

# 5. starship.toml
cat > "$STARSHIP_DIR/starship.toml" << 'EOF'
# Minimal Gruvbox Dark prompt
add_newline = false
format = "\$character \$git_branch \$status"
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"
EOF

# 6. bspwmrc + sxhkdrc
cat > "$BSPWM_DIR/bspwmrc" << 'EOF'
#!/usr/bin/env bash
# Autostart
picom --config "$HOME/.config/picom/picom.conf" -b
"$HOME/.config/polybar/launch.sh" &
# Set wallpaper (if tienes feh instalado):
# feh --bg-scale /ruta/a/fondo.jpg
exec bspwm
EOF
chmod +x "$BSPWM_DIR/bspwmrc"

cat > "$SXHKD_DIR/sxhkdrc" << 'EOF'
# Switch desktop
super + {1-9}
    bspc desktop -f '^{}'

# Terminal
super + Return
    alacritty

# Rofi app launcher
super + d
    rofi -show drun

# Rofi window switcher
super + w
    rofi -show window

# Close window
super + shift + q
    bspc node -c
EOF

# 7. Polybar config + launcher
cat > "$POLYBAR_DIR/config" << 'EOF'
[bar/main]
width = 100%
height = 24
background = #2E3440
foreground = #D8DEE9
font-0 = "Iosevka Nerd Font:size=10;3"
modules-left = bspwm
modules-right = cpu memory wlan date

[module/bspwm]
type = internal/bspwm
label-focused = %index%

[module/cpu]
type = internal/cpu
format = CPU %percentage:2%%

[module/memory]
type = internal/memory
format = RAM %used%/%total%MiB

[module/wlan]
type = internal/network
interface = wlp2s0
format-connected =  %essid%

[module/date]
type = internal/date
date = %Y-%m-%d %H:%M
EOF

cat > "$POLYBAR_DIR/launch.sh" << 'EOF'
#!/usr/bin/env bash
killall -q polybar
sleep 1
polybar main &
EOF
chmod +x "$POLYBAR_DIR/launch.sh"

# 8. Picom config
cat > "$PICOM_DIR/picom.conf" << 'EOF'
backend = "glx"
vsync = true

shadow = true
shadow-radius = 7
shadow-opacity = 0.4
shadow-exclude = ["class_g = 'Polybar'"]

corner-radius = 6

blur-method = "kernel"
blur-strength = 3

fade = false
EOF

# 9. Rofi config
cat > "$ROFI_DIR/config.rasi" << 'EOF'
@import "rose-pine-dawn.rasi";
configuration {
  modi: "drun,window";
  show-icons: true;
  icon-theme: "Papirus";
  width: 40%;
  lines: 10;
  padding: 5px;
}
EOF

# 10. xinitrc para LightDM session
SESSION_FILE="/usr/share/xsessions/custom-bspwm.desktop"
sudo tee "$SESSION_FILE" > /dev/null << 'EOF'
[Desktop Entry]
Name=BSPWM Custom
Exec=startx
Type=Application
EOF

cat > "$HOME/.xinitrc" << 'EOF'
#!/usr/bin/env bash
exec bspwm
EOF
chmod +x "$HOME/.xinitrc"

# 11. Entorno Zsh init
echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"

echo "¡Listo! Cierra sesión y selecciona 'BSPWM Custom' en LightDM para comenzar."
