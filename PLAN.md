# Plan de Desarrollo: RPG 2D Lovecraftiano Medieval

## Resumen del Proyecto
Juego RPG 2D con estética pixel art, temática Lovecraftiana (horror cósmico) en un escenario medieval oscuro.

---

## 1. Análisis de Tecnologías (2025-2026)

### Motor de Juego Recomendado: **Godot 4.x**

| Criterio | Godot | Unity | RPG Maker | Phaser |
|----------|-------|-------|-----------|--------|
| Costo | ✅ Gratis (MIT) | ⚠️ Gratis hasta $200k | 💰 $80+ | ✅ Gratis |
| Curva de aprendizaje | ✅ Baja | ⚠️ Media-Alta | ✅ Muy baja | ⚠️ Media |
| Especialización 2D | ✅ Excelente | ⚠️ Bueno | ✅ Excelente | ✅ Bueno |
| Asistencia IA | ✅ GDScript bien documentado | ✅ C# muy soportado | ⚠️ Limitado | ✅ JavaScript |
| Pixel Art | ✅ Nativo | ⚠️ Requiere config | ✅ Nativo | ✅ Bueno |
| Open Source | ✅ Sí | ❌ No | ❌ No | ✅ Sí |

### ¿Por qué Godot?
1. **100% gratuito** - Sin royalties ni licencias
2. **Diseñado para 2D** - Herramientas nativas para tilemaps, sprites, animaciones
3. **GDScript** - Similar a Python, perfecto para IA como Claude
4. **Ligero** - Funciona en hardware modesto
5. **Gran comunidad** - Muchos tutoriales y recursos
6. **Exportación multiplataforma** - Windows, Linux, Mac, Web, Mobile

---

## 2. Herramientas de Desarrollo

### Arte y Gráficos
| Herramienta | Uso | Costo |
|-------------|-----|-------|
| **Aseprite** | Editor pixel art principal | $20 (o compilar gratis) |
| **LibreSprite** | Alternativa gratuita a Aseprite | Gratis |
| **GIMP** | Edición de imágenes general | Gratis |
| **Krita** | Arte digital y conceptos | Gratis |

### Audio
| Herramienta | Uso | Costo |
|-------------|-----|-------|
| **LMMS** | Composición musical | Gratis |
| **Audacity** | Edición de audio/SFX | Gratis |
| **SFXR/Bfxr** | Generador de efectos retro | Gratis |

### Desarrollo con IA
| Herramienta | Uso |
|-------------|-----|
| **Claude** | Código GDScript, diálogos, lore, diseño de sistemas |
| **Generadores IA de Arte** | Concept art, referencias (no assets finales) |
| **IA de Audio** | Música ambiental, efectos |

---

## 3. Estructura del Proyecto Godot

```
rpg-2d/
├── project.godot          # Configuración del proyecto
├── assets/
│   ├── sprites/
│   │   ├── characters/    # Personajes y NPCs
│   │   ├── enemies/       # Monstruos Lovecraftianos
│   │   ├── tilesets/      # Tiles del mundo
│   │   └── ui/            # Interfaz de usuario
│   ├── audio/
│   │   ├── music/         # Música ambiental oscura
│   │   └── sfx/           # Efectos de sonido
│   └── fonts/             # Fuentes pixel art
├── scenes/
│   ├── main.tscn          # Escena principal
│   ├── player/            # Escenas del jugador
│   ├── enemies/           # Escenas de enemigos
│   ├── maps/              # Mapas del mundo
│   └── ui/                # Interfaz de usuario
├── scripts/
│   ├── player/            # Lógica del jugador
│   ├── enemies/           # IA de enemigos
│   ├── systems/           # Sistemas del juego
│   │   ├── combat.gd      # Sistema de combate
│   │   ├── inventory.gd   # Inventario
│   │   ├── dialogue.gd    # Sistema de diálogos
│   │   └── sanity.gd      # Sistema de cordura (Lovecraft)
│   └── utils/             # Utilidades
├── data/
│   ├── items.json         # Definición de items
│   ├── enemies.json       # Estadísticas de enemigos
│   └── dialogues/         # Archivos de diálogo
└── docs/
    ├── PLAN.md            # Este documento
    ├── GDD.md             # Game Design Document
    └── LORE.md            # Historia y mundo
```

---

## 4. Características del Juego (MVP)

