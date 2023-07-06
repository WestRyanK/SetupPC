# Ryan's Easy PC Setup

This project allows me to quickly and easily set up a new computer with all the tools I normally use. It assumes I am starting from scratch with absolutely no tools installed on the system. 

# Instructions

1. Run Powershell as an **Administrator**.
2. Paste in the following line and run it.
```
Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/WestRyanK/SetupPC/main/setup.ps1 | Invoke-Expression
```

# Setup Contents
Like always, the following documentation will most likely get out of sync with what the script actually does. But this might still be useful...

The following tools are installed:
* Chocolatey
* Git
* Vim
* Powershell Core
* Microsoft Terminal
* AutoHotKey
* PowerToys
* Posh-Git

The following changes are made:
* Create a junction for "westryank" pointing to the current user directory. (Oftentimes the user directory is something like "rwest" or "westr", which I don't like)
* Create a repos folder at the root.
* Create a junction in the user directory pointing to my repos folder.
* Downloads an AutoHotKey script which does the following:
  * Binds Ctrl+Win+` to open a Terminal in quake mode.
  * Binds Shift+Win+` to open an elevated Terminal in quake mode.
  * Binds Capslock to the right arrow in Powershell to easily autocomplete.
* Auto run the AutoHotKey script on startup.
* Set Windows to dark mode.
* Downloads my _vimrc to customize vim.
