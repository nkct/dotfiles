#!/bin/bash
cd "$(dirname "$0")"
source ".env"
echo "Installing dotfiles from $DOTFILES_DIR"

cat << EOF >> "$HOME/.bashrc"

# ! DOTFILES BEGIN !
# dotfiles installed on $(date -u +"%Y-%m-%d"), from $(git remote get-url origin) #$(git rev-parse --short HEAD)
source "$DOTFILES_DIR/.env"
EOF
cat << 'EOF' >> "$HOME/.bashrc"
if [ -d $DOTFILES_DIR ]; then
  . "$DOTFILES_DIR/.env"
  . "$DOTFILES_DIR/.aliases"
else
  printf "\e[33mWARN: %s\e[0m\n" "Could not find dotfiles directory at '$DOTFILES_DIR'"
fi
# ! DOTFILES END !
EOF
echo "Remember to source $HOME/.bashrc"

ln -s "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
ln -s "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -s "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"

mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.ssh/sessions"
chmod 700 "$HOME/.ssh" 
find "$DOTFILES_DIR/.ssh" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' f; do
  ln -s "$f" "$HOME/.ssh/$(basename "$f")"
done