### Mecánicas Core
1. **Movimiento** - Top-down o side-scroller
2. **Combate** - Por turnos o acción (recomendado: turnos para simplicidad)
3. **Inventario** - Items, equipamiento, consumibles
4. **Diálogos** - Sistema de conversaciones con NPCs
5. **Sistema de Cordura** - Mecánica Lovecraftiana única

### Sistema de Cordura (Sanity)
- La cordura disminuye al ver horrores
- Baja cordura = alucinaciones, enemigos más difíciles
- Se recupera descansando, usando items, en lugares seguros
- Efectos visuales/auditivos al bajar

### Estética Lovecraftiana Medieval
- **Paleta de colores**: Oscura, desaturada (4-5 colores base)
- **Criaturas**: Tentáculos, ojos múltiples, formas imposibles
- **Ambiente**: Aldeas abandonadas, bosques siniestros, ruinas antiguas
- **Temas**: Locura, conocimiento prohibido, cultos, lo desconocido

---

## 5. Fases de Desarrollo

### Fase 1: Prototipo (2-3 semanas de trabajo)
- [ ] Configurar proyecto Godot
- [ ] Movimiento básico del jugador
- [ ] Tilemap simple (una habitación)
- [ ] Colisiones básicas
- [ ] Un sprite placeholder del jugador

### Fase 2: Mecánicas Core (4-6 semanas)
- [ ] Sistema de combate por turnos
- [ ] Inventario básico
- [ ] Sistema de diálogos
- [ ] Sistema de cordura
- [ ] Menú de pausa

### Fase 3: Contenido (6-8 semanas)
- [ ] Primer mapa completo (aldea inicial)
- [ ] 3-5 tipos de enemigos
- [ ] 10-15 items
- [ ] NPCs con diálogos
- [ ] Primera mazmorra

### Fase 4: Pulido (2-4 semanas)
- [ ] Arte final pixel art
- [ ] Música y efectos de sonido
- [ ] Balanceo de dificultad
- [ ] UI/UX mejorado
- [ ] Bugs y optimización

---

## 6. Recursos de Aprendizaje

### Godot
- [Documentación oficial Godot](https://docs.godotengine.org/)
- [GDQuest - Tutoriales YouTube](https://www.youtube.com/@gdquest)
- [HeartBeast - RPG Tutorial Series](https://www.youtube.com/@uaborterror)

### Pixel Art
- [Pixel Art Tutorial - Lospec](https://lospec.com/pixel-art-tutorials)
- [MortMort - YouTube](https://www.youtube.com/@MortMort)

### Assets Gratuitos (para prototipar)
- [itch.io - Pixel Art Assets](https://itch.io/game-assets/tag-pixel-art)
- [OpenGameArt.org](https://opengameart.org/)
- [Kenney.nl](https://kenney.nl/assets)

---

## 7. Próximos Pasos Inmediatos

1. **Instalar Godot 4.3+** desde [godotengine.org](https://godotengine.org/)
2. **Instalar Aseprite o LibreSprite** para pixel art
3. **Crear estructura de proyecto** en este repositorio
4. **Definir el GDD** (Game Design Document) detallado
5. **Comenzar prototipo** con movimiento básico

---

## 8. Consideraciones para Desarrollo con IA

### Lo que Claude puede hacer bien:
- ✅ Escribir código GDScript
- ✅ Diseñar sistemas de juego
- ✅ Crear diálogos y lore
- ✅ Debuggear código
- ✅ Documentación

### Lo que requiere trabajo manual:
- ⚠️ Arte pixel art (IA puede dar referencias)
- ⚠️ Testing y gameplay feel
- ⚠️ Integración en Godot Editor
- ⚠️ Balanceo fino

---

## Fuentes de Investigación

- [Best Game Engines for Beginners 2026](https://gamedesignskills.com/game-development/video-game-engines/)
- [6 Best 2D Game Engines 2025](https://rocketbrush.com/blog/best-2d-game-engines)
- [Godot vs Unity 2025](https://kevurugames.com/blog/godot-vs-unity-which-one-suits-you-best/)
- [Pixel Art Game Development Techniques](https://ejaw.net/how-to-get-started-with-pixel-art-game-development/)
- [Pixel Art Cosmic Horror RPG](https://80.lv/articles/pixel-art-cosmic-horror-rpg-inspired-by-h-p-lovecraft)
- [Lovecraftian Pixel Art Assets - itch.io](https://itch.io/game-assets/tag-lovecraft/tag-pixel-art)
- [Magic Tools - Game Dev Resources](https://github.com/ellisonleao/magictools)
