#! /usr/bin/env bash

sudo pacman -Syu
sudo pacman -S neovim ripgrep wl-clipboard npm
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
