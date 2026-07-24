extends Node2D
## Main - Script de la escena principal del juego

@onready var player: Player = $World/Entities/Player
@onready var health_bar: ProgressBar = $CanvasLayer/UI/HealthBar
@onready var sanity_bar: ProgressBar = $CanvasLayer/UI/SanityBar
@onready var sanity_effect: ColorRect = $CanvasLayer/SanityEffect
@onready var weapon_label: Label = $CanvasLayer/UI/WeaponLabel
@onready var floor_layer: TileMapLayer = $World/Floor
@onready var walls_layer: TileMapLayer = $World/Walls

const ROOM_WIDTH := 20
const ROOM_HEIGHT := 12


func _ready() -> void:
	# Generar nivel básico
	_generate_simple_dungeon()

	# Conectar señales
	SanitySystem.sanity_changed.connect(_on_sanity_changed)
	SanitySystem.hallucination_triggered.connect(_on_hallucination)
	GameManager.player_died.connect(_on_player_died)
	player.weapon_changed.connect(_on_weapon_changed)

	# Inicializar UI
	_update_ui()


func _generate_simple_dungeon() -> void:
	# Limpiar cualquier tile existente
	floor_layer.clear()
	walls_layer.clear()

	# Generar piso (tiles 0:0 a 3:3 son variaciones de piso)
	for x in range(ROOM_WIDTH):
		for y in range(ROOM_HEIGHT):
			# Elegir tile aleatorio del piso (primeras 4 filas, primeras 4 columnas)
			var tile_x := randi() % 4
			var tile_y := randi() % 4
			floor_layer.set_cell(Vector2i(x, y), 0, Vector2i(tile_x, tile_y))

	# Generar paredes (alrededor del perímetro)
	for x in range(-1, ROOM_WIDTH + 1):
		# Pared superior
		walls_layer.set_cell(Vector2i(x, -1), 0, Vector2i(4, 0))
		# Pared inferior
		walls_layer.set_cell(Vector2i(x, ROOM_HEIGHT), 0, Vector2i(4, 2))

	for y in range(ROOM_HEIGHT):
		# Pared izquierda
		walls_layer.set_cell(Vector2i(-1, y), 0, Vector2i(4, 1))
		# Pared derecha
		walls_layer.set_cell(Vector2i(ROOM_WIDTH, y), 0, Vector2i(5, 1))

	# Esquinas
	walls_layer.set_cell(Vector2i(-1, -1), 0, Vector2i(4, 0))
	walls_layer.set_cell(Vector2i(ROOM_WIDTH, -1), 0, Vector2i(5, 0))
	walls_layer.set_cell(Vector2i(-1, ROOM_HEIGHT), 0, Vector2i(4, 2))
	walls_layer.set_cell(Vector2i(ROOM_WIDTH, ROOM_HEIGHT), 0, Vector2i(5, 2))


func _process(_delta: float) -> void:
	_update_ui()


func _update_ui() -> void:
	health_bar.value = GameManager.player_stats.health
	health_bar.max_value = GameManager.player_stats.max_health
	sanity_bar.value = GameManager.player_stats.sanity
	sanity_bar.max_value = GameManager.player_stats.max_sanity

	# Efecto visual de cordura baja
	var sanity_percent = SanitySystem.get_sanity_percent()
	if sanity_percent < 0.5:
		sanity_effect.visible = true
		sanity_effect.color.a = (0.5 - sanity_percent) * 0.6
	else:
		sanity_effect.visible = false


func _on_sanity_changed(new_value: int, max_value: int) -> void:
	sanity_bar.value = new_value
	sanity_bar.max_value = max_value


func _on_hallucination() -> void:
	# Efecto visual de alucinación
	_flash_screen(Color(0.2, 0, 0.3, 0.5), 0.3)


func _on_weapon_changed(weapon: Resource) -> void:
	if weapon and weapon.has("weapon_name"):
		weapon_label.text = "Weapon: " + weapon.weapon_name
	else:
		weapon_label.text = "Weapon: Fists"


func _on_player_died() -> void:
	# TODO: Pantalla de game over
	print("Player died!")
	await get_tree().create_timer(2.0).timeout
	GameManager.reset_game()
	get_tree().reload_current_scene()


func _flash_screen(color: Color, duration: float) -> void:
	sanity_effect.color = color
	sanity_effect.visible = true
	await get_tree().create_timer(duration).timeout
	sanity_effect.visible = SanitySystem.get_sanity_percent() < 0.5


# Debug: Teclas para probar sistemas
func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey and event.pressed:
			match event.keycode:
				KEY_F1:
					# Reducir cordura para debug
					SanitySystem.reduce_sanity(10)
					print("Sanity: ", GameManager.player_stats.sanity)
				KEY_F2:
					# Restaurar cordura para debug
					SanitySystem.restore_sanity(10)
					print("Sanity: ", GameManager.player_stats.sanity)
				KEY_F3:
					# Dañar jugador para debug
					GameManager.damage_player(10)
					print("Health: ", GameManager.player_stats.health)
