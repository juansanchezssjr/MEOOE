# My Stranger Eyes Alpha Edition

Proyecto de aventura 2D en Godot. Esta versión alpha contiene el mapa de Ohir, un
personaje controlable, personajes no jugadores, un ciclo de día y noche y una
interfaz básica de diálogo.

## Requisitos y ejecución

- Godot 4.7 o una versión compatible con la configuración del proyecto.
- No se requieren complementos ni dependencias externas.

Abre `project.godot` desde Godot y ejecuta el proyecto con **F5** (**Ejecutar
proyecto**). La escena principal configurada es `maps/ohirTown.tscn`.
`TEST.tscn` es una escena de pruebas que se puede ejecutar directamente con
**F6** (**Ejecutar escena actual**).

## Controles

- **Flechas**: mover al personaje (acciones predeterminadas `ui_up`,
  `ui_down`, `ui_left` y `ui_right` de Godot).
- **Enter/Espacio**: completar el texto actual o cerrar el cuadro de diálogo
  (acción predeterminada `ui_accept`).

## Estructura

| Ruta | Contenido |
| --- | --- |
| `project.godot` | Configuración, escena principal y autoloads. |
| `maps/` | Mapas del juego; `ohirTown.tscn` es el punto de entrada. |
| `characters/` | Escena, comportamiento y texturas de los personajes. |
| `builds/` | Edificios y elementos del entorno reutilizables. |
| `system/` | Ciclo día/noche, diálogos, HUD y generador de NPC. |
| `assets/` | Hojas de sprites, texturas y animaciones gráficas. |
| `GAMESTATE.gd` | Estado global de salud, dinero, capítulo, mapa y hora. |
| `PLAYER.gd` | Movimiento y animación del jugador. |
| `ORCHESTRA.gd` | Cargador experimental de mapas y niveles. |
| `TEST.tscn` | Escena independiente para probar personajes y movimiento. |

## Sistemas principales

- `GAMESTATE` y `DIALOGBOX` se registran como autoloads y están disponibles
  globalmente.
- `PLAYER.gd` lee las acciones de movimiento de Godot y actualiza su posición
  mediante la física 2D.
- `characters/CHARACTER.gd` controla animación, movimiento y comportamiento
  básico de los NPC. Sus apariencias se cargan desde `characters/textures/`.
- `system/daynight.gd` calcula la hora del juego y aplica el gradiente de luz.
- `system/dialog/dialogbox.gd` muestra texto progresivamente y espera la acción
  `ui_accept` para continuar o cerrar el diálogo.

## Estado y limitaciones conocidas

El proyecto es una alpha en desarrollo. `ORCHESTRA.gd` es experimental y busca
scripts de nivel en `control/mission/`; esa carpeta no contiene niveles todavía,
por lo que el cargador no está conectado a la escena principal. La escena
principal jugable es actualmente `maps/ohirTown.tscn`.

No hay una suite de pruebas automatizada ni un sistema de guardado configurado.
