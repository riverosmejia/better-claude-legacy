# better-hermes

Las ideas de [better-claude](https://github.com/midudev/better-claude), adaptadas a **Hermes Agent** y
al terminal.

Hermes no da ninguna costura para que un plugin dibuje dentro de un mensaje, así que cada adaptación
usa la superficie que sí existe: un **plugin** (comandos y hooks), un **widget**
(`~/.hermes/tui-widgets`) o, cuando la función vive en el transcript, un **parche** de `ui-tui`. Cada
una dice en su README cuál de las tres usa y por qué.

## Estado de las adaptaciones

| Pieza de better-claude | Aquí | Estado |
|---|---|---|
| **Quick Peek** — rutas clicables en las respuestas | [`plugins/better-peek/`](plugins/better-peek/) + [`tui-widgets/better-peek.mjs`](tui-widgets/better-peek.mjs) + [`patches/`](patches/) | **Hecho.** `/peek` lista las rutas de la última respuesta y muestra un fichero; el widget las navega; con los parches, el ratón resalta la ruta, abre su tarjeta y el clic muestra el fichero en el visor. |
| **Commit** — `/commit` en Conventional Commits | — | Siguiente. En Hermes cabe como comando de plugin que devuelve el prompt; es la adaptación más pequeña. |
| **Narrator** — leer en voz alta lo que hizo el turno | — | Candidato. `post_llm_call` + un motor de voz del sistema; hoy no hay ninguno instalado en las máquinas. |
| **Time Machine** — snapshot por turno y `/timeline` | — | Parcial por diseño: Hermes ya trae checkpoints, `/undo` y rewind para lo que editan sus herramientas. Lo que falta es cobertura de cambios por Bash y la vista de ramas. |
| **Token Meter** / **Context Meter** | — | No hace falta: la barra de estado del TUI ya muestra modelo, barra de contexto con porcentaje, latencia y tokens/s. |
| **Sub Meter** — ventanas 5h/semanal de la suscripción | — | Depende del proveedor: sin uno que publique ventanas, no hay nada que dibujar. |
| **After** — cola de prompts | — | A revisar: el TUI ya encola lo que escribes mientras el agente trabaja; la diferencia es la cola explícita y reordenable. |
| **Use Haiku** / **Think Hard** — prefijos para un turno | — | Necesitan middleware de request. En Hermes ya existen `/model` y `/reasoning`; valor bajo salvo que se echen de menos. |
| **Image Preview** — hover sobre `[Image #N]` | — | No portable sin tocar el compositor del TUI: el hover vive en el motor, no en un plugin. |

Esta tabla es el mapa: si algo no está aquí, no está adaptado. Lo que se añada, se añade con su fila.

## Instalar

Requisitos: Hermes Agent instalado (`~/.hermes/hermes-agent`), `python3` y el TUI construido una vez
(`hermes --tui`). Nada más: ni dependencias de Python ni de sistema.

```bash
git clone git@github.com:riverosmejia/better-hermes.git
cd better-hermes

./install.sh              # todos los plugins y widgets: enlaza, habilita y verifica
./patches/apply.sh        # opcional: lo que vive en el transcript (hoy, las rutas enlazadas)
```

`install.sh` recorre `plugins/*` y `tui-widgets/*.mjs`, enlaza cada uno en `~/.hermes`, habilita cada
plugin y pasa `hermes plugins doctor`. Es idempotente y acepta `--check`, que solo comprueba sin tocar
nada. Cuando haya más adaptaciones se instalan solas: no hay que editar el script.

`patches/apply.sh` aplica el diff de `ui-tui` con `patch --fuzz=3` y reconstruye el TUI (ink
incluido). También es idempotente, acepta `--check` y `--no-build`.

## Uso

Lo que ya funciona:

```text
/peek                     las rutas de la última respuesta, numeradas
/peek 2                   esa, con sus líneas y la que nombra marcada
/peek src/app.ts:42       una ruta concreta, aunque no saliera en la respuesta
/better-peek              el modal del TUI (flechas, Enter, c para copiar, Esc)
```

Con los parches puestos, además: el ratón sobre una ruta la resalta y abre su tarjeta, y el clic
muestra el fichero en el visor del TUI. Si prefieres que el clic abra un editor, dilo con
`PEEK_OPEN`, que se ejecuta con `{file}` y `{line}` sustituidos y la ruta entrecomillada:

```bash
PEEK_OPEN='tmux new-window nano {file} +{line}' hermes --tui
PEEK_OPEN='code -g {file}:{line}' hermes --tui
```

El hover necesita el ratón del terminal (`display.mouse_tracking` en `all`, el valor por defecto) y
no funciona en tmux con el modo `wheel`, que existe justamente para que el ratón no ensucie el prompt.
Sin hover, el clic y `/peek` siguen funcionando.

## Cómo se adapta una pieza

1. **¿Existe ya en Hermes?** Si sí, no se porta: se dice en la tabla y se pasa a la siguiente.
2. **¿Cabe en un plugin?** Comandos (`ctx.register_command`) y hooks (`post_llm_call`, `pre_tool_call`…).
   Vive en `plugins/<nombre>/` y funciona en el CLI, en el TUI, por SSH y en el gateway.
3. **¿Necesita una superficie propia en el TUI?** Un widget en `tui-widgets/<nombre>.mjs` (modal o
   dock). Solo recibe teclado, no ratón.
4. **¿Vive dentro de un mensaje?** Entonces es parche de `ui-tui`, va en `patches/` y se aplica con
   `apply.sh`. Es la única parte que toca Hermes por dentro.

## Qué no hace

- No abre ventanas ni aplicaciones gráficas: todo se dibuja en el terminal.
- No toca ficheros: lee lo que el modelo nombró, si existe.
- Un `file://` escrito por el modelo no dispara nada: los enlaces de ruta usan un esquema propio
  (`hermes-peek://`) que solo fabrica el renderer, y la ruta tiene que existir en esta máquina.

## Origen

Nace de [better-claude](https://github.com/midudev/better-claude) de **midudev**. Las reglas para
encontrar rutas en un texto, resolverlas y sacar las líneas de un fichero son un port de su
`hooks/paths.ts` y `hooks/code.ts`, y sus casos de test son el contrato de ese port. Licencia MIT, la
misma de arriba.

## Licencia

MIT © Miguel Ángel Durán (midudev) y riverosmejia. Ver [LICENSE](LICENSE).
