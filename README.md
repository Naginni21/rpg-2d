# Eldritch Depths

Un RPG 2D con temática Lovecraftiana en un escenario medieval oscuro.

## Requisitos

- [Godot 4.3+](https://godotengine.org/download)

## Cómo Ejecutar

1. Abre Godot 4.3 o superior
2. Importa el proyecto seleccionando el archivo `project.godot`
3. Presiona F5 o el botón "Play"

## Controles

| Tecla | Acción |
|-------|--------|
| WASD / Flechas | Movimiento |
| E / Enter | Interactuar |
| ESC | Pausa |

### Debug (solo en modo desarrollo)
| Tecla | Acción |
|-------|--------|
| F1 | Reducir cordura (-10) |
| F2 | Restaurar cordura (+10) |
| F3 | Dañar jugador (-10 HP) |

## Estructura del Proyecto

```
rpg-2d/
├── assets/          # Recursos gráficos y de audio
├── scenes/          # Escenas de Godot (.tscn)
├── scripts/         # Código GDScript
│   ├── player/      # Lógica del jugador
│   ├── enemies/     # IA y comportamiento de enemigos
│   └── systems/     # Sistemas del juego (cordura, combate, etc.)
└── data/            # Datos JSON (items, enemigos, diálogos)
```

## Sistema de Cordura

La cordura es una mecánica central del juego:

- **100-80%**: Estable - Sin efectos
- **79-60%**: Inquieto - Ligera viñeta
- **59-40%**: Perturbado - Distorsión visual leve
- **39-20%**: Inestable - Alucinaciones ocasionales
- **19-0%**: Roto - Efectos severos, alucinaciones frecuentes

### Cómo se pierde cordura
- Ver horrores/enemigos por primera vez
- Leer conocimiento prohibido
- Presenciar muertes

### Cómo se recupera
- Descansar en lugares seguros
- Usar tónicos de cordura
- Items especiales

## Próximos Pasos

- [ ] Agregar sprites placeholder para el jugador
- [ ] Crear un tileset básico para pruebas
- [ ] Implementar sistema de combate por turnos
- [ ] Agregar NPCs con diálogos
- [ ] Crear primera mazmorra

## Licencia

Proyecto privado - Todos los derechos reservados
