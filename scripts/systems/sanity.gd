extends Node
## SanitySystem - Sistema de cordura Lovecraftiano
## La cordura afecta la percepción del jugador y la dificultad del juego

signal sanity_changed(new_value: int, max_value: int)
signal sanity_threshold_crossed(threshold: String)
signal hallucination_triggered

# Umbrales de cordura
enum SanityState { STABLE, UNEASY, DISTURBED, UNSTABLE, BROKEN }

const THRESHOLDS = {
	SanityState.STABLE: 80,      # 80-100: Normal
	SanityState.UNEASY: 60,      # 60-79: Ligeramente perturbado
	SanityState.DISTURBED: 40,   # 40-59: Perturbado
	SanityState.UNSTABLE: 20,    # 20-39: Inestable
	SanityState.BROKEN: 0        # 0-19: Roto
}

var current_state: SanityState = SanityState.STABLE
var hallucination_chance: float = 0.0
var sanity_drain_multiplier: float = 1.0

# Efectos visuales por nivel de cordura
var visual_effects: Dictionary = {
	SanityState.STABLE: {"vignette": 0.0, "distortion": 0.0, "desaturation": 0.0},
	SanityState.UNEASY: {"vignette": 0.1, "distortion": 0.02, "desaturation": 0.1},
	SanityState.DISTURBED: {"vignette": 0.25, "distortion": 0.05, "desaturation": 0.25},
	SanityState.UNSTABLE: {"vignette": 0.4, "distortion": 0.1, "desaturation": 0.4},
	SanityState.BROKEN: {"vignette": 0.6, "distortion": 0.2, "desaturation": 0.6}
}


func _ready() -> void:
	_update_state()


func _process(delta: float) -> void:
	_check_hallucinations(delta)


func reduce_sanity(amount: int, source: String = "") -> void:
	var actual_amount = int(amount * sanity_drain_multiplier)
	GameManager.player_stats.sanity = maxi(
		GameManager.player_stats.sanity - actual_amount,
		0
	)
	_update_state()
	sanity_changed.emit(
		GameManager.player_stats.sanity,
		GameManager.player_stats.max_sanity
	)


func restore_sanity(amount: int) -> void:
	GameManager.player_stats.sanity = mini(
		GameManager.player_stats.sanity + amount,
		GameManager.player_stats.max_sanity
	)
	_update_state()
	sanity_changed.emit(
		GameManager.player_stats.sanity,
		GameManager.player_stats.max_sanity
	)


func get_sanity_percent() -> float:
	return float(GameManager.player_stats.sanity) / float(GameManager.player_stats.max_sanity)


func get_current_effects() -> Dictionary:
	return visual_effects[current_state]


func _update_state() -> void:
	var sanity = GameManager.player_stats.sanity
	var old_state = current_state

	if sanity >= THRESHOLDS[SanityState.STABLE]:
		current_state = SanityState.STABLE
		hallucination_chance = 0.0
	elif sanity >= THRESHOLDS[SanityState.UNEASY]:
		current_state = SanityState.UNEASY
		hallucination_chance = 0.02
	elif sanity >= THRESHOLDS[SanityState.DISTURBED]:
		current_state = SanityState.DISTURBED
		hallucination_chance = 0.05
	elif sanity >= THRESHOLDS[SanityState.UNSTABLE]:
		current_state = SanityState.UNSTABLE
		hallucination_chance = 0.1
	else:
		current_state = SanityState.BROKEN
		hallucination_chance = 0.2

	if old_state != current_state:
		sanity_threshold_crossed.emit(SanityState.keys()[current_state])


func _check_hallucinations(delta: float) -> void:
	if hallucination_chance > 0 and randf() < hallucination_chance * delta:
		hallucination_triggered.emit()


func get_state_name() -> String:
	return SanityState.keys()[current_state]


# Eventos que afectan la cordura
func on_see_horror(horror_level: int = 1) -> void:
	reduce_sanity(5 * horror_level, "horror")


func on_read_forbidden_knowledge() -> void:
	reduce_sanity(10, "forbidden_knowledge")


func on_enemy_death_witnessed() -> void:
	reduce_sanity(2, "death")


func on_rest_at_safe_location() -> void:
	restore_sanity(20)


func on_use_calming_item(potency: int = 10) -> void:
	restore_sanity(potency)
