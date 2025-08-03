#!/bin/bash
# GinieSystem – Master Init Script (QWERTY)
# Full system init med selvreparasjon og agent‑boot.

# 🌍 DETEKTER OPERATIVSYSTEM
OS=$(uname)
echo "[QWERTY] Initierer GinieSystem på: $OS"

# 🧱 LAST INN VAULT‑TOKENS OG NØKKELFIL
TOKEN_FILE="~/VaultDrive/vault_tokens.yaml"
if [[ -f "$TOKEN_FILE" ]]; then
    echo "[QWERTY] Henter tokens fra Vault..."
    # shellcheck source=/dev/null
    source "$TOKEN_FILE"
else
    echo "[QWERTY] Advarsel: Tokens ikke funnet. Bruker dummy‑mode."
fi

# ⚙️ AKTIVER AGENTER
AGENTS=(G.ORACLE G.LÆRLING G.WATCHDOG G.AVATAR G.ACTIVATOR)
echo "[QWERTY] Starter kjernekode for agentene..."
for agent in "${AGENTS[@]}"; do
    if [[ -f "~/GinieSystem/Agents/$agent/launch.sh" ]]; then
        bash "~/GinieSystem/Agents/$agent/launch.sh" &
        echo "[QWERTY] ➤ $agent startet."
    else
        echo "[QWERTY] ⚠️  $agent mangler launch.sh. Forsøker fallback."
    fi
done

# 🔁 KJØR AUTO‑REPAIR VED MANGLENDE KOMPONENTER
if [[ -f "~/GinieSystem/Repair/auto_repair.sh" ]]; then
    bash ~/GinieSystem/Repair/auto_repair.sh
    echo "[QWERTY] Auto‑repair kjørt."
else
    echo "[QWERTY] ⚠️  Auto‑repair‑script mangler."
fi

# 🧭 START OVERVÅKING (30s‑regel + avatar + strøm)
bash ~/GinieSystem/Watchdog/battery_watch.sh &
bash ~/GinieSystem/Watchdog/sleep_guard.sh &
bash ~/GinieSystem/Avatar/avatar_loop.sh &
echo "[QWERTY] Watchdog og Avatar aktivert."

# 📚 LAG LOGG
mkdir -p ~/GinieSystem/Logs/
echo "[QWERTY] $(date '+%Y-%m-%d %H:%M:%S') – INIT FULLFØRT" >> ~/GinieSystem/Logs/QWERTY_HEARTBEAT.log

# 🟢 SYSTEMET ER KLART
clear
cat <<'BANNER'
███████╗██╗███╗   ██╗██╗███████╗██╗   ██╗███████╗████████╗
██╔════╝██║████╗  ██║██║██╔════╝██║   ██║██╔════╝╚══██╔══╝
█████╗  ██║██╔██╗ ██║██║█████╗  ██║   ██║███████╗   ██║   
██╔══╝  ██║██║╚██╗██║██║██╔══╝  ██║   ██║╚════██║   ██║   
██║     ██║██║ ╚████║██║███████╗╚██████╔╝███████║   ██║   
╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚══════╝ ╚═════╝ ╚══════╝   ╚═╝   
BANNER
echo "[QWERTY] 🧠 GinieSystem klar. Alle kjerner aktive."
echo "[QWERTY] 🔁 Kontinuerlig drift overvåkes. Si 'Status kaptein' når som helst."