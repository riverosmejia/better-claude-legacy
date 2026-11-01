# better-hermes

Rutas, vistas previas y atajos para **Hermes Agent**, en el terminal.

En una respuesta de Hermes los ficheros aparecen como texto: `/home/tu/proyecto/src/app.ts:42` es
algo que hay que copiar a mano y buscar. Aqui cada ruta que existe de verdad se vuelve un enlace:
pasa el raton y ves sus lineas en una tarjeta, haz clic y se abre el fichero dentro del propio TUI.
Y con `/peek`, lo mismo sin raton, desde cualquier superficie, tambien por SSH.

```
  El bug esta en src/app.ts:42 y en el lockfile      <- raton: tarjeta con las lineas
                                                        clic: el fichero en el TUI
```

## Que incluye

| Pieza | Que hace | Donde vive |
|---|---|---|
| **better-peek** (plugin) | `/peek` lista las rutas de la ultima respuesta y muestra un fichero con las lineas numeradas y la que nombra el enlace marcada. Funciona en el CLI, en el TUI y por SSH, sin raton. | [`plugins/better-peek/`](plugins/better-peek/) |
| **better-peek** (widget) | Modal del TUI: `/better-peek` abre la lista, flechas para elegir, Enter abre el fichero, `c` copia `ruta:linea`, Esc cierra. | [`tui-widgets/better-peek.mjs`](tui-widgets/better-peek.mjs) |
| **parches del TUI** | Las rutas del transcript como enlaces: resaltado al pasar el raton, tarjeta con el fichero en la esquina, clic para abrirlo en el visor. | [`patches/`](patches/) |

## Instalar

Requisitos: Hermes Agent instalado (`~/.hermes/hermes-agent`), `python3` y el TUI construido una vez
(`hermes --tui`). Nada mas: ni dependencias de Python, ni de sistema.

```bash
git clone git@github.com:riverosmejia/better-hermes.git
cd better-hermes

./install.sh              # plugin + widget: enlaza, habilita y verifica
./patches/apply.sh        # opcional: rutas enlazadas y tarjeta al pasar el raton
```

`install.sh` es idempotente: corre los tests, enlaza `~/.hermes/plugins/better-peek` y
`~/.hermes/tui-widgets/better-peek.mjs`, habilita el plugin y pasa `hermes plugins doctor`.
`--check` solo comprueba, sin tocar nada.

`apply.sh` aplica los parches de `ui-tui` con `patch --fuzz=3` y reconstruye el TUI (ink incluido).
Tambien es idempotente y acepta `--check`. Los parches son la unica parte que toca Hermes por dentro:
el resto son un plugin y un widget, que Hermes carga sin modificar nada.

## Uso

```text
/peek                     las rutas de la ultima respuesta, numeradas
/peek 2                   esa, con sus lineas y la que nombra marcada
/peek src/app.ts:42       una ruta concreta, aunque no saliera en la respuesta
/better-peek              el modal del TUI (flechas, Enter, c, esc)
```

Con los parches puestos, ademas: el raton sobre una ruta la resalta y abre su tarjeta, y el clic
muestra el fichero en el visor del TUI. Si prefieres que el clic abra un editor, dilo con
`PEEK_OPEN`, que se ejecuta con `{file}` y `{line}` sustituidos y la ruta entrecomillada:

```bash
PEEK_OPEN='tmux new-window nano {file} +{line}' hermes --tui
PEEK_OPEN='code -g {file}:{line}' hermes --tui
```

El hover necesita el raton del terminal (`display.mouse_tracking` en `all`, que es el valor por
defecto) y no funciona dentro de tmux con el modo `wheel`, que existe justamente para que el raton
no ensucie el prompt. Sin hover, el clic y `/peek` siguen funcionando.

## Que NO hace

- No abre ventanas ni aplicaciones graficas: todo se dibuja en el terminal.
- No toca ficheros: lee lo que el modelo nombro, si existe.
- Un `file://` escrito por el modelo no dispara nada: los enlaces de ruta usan un esquema propio
  (`hermes-peek://`) que solo fabrica el renderer, y la ruta tiene que existir en esta maquina.

## Origen

Nace de [better-claude](https://github.com/midudev/better-claude) de **midudev**, en concreto de su
plugin *quick-peek*: las reglas para encontrar rutas en un texto, resolverlas y sacar las lineas de
un fichero son un port de su `hooks/paths.ts` y `hooks/code.ts`, y sus casos de test son el contrato
de este port. Licencia MIT, la misma de arriba.

## Licencia

MIT (c) Miguel Angel Duran (midudev) y riverosmejia. Ver [LICENSE](LICENSE).
