#!/usr/bin/env bash
# Instala en el Hermes de este usuario lo que hay en plugins/ y en tui-widgets/.
#
#   ./install.sh            instala, habilita y comprueba
#   ./install.sh --check    solo comprueba (no cambia nada)
#
# Idempotente: enlaza, no copia, así que editar en el repo se ve al instante.
# Recorre el directorio, no una lista: una adaptación nueva se instala sola sin
# tocar este script.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

fail() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

shopt -s nullglob
PLUGINS=("$HERE"/plugins/*/)
WIDGETS=("$HERE"/tui-widgets/*.mjs)

[ ${#PLUGINS[@]} -gt 0 ] || fail "no hay nada en $HERE/plugins"
[ ${#WIDGETS[@]} -gt 0 ] || fail "no hay nada en $HERE/tui-widgets"

HERMES="$(command -v hermes || true)"
[ -n "$HERMES" ] || HERMES="$HERMES_HOME/hermes-agent/venv/bin/hermes"
[ -x "$HERMES" ] || fail "no encuentro el binario de hermes (PATH ni $HERMES_HOME/hermes-agent/venv/bin)"

printf 'repo:         %s\n' "$HERE"
printf 'hermes home:  %s\n' "$HERMES_HOME"
printf 'hermes:       %s\n' "$HERMES"
"$HERMES" --version 2>&1 | head -1
printf 'python:       %s\n' "$(python3 --version 2>&1)"
printf 'plugins:      %s\n' "$(for dir in "${PLUGINS[@]}"; do printf '%s ' "$(basename "$dir")"; done)"
printf 'widgets:      %s\n' "$(for file in "${WIDGETS[@]}"; do printf '%s ' "$(basename "$file")"; done)"

printf '\ntests de cada plugin\n'
for dir in "${PLUGINS[@]}"; do
  [ -d "$dir/tests" ] || continue
  printf '  %s ... ' "$(basename "$dir")"
  python3 -m unittest discover -s "$dir/tests" -q 2>&1 | tail -2 | tr '\n' ' '
  printf '\n'
done

if [ "$CHECK_ONLY" = 0 ]; then
  printf '\nenlazando\n'
  mkdir -p "$HERMES_HOME/plugins" "$HERMES_HOME/tui-widgets"

  for dir in "${PLUGINS[@]}"; do
    name="$(basename "$dir")"
    ln -sfn "${dir%/}" "$HERMES_HOME/plugins/$name"
    printf '  %s -> %s\n' "$HERMES_HOME/plugins/$name" "${dir%/}"
  done

  for file in "${WIDGETS[@]}"; do
    ln -sfn "$file" "$HERMES_HOME/tui-widgets/$(basename "$file")"
    printf '  %s -> %s\n' "$HERMES_HOME/tui-widgets/$(basename "$file")" "$file"
  done

  printf '\nhabilitando\n'
  for dir in "${PLUGINS[@]}"; do
    "$HERMES" plugins enable "$(basename "$dir")" 2>&1 | tail -2 | sed 's/^/  /'
  done
fi

printf '\ncomprobación\n'
for dir in "${PLUGINS[@]}"; do
  "$HERMES" plugins doctor "$(basename "$dir")" 2>&1 | tail -3
done
ls -l "$HERMES_HOME"/plugins/better-peek | sed 's/^/  /'
for file in "${WIDGETS[@]}"; do
  ls -l "$HERMES_HOME/tui-widgets/$(basename "$file")" | sed 's/^/  /'
done

printf '\nlisto. Para probar lo que hay:\n'
printf '  %s chat -q "/peek /etc/os-release"     (sin modelo, imprime la tarjeta)\n' "$HERMES"
printf '  %s --tui   y luego  /better-peek ⏎      (modal: flechas, Enter, c, esc)\n' "$HERMES"
