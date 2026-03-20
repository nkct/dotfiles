
source .env

cat << EOF >> ~/.bashrc

# dotfiles installed on $(date -u +"%Y%m%dT%H%M%SZ"), based on commit $(git rev-parse HEAD)
source "$DOTFILES_DIR/.env"
EOF
cat << 'EOF' >> ~/.bashrc
if [ -d $DOTFILES_DIR ]; then
  . $DOTFILES_DIR/.env
  . $DOTFILES_DIR/.aliases
  ln -s ~/.vimrc $DOTFILES_DIR/.vimrc
else
  printf "\e[33mWARN: %s\e[0m\n" "Could not find dotfiles directory at '$DOTFILES_DIR'"
fi
EOF

