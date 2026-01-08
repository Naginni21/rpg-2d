extends Node2D
## Main - Script de la escena principal del juego

@onready var player: Player = $World/Entities/Player
@onready var health_bar: ProgressBar = $CanvasLayer/UI/HealthBar
@onready var sanity_bar: ProgressBar = $CanvasLayer/UI/SanityBar
@onready var sanity_effect: ColorRect = $CanvasLayer/SanityEffect


func _ready() -> void:
	# Conectar señales
	SanitySystem.sanity_changed.connect(_on_sanity_changed)
	SanitySystem.hallucination_triggered.connect(_on_hallucination)
	GameManager.player_died.connect(_on_player_died)

	# Inicializar UI
	_update_ui()


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
