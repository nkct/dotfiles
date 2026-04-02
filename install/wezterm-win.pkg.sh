_DEPS=("wget" "powershell.exe")

info() {
  echo "wezterm - Wez's Terminal Emulator [Windows WSL]"
  echo "Downloads the installer and runs it via powershell."
  echo "Reference: https://wezterm.org/install/windows.html"
}

install() {
  TMP_PATH="/tmp/wezterm-win-setup.exe"
  WIN_DOWNLOADS="/mnt/c/Users/$(whoami)/Downloads"
  WIN_PATH="$WIN_DOWNLOADS/wezterm-win-setup.exe"

  wget 'https://github.com/wezterm/wezterm/releases/download/20240203-110809-5046fc22/WezTerm-20240203-110809-5046fc22-setup.exe' -o "$TMP_PATH"
  cp "$TMP_PATH" "$WIN_PATH"
  powershell.exe "$WIN_PATH"

  # install font
  cp "$DOTFILES_HOME/fonts/Noto_Sans_Mono/NotoSansMono-VariableFont_wdth,wght.ttf" "$WIN_DOWNLOADS/NotoSansMono.ttf"
  powershell.exe -Command "Copy-Item -Path 'C:\\Users\\$(whoami)\\Downloads\\NotoSansMono.ttf' -Destination 'C:\\Windows\\Fonts\\NotoSansMono.ttf'; $shell = New-Object -ComObject Shell.Application; $shell.Namespace('C:\\Windows\\Fonts').CopyHere('C:\\Windows\\Fonts\\NotoSansMono.ttf')"

  cp "$DOTFILES_DIR/.wezterm.lua" "/mnt/c/Program Files/WezTerm/wezterm.lua"
}

