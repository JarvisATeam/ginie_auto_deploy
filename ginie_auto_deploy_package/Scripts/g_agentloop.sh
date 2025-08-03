#!/bin/bash
# GinieSystem – G.AgentLoop
# Løkke som kontinuerlig skanner agentkatalogen og starter agenter.

while true; do
    for agent in $(ls ~/GinieSystem/Agents/*.gpt.json 2>/dev/null); do
        name=$(jq -r .name "$agent")
        role=$(jq -r .role "$agent")
        script=$(jq -r .script "$agent")

        # Fjern eventuelle anførselstegn rundt stien
        script_path="~/GinieSystem/Scripts/$script"

        if [[ ! -f $script_path ]]; then
            echo "🔍 Mangler $script – G.Fixer kobles inn"
            if [ -x "~/GinieSystem/Scripts/g_fixer.sh" ]; then
              bash ~/GinieSystem/Scripts/g_fixer.sh "$script"
            else
              echo "⚠️  g_fixer.sh mangler. Kan ikke reparere $script."
            fi
        fi
        echo "✅ Agent $name ($role) aktivert"
        if [[ -x $script_path ]]; then
          bash "$script_path" &
        fi
    done
    sleep 15
done