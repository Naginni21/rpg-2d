extends Node
## GameManager - Autoload singleton para manejar el estado global del juego

signal game_paused
signal game_resumed
signal player_died

# Estado del juego
var is_paused: bool = false
var current_map: String = ""

# Estadísticas del jugador (persistentes entre escenas)
var player_stats: Dictionary = {
	"max_health": 100,
	"health": 100,
	"max_sanity": 100,
	"sanity": 100,
	"attack": 10,
	"defense": 5,
	"speed": 100.0,
	"level": 1,
	"experience": 0
}

# Inventario
var inventory: Array[Dictionary] = []
var max_inventory_size: int = 20

# Flags de progreso del juego
var game_flags: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	if is_paused:
		game_paused.emit()
	else:
		game_resumed.emit()


func heal_player(amount: int) -> void:
	player_stats.health = mini(player_stats.health + amount, player_stats.max_health)


func damage_player(amount: int) -> void:
	var actual_damage = maxi(amount - player_stats.defense, 1)
	player_stats.health -= actual_damage
	if player_stats.health <= 0:
		player_stats.health = 0
		player_died.emit()


func add_item(item: Dictionary) -> bool:
	if inventory.size() >= max_inventory_size:
		return false
	inventory.append(item)
	return true


func remove_item(item_id: String) -> bool:
	for i in range(inventory.size()):
		if inventory[i].get("id") == item_id:
			inventory.remove_at(i)
			return true
	return false


func set_flag(flag_name: String, value: bool = true) -> void:
	game_flags[flag_name] = value


func get_flag(flag_name: String) -> bool:
	return game_flags.get(flag_name, false)


func change_scene(scene_path: String) -> void:
	current_map = scene_path
	get_tree().change_scene_to_file(scene_path)


func reset_game() -> void:
	player_stats = {
		"max_health": 100,
		"health": 100,
		"max_sanity": 100,
		"sanity": 100,
		"attack": 10,
		"defense": 5,
		"speed": 100.0,
		"level": 1,
		"experience": 0
	}
	inventory.clear()
	game_flags.clear()
