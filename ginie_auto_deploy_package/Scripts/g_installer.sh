#!/bin/bash
# GinieSystem – G.Installer
# Dette skriptet installerer nødvendige pakker basert på oppdaget pakkesystem.
set -e

case $PKG in
  apt)
    sudo apt update && sudo apt install -y git python3 python3-pip unzip
    ;;
  pacman)
    sudo pacman -Syu --noconfirm git python unzip
    ;;
  brew)
    brew install git python unzip
    ;;
  *)
    echo "❌ Ustøttet pakkesystem: $PKG"
    ;;
esac