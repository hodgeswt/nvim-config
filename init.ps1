$packerPath = "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
git clone --depth 1 https://github.com/wbthomason/packer.nvim $packerPath

go install golang.org/x/tools/gopls@latest

nvim --headless -c 'PackerInstall' -c 'PackerSync'
