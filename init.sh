git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
sudo chown -R $(whoami) ~/.local/state/nvim
if [ ! -d ~/.local/share/nvim/swap ]; then
    mkdir ~/.local/share/nvim/swap 
fi
sudo chown -R $(whoami) ~/.local/share/nvim/swap
go install golang.org/x/tools/gopls@latest
