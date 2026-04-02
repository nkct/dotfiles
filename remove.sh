cd "$HOME"

rm .wezterm.lua .vimrc .gitignore_global .gitconfig
rm -r .ssh/sessions

sed -i '/# ! DOTFILES BEGIN !/,/# ! DOTFILES END !/d' ~/.bashrc

