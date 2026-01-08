extends CharacterBody2D
class_name Player
## Player - Controlador principal del personaje jugable

signal interacted

@export var speed: float = 100.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interaction_area: Area2D = $InteractionArea

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN
var can_move: bool = true
var is_interacting: bool = false

# Referencias a interactuables cercanos
var nearby_interactables: Array[Node2D] = []


func _ready() -> void:
	# Conectar señales del sistema de cordura
	SanitySystem.sanity_changed.connect(_on_sanity_changed)
	SanitySystem.hallucination_triggered.connect(_on_hallucination)


func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
		return

	# Obtener input
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		last_direction = direction
		# Acelerar hacia la dirección
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		_update_animation("walk")
	else:
		# Aplicar fricción
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		_update_animation("idle")

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_move:
		_try_interact()


func _update_animation(state: String) -> void:
	var anim_direction = _get_animation_direction()
	var anim_name = state + "_" + anim_direction

	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	elif animation_player.has_animation(state):
		animation_player.play(state)


func _get_animation_direction() -> String:
	if abs(last_direction.x) > abs(last_direction.y):
		return "right" if last_direction.x > 0 else "left"
	else:
		return "down" if last_direction.y > 0 else "up"


func _try_interact() -> void:
	if nearby_interactables.is_empty():
		return

	# Interactuar con el objeto más cercano
	var closest: Node2D = null
	var closest_dist: float = INF

	for obj in nearby_interactables:
		var dist = global_position.distance_to(obj.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = obj

	if closest and closest.has_method("interact"):
		is_interacting = true
		can_move = false
		closest.interact(self)
		interacted.emit()


func end_interaction() -> void:
	is_interacting = false
	can_move = true


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		nearby_interactables.append(body)


func _on_interaction_area_body_exited(body: Node2D) -> void:
	nearby_interactables.erase(body)


func _on_sanity_changed(new_value: int, max_value: int) -> void:
	# Aplicar efectos visuales basados en la cordura
	var effects = SanitySystem.get_current_effects()
	# TODO: Aplicar shader de distorsión basado en effects


func _on_hallucination() -> void:
	# Efecto de alucinación
	# TODO: Mostrar sprite fantasma, sonido perturbador, etc.
	pass


func take_damage(amount: int) -> void:
	GameManager.damage_player(amount)
	# Flash rojo o animación de daño
	_flash_damage()


func _flash_damage() -> void:
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
