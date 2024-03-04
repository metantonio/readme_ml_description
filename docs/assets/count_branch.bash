#!/bin/bash

# Especifica la rama destino del pull request
rama_destino="main"

# Obtiene todas las ramas del repositorio
ramas=$(git branch --format='%(refname:short)')

# Recorre todas las ramas y busca los pull requests hacia la rama destino
for rama in $ramas; do
    if [ "$rama" != "$rama_destino" ]; then
        count=$(git log --merges --oneline --no-merges $rama..$rama_destino | grep -i "pull request" | wc -l)
        echo "Rama: $rama - Pull Requests: $count"
    fi
done
