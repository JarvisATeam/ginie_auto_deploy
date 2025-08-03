#!/bin/bash
# GinieSystem – WalkModes Plug‑and‑Play Installer
# Installerer WalkModes, Weathernet, Siri Shortcuts, Bluetooth‑lås og cache.
set -e

GINIE="$HOME/GinieSystem"
CORE="$GINIE/Core"
DATA="$GINIE/Data/Weathernet"
QR="$GINIE/QR"
SHORTCUTS="$GINIE/Shortcuts"
LOG="$GINIE/Logs/walkmode.log"
# Endre navnet på Bluetooth‑låsenhet om ønsket
BLUETOOTH_LOCK_DEVICE="Plantronics_Edge_457C"

echo -e "\n🚀 Starter FULL OPPSETT AV GINIE WALKMODES\n"

# === LAG MAPPESTRUKTUR ===
mkdir -p "$CORE" "$DATA/Nodes" "$DATA/Local" "$QR" "$SHORTCUTS" "$GINIE/Scripts" "$GINIE/Logs"

# === GENERER MODUSLOGIKK ===
cat > "$CORE/g.walkmode_status.sh" <<'EOF_STATUS'
#!/bin/bash
WALKMODE_FILE="${CORE}/.walkmode"
BLUETOOTH_LOCK_DEVICE="${BLUETOOTH_LOCK_DEVICE}"
MODE="$(cat "$WALKMODE_FILE" 2>/dev/null || echo "sun")"
case "$MODE" in
  sun) MODE_LABEL="☀️ SunWalk – Åpen og globalisert" ;;
  shadow) MODE_LABEL="⚫ ShadowWalk – Stealth og VPN" ;;
  night) MODE_LABEL="🌑 NightWalk – Offline og BT‑låst" ;;
  *) MODE="sun"; MODE_LABEL="☀️ SunWalk – Default" ;;
esac
echo "🔁 Aktiv modus: $MODE_LABEL"
EOF_STATUS
chmod +x "$CORE/g.walkmode_status.sh"

# === GENERER MODUSBYTTER ===
cat > "$GINIE/Scripts/g.switch_mode.sh" <<'EOF_SWITCH'
#!/bin/bash
WALKMODE_FILE="${CORE}/.walkmode"
MODE="$1"
if [[ "$MODE" != "sun" && "$MODE" != "shadow" && "$MODE" != "night" ]]; then
  echo "❌ Ugyldig modus. Bruk: sun, shadow, night"
  exit 1
fi
if [[ "$MODE" == "night" ]]; then
  echo "🔒 Verifiserer Bluetooth‑lås..."
  if system_profiler SPBluetoothDataType | grep -q "${BLUETOOTH_LOCK_DEVICE}"; then
    echo "✅ Låsenhet verifisert: ${BLUETOOTH_LOCK_DEVICE}"
  else
    echo "❌ Bluetooth‑lås ikke verifisert. Kan ikke aktivere NightWalk."
    exit 1
  fi
fi
echo "$MODE" > "$WALKMODE_FILE"
echo "✅ Modus endret til: $MODE"
EOF_SWITCH
chmod +x "$GINIE/Scripts/g.switch_mode.sh"

# === GENERER VÆR‑HER MODUL (kortversjon) ===
cat > "$GINIE/Scripts/g.weather_here.sh" <<'EOF_WEATHER'
#!/bin/bash
source "${CORE}/g.walkmode_status.sh"
if [[ "$MODE" == "night" ]]; then
  echo "🌑 NightWalk – henter cachet værdata fra lokal lagring..."
  cat "${DATA}/Local/last_known.json"
  exit 0
fi
# (API‑integrasjon for Sun/Shadow bygges ut etter behov)
EOF_WEATHER
chmod +x "$GINIE/Scripts/g.weather_here.sh"

# === GENERER SIMPLE SIRI SHORTCUT (manuell import via QR) ===
cat > "$SHORTCUTS/ginie_walkmode.shortcut.json" <<EOF_SHORTCUT
{
  "name": "Ginie – Aktiver WalkMode",
  "actions": [
    { "type": "Ask", "question": "Velg WalkMode", "options": ["SunWalk", "ShadowWalk", "NightWalk"] },
    { "type": "Run Script Over SSH", "host": "localhost", "username": "$USER", "script": "$GINIE/Scripts/g.switch_mode.sh [valgt]" }
  ]
}
EOF_SHORTCUT

# === GENERER README OG AUTOINSTRUKS ===
cat > "$GINIE/README_WALKMODES.md" <<EOF_README
# Ginie WalkModes – Kom i gang
1. Kjør `bash $GINIE/Scripts/g.switch_mode.sh sun|shadow|night` for å skifte modus
2. `g.weather_here.sh` viser været tilpasset modus
3. Importer Siri Shortcut fra $SHORTCUTS til iOS via QR (følger i mappen)
4. Bluetooth‑lås kreves for NightWalk (enhet: ${BLUETOOTH_LOCK_DEVICE})
EOF_README

# === AUTOINIT – Sett default modus til SunWalk første gang ===
echo "sun" > "$CORE/.walkmode"

echo -e "\n✅ WALKMODES installert i $GINIE\n"
echo "For å endre modus: bash $GINIE/Scripts/g.switch_mode.sh sun|shadow|night"
echo "For vær: bash $GINIE/Scripts/g.weather_here.sh"
echo "Shortcuts: Importer fra $SHORTCUTS/ginie_walkmode.shortcut.json til iOS"

echo -e "\n🟢 Alt klart. Ingen manuell filhenting nødvendig!\n"

exit 0