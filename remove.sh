cd "$HOME"

rm .wezterm.lua .vimrc .gitignore_global .gitconfig
rm -r .ssh/sessions
rm "$HOME/.local/bin/editor-wrapper"

sed -i '/# ! DOTFILES BEGIN !/,/# ! DOTFILES END !/d' ~/.bashrc

