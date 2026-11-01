# better-hermes

Las ideas de [better-claude](https://github.com/midudev/better-claude), adaptadas a **Hermes Agent**.
Cada adaptación vive en su propio repo, para que se pueda instalar sola y tener su entrada en el
catálogo de plugins de Hermes.

Este repo es el **menú**: aquí está el mapa y el criterio. No hay código.

## Adaptaciones

| Pieza | Repo | Estado |
|---|---|---|
| **Quick Peek** — las rutas de una respuesta se vuelven ficheros que puedes ver y abrir | [`better-peek`](https://github.com/riverosmejia/better-peek) · `v0.1.0` | **Hecho.** `/peek`, widget del TUI y, opcional, un parche para el ratón. |
| **Commit** — `/commit` en Conventional Commits | — | Siguiente. Cabe como comando de plugin que devuelve el prompt: la adaptación más pequeña. |
| **Narrator** — leer en voz alta lo que hizo el turno | — | Candidato. `post_llm_call` + un motor de voz del sistema; hoy no hay ninguno instalado. |
| **Time Machine** — snapshot por turno y `/timeline` | — | Parcial por diseño: Hermes ya trae checkpoints, `/undo` y rewind. Falta cobertura de cambios por Bash y la vista de ramas. |
| **Token Meter** / **Context Meter** | — | No hace falta: la barra de estado del TUI ya muestra modelo, contexto, latencia y tokens/s. |
| **Sub Meter** — ventanas 5h/semanal de la suscripción | — | Depende del proveedor: sin uno que publique ventanas, no hay nada que dibujar. |
| **After** — cola de prompts | — | A revisar: el TUI ya encola lo que escribes mientras el agente trabaja. |
| **Use Haiku** / **Think Hard** — prefijos para un turno | — | Necesitan middleware de request; ya existen `/model` y `/reasoning`. |
| **Image Preview** — hover sobre `[Image #N]` | — | No portable sin tocar el compositor del TUI: el hover vive en el motor, no en un plugin. |

Si algo no está en esta tabla, no está adaptado. Lo que se añada, se añade con su fila y su repo.

## Instalar

```bash
hermes plugins install riverosmejia/better-peek --enable     # desde GitHub, sin clonar a mano
```

O, para tener también el widget y los parches opcionales:

```bash
git clone git@github.com:riverosmejia/better-peek.git
cd better-peek && ./install.sh
```

Cada repo explica lo suyo: requisitos, qué toca y qué no, y cómo se desinstala.

## Cómo se adapta una pieza

1. **¿Existe ya en Hermes?** Si sí, no se porta: se dice en la tabla y se pasa a la siguiente.
2. **¿Cabe en un plugin?** Comandos (`ctx.register_command`) y hooks (`post_llm_call`, `pre_tool_call`…).
   Funciona en el CLI, en el TUI, por SSH y en el gateway.
3. **¿Necesita una superficie propia en el TUI?** Un widget en `tui-widgets/` (modal o dock). Solo
   recibe teclado, no ratón.
4. **¿Vive dentro de un mensaje?** Entonces es un parche de `ui-tui`, con su `apply.sh` idempotente y
   su reversión documentada. Es la única categoría que modifica Hermes por dentro.

Una adaptación por repo, un `plugin.json` en la raíz (Agent Plugins v1) junto al `plugin.yaml` nativo:
así `hermes plugins install owner/repo` funciona y el catálogo puede fijar un commit.

## Origen

Nace de [better-claude](https://github.com/midudev/better-claude) de **midudev**. Este repo empezó
siendo un fork suyo con los once plugins; su estado congelado está en el tag local
`origen-better-claude`, y lo que se adaptó vive ahora en los repos de arriba.

## Licencia

MIT © Miguel Ángel Durán (midudev) y riverosmejia. Ver [LICENSE](LICENSE).
