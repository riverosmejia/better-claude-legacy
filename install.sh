#!/usr/bin/env bash
# Instala better-peek en el Hermes de este usuario: plugin (/peek) y widget del TUI (/better-peek).
# Idempotente: enlaza, no copia, así que editar en el repo se ve al instante. No toca nada más.
#
#   ./install.sh            instala y comprueba
#   ./install.sh --check    solo comprueba (no cambia nada)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
PLUGIN_SRC="$HERE/plugins/better-peek"
WIDGET_SRC="$HERE/tui-widgets/better-peek.mjs"
CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

fail() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

[ -f "$PLUGIN_SRC/plugin.yaml" ] || fail "no encuentro $PLUGIN_SRC/plugin.yaml"
[ -f "$WIDGET_SRC" ] || fail "no encuentro $WIDGET_SRC"

HERMES="$(command -v hermes || true)"
[ -n "$HERMES" ] || HERMES="$HERMES_HOME/hermes-agent/venv/bin/hermes"
[ -x "$HERMES" ] || fail "no encuentro el binario de hermes (PATH ni $HERMES_HOME/hermes-agent/venv/bin)"

printf 'repo:         %s\n' "$HERE"
printf 'hermes home:  %s\n' "$HERMES_HOME"
printf 'hermes:       %s\n' "$HERMES"
"$HERMES" --version 2>&1 | head -1
printf 'python:       %s\n' "$(python3 --version 2>&1)"

printf '\ntests de la lógica\n'
python3 -m unittest discover -s "$PLUGIN_SRC/tests" -q

if [ "$CHECK_ONLY" = 0 ]; then
  printf '\nenlazando\n'
  mkdir -p "$HERMES_HOME/plugins" "$HERMES_HOME/tui-widgets"
  ln -sfn "$PLUGIN_SRC" "$HERMES_HOME/plugins/better-peek"
  ln -sfn "$WIDGET_SRC" "$HERMES_HOME/tui-widgets/better-peek.mjs"
  printf '  %s -> %s\n' "$HERMES_HOME/plugins/better-peek" "$PLUGIN_SRC"
  printf '  %s -> %s\n' "$HERMES_HOME/tui-widgets/better-peek.mjs" "$WIDGET_SRC"

  printf '\nhabilitando el plugin\n'
  "$HERMES" plugins enable better-peek 2>&1 | tail -3
fi

printf '\ncomprobación\n'
"$HERMES" plugins doctor better-peek 2>&1 | tail -4
ls -l "$HERMES_HOME/plugins/better-peek" "$HERMES_HOME/tui-widgets/better-peek.mjs"

printf '\nlisto. Para probarlo:\n'
printf '  %s chat -q "/peek /etc/os-release"     (sin modelo, imprime la tarjeta)\n' "$HERMES"
printf '  %s --tui   y luego  /better-peek ⏎      (modal con ↑↓ ⏎ c)\n' "$HERMES"
