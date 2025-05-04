#!/bin/bash

# Actualiza el sistema
sudo apt update && sudo apt upgrade -y

# Instala Xorg y utilidades básicas
sudo apt install -y xorg xinit git curl wget unzip locales

# Configura el teclado a español
sudo localectl set-x11-keymap es

# Instala los componentes principales
sudo apt install -y bspwm sxhkd kitty tmux rofi feh picom polybar zsh neovim python3-pip

# Instala dependencias para Neovim (LSP, Treesitter, Telescope, Startify)
pip3 install pynvim
nvim --headless "+Lazy! sync" +qa # Prepara Lazy.nvim si lo usas

# Instala Pywal y Starship
sudo apt install -y python3-pywal
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Instala fm6000 (fetch)
wget https://github.com/6n4k0n/fm6000/releases/latest/download/fm6000-linux-amd64 -O ~/fm6000
chmod +x ~/fm6000
sudo mv ~/fm6000 /usr/local/bin/

# Cambia la shell a zsh
chsh -s $(which zsh)

# Crea las carpetas de configuración
mkdir -p ~/.config/{bspwm,sxhkd,kitty,polybar,picom,rofi,tmux,starship,neovim,wal}

# Copia archivos de configuración de ejemplo
cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc
cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc

# Haz ejecutable el archivo bspwmrc
chmod +x ~/.config/bspwm/bspwmrc

# Configuración básica de picom y polybar (puedes personalizar después)
echo -e "[general]\nbackend = \"glx\"\nvsync = true\n" > ~/.config/picom/picom.conf
echo -e "[bar/example]\nwidth = 100%\nheight = 24\nmodules-center = date\n" > ~/.config/polybar/config.ini

# Configuración básica de kitty
echo -e "font_family      FiraCode\nfont_size        11.0\n" > ~/.config/kitty/kitty.conf

# Configuración básica de tmux
echo -e "set -g mouse on\nset -g history-limit 10000\n" > ~/.config/tmux/tmux.conf

# Configuración básica de starship
echo '[character]\nsuccess_symbol = "[➜](bold green)"\n' > ~/.config/starship.toml

# Configuración básica de rofi
echo -e "rofi.theme: ~/.cache/wal/colors-rofi-dark.rasi\n" > ~/.config/rofi/config.rasi

# Configuración de fondo de pantalla con feh y pywal
wal -i /usr/share/backgrounds/xfce/xfce-blue.jpg # Cambia por tu fondo preferido

# Añade al bspwmrc el autostart de sxhkd, picom, polybar, feh y pywal
cat << 'EOF' >> ~/.config/bspwm/bspwmrc

# Lanzar sxhkd para atajos
sxhkd &

# Lanzar compositor picom
picom --config ~/.config/picom/picom.conf &

# Lanzar polybar
polybar example &

# Aplicar colores de pywal y fondo
[[ -f "$HOME/.cache/wal/colors.sh" ]] && source "$HOME/.cache/wal/colors.sh"
feh --bg-scale "$(< ~/.cache/wal/wal)" &

EOF

# Configuración básica de Neovim (init.lua)
mkdir -p ~/.config/nvim
cat << 'EOF' > ~/.config/nvim/init.lua
vim.cmd [[colorscheme onedark]]
require('telescope').setup{}
require('nvim-treesitter.configs').setup { highlight = { enable = true } }
require('lspconfig').pyright.setup{}
vim.g.startify_custom_header = { 'Minimalista listo!' }
EOF

echo "Instalación completada. Reinicia tu sesión gráfica o ejecuta 'startx' para iniciar bspwm."
echo "Personaliza tus atajos en ~/.config/sxhkd/sxhkdrc y tus temas con Pywal."
