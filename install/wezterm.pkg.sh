_DEPS=("sudo" "curl" "apt" "gpg")

info() {
  echo "wezterm - Wez's Terminal Emulator [Linux Debian]"
  echo "Adds WezTerm sources and installs as apt package."
  echo "Reference: https://wezterm.org/install/linux.html#using-the-apt-repo"
}

install() {
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
  sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
  sudo apt update
  sudo apt install wezterm -y

  ln -s "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
}

