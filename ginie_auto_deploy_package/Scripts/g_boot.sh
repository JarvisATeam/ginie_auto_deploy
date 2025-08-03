#!/bin/bash
# GinieSystem – G.Boot
# Dette skriptet detekterer operativsystem og arkitektur,
# oppretter grunnleggende mappestruktur i ~/GinieSystem og starter G.AgentLoop.
set -e

echo "\n🔍 Sjekker operativsystem og maskinvare..."
OS="$(uname -s)"
ARCH="$(uname -m)"
PLATFORM="$(uname -o 2>/dev/null || echo 'unknown')"

case $OS in
  Linux)
    PKG="apt"
    # Hvis pacman finnes, bruk pacman istedenfor apt
    [ -x "$(command -v pacman)" ] && PKG="pacman"
    ;;
  Darwin)
    PKG="brew"
    ;;
  *)
    echo "❌ Ikke-støttet OS: $OS" && exit 1
    ;;
esac

# === MAPPESTRUKTUR ===
mkdir -p ~/GinieSystem/{Scripts,Agents,Logs,QR,Vault,Snapshots,Installers}

# === AGENTLOOP ===
echo "🚀 Starter G.AgentLoop"
if [ -x "~/GinieSystem/Scripts/g_agentloop.sh" ]; then
  bash ~/GinieSystem/Scripts/g_agentloop.sh &
else
  echo "⚠️  g_agentloop.sh ikke funnet eller ikke kjørbar."
fi

# === INIT ===
echo "✅ Init fullført. Skriv \"ja til alt\" eller \"agentvis valg\""