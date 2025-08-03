# 🌐 Ginie Sovereign Stack – Full Agentbasert Autoinstallerende System

Dette prosjektet inneholder en fullstendig spesifikasjon for GinieSystem, et agentbasert operativsystem med selvinstallerende mekanismer, autonom dokumentasjon, testing og feilretting.

## 🎯 Mål

1. **Opprette og deployere egne GPT‑agenter** automatisk.
2. **Utføre all dokumentasjon, testing, feilretting og optimalisering** uten brukerinngrep.
3. **Tilpasse seg fysisk maskinvare og operativsystem** automatisk (Linux, macOS, Raspberry Pi).
4. **Kjøre full autonomi i bakgrunnsmodus**, med én enkel bekreftelse: `ja til alt`.
5. **Klar til bruk** på Mac, Linux, Pi og tilkoblet fysisk node/USB.

## 📦 Agentstruktur og roller

```yaml
- G.Boot:
    rolle: Initierer hele stacken
    funksjon: OS‑deteksjon, opprettelse av grunnmapper, starter AgentLoop

- G.Installer:
    rolle: OS‑avhengig installasjonsmotor
    funksjon: Henter riktig pakke (apt, brew, pacman, nix)

- G.AgentLoop:
    rolle: Løpende aktivering og trening av GPT‑er
    funksjon: Henter prompts, agentroller, API‑nøkler og logger

- G.Doc:
    rolle: Dokumenterer hele oppsettet kontinuerlig
    funksjon: Skriver README.md, INSTALL.sh, SYSTEMMAP.md og Q&A

- G.Tester:
    rolle: Tester alle systemmoduler
    funksjon: Kjører testskript, verifiserer resultater, lagrer logg

- G.Fixer:
    rolle: Hvis G.Tester feiler
    funksjon: Retter dependency‑problemer, feil path, feil moduler

- G.Finisher:
    rolle: Kjører siste validering før produksjon
    funksjon: Lag snapshot, generer QR‑kode, ZIP og backup

- G.UIQR:
    rolle: Lager interaktiv QR‑meny eller terminalmeny for valg av modus
    funksjon: Brukeren kan si "ja til alt" eller velge modulvis oppsett
```

## 🔁 Oppstartsskript (autodetekterende agentmodus)

Filen `Scripts/g_boot.sh` er et Bash‑skript som detekterer operativsystemet, oppretter grunnleggende mappestruktur og starter agentloopen.

## ⚙️ Installeringsmodul (G.Installer)

Filen `Scripts/g_installer.sh` inneholder OS‑spesifikk installasjonslogikk. Den bruker `apt`, `pacman` eller `brew` avhengig av hvilket system skriptet kjører på.

## 🧠 Eksempel: GPT‑agent registrering og auto‑oppsett (G.AgentLoop)

Filen `Scripts/g_agentloop.sh` inspiserer `~/GinieSystem/Agents` for å finne agentdefinisjoner (JSON‑filer). Hvis tilhørende skript mangler, kaller den G.Fixer, ellers aktiverer agenten.

## ✅ Bekreftelseskommando: «ja til alt»

Når hovedskriptet kjøres, kan brukeren skrive `ja til alt` for å initiere full installasjon, dokumentasjon, testing, feilretting, generering av QR/ZIP og backup.

## 📤 Distribusjon og aktivering

Systemet kan pakkes som ZIP med QR‑kode og distribueres via USB eller nettverk. Ved oppstart detekteres systemet og en meny vises (via G.UIQR) hvor man kan godkjenne full installasjon eller velge modulvis oppsett.

## 📜 GinieSystem Etisk Grunnlov

Se filen `ethics.yaml` for et forslag til etisk grunnlov for GinieSystem.

## 🛠 Filer

Denne pakken inneholder følgende filer og kataloger:

| Fil/katalog | Beskrivelse |
| ----------- | ----------- |
| `Scripts/g_boot.sh` | Oppstartsskriptet som detekterer OS, oppretter mapper og starter AgentLoop. |
| `Scripts/g_installer.sh` | OS‑spesifikk installasjonsmodul. |
| `Scripts/g_agentloop.sh` | Agentloopen som starter og overvåker GPT‑agenter. |
| `Scripts/g_walkmodes.sh` | Plug‑and‑play installasjon av WalkModes og Weathernet. |
| `master_init.sh` | QWERTY master init‑skript for full systemstart med watchdogs og auto‑reparasjon. |
| `ethics.yaml` | Etisk grunnlov for GinieSystem. |
| `Agents/earn_core/earn_core.yaml` | Spesifikasjon for agenten `earn.core`, som identifiserer og utfører ikke‑skattepliktig verdiøkning. |

## 📦 Bruk

For å starte installasjonen manuelt:

```bash
cd ginie_auto_deploy_package
bash Scripts/g_boot.sh
```

Den komplette pakken kan legges i et GitHub‑repository og distribueres til en fysisk node eller kjøres direkte på en enhet. Husk å sette kjørbarheten (chmod +x) på skriptene før du kjører dem.