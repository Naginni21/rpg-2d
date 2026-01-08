extends CharacterBody2D
class_name BaseEnemy
## BaseEnemy - Clase base para todos los enemigos

signal died(enemy: BaseEnemy)

@export var enemy_name: String = "Unknown Horror"
@export var max_health: int = 30
@export var attack: int = 5
@export var defense: int = 2
@export var speed: float = 50.0
@export var horror_level: int = 1  # Cuánta cordura drena al ser visto
@export var detection_range: float = 80.0
@export var attack_range: float = 20.0

var health: int
var target: Node2D = null
var is_dead: bool = false
var has_been_seen: bool = false

enum State { IDLE, PATROL, CHASE, ATTACK, STUNNED }
var current_state: State = State.IDLE

@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $DetectionArea


func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	_setup_detection_area()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.PATROL:
			_state_patrol(delta)
		State.CHASE:
			_state_chase(delta)
		State.ATTACK:
			_state_attack(delta)
		State.STUNNED:
			pass

	move_and_slide()


func _state_idle(_delta: float) -> void:
	velocity = Vector2.ZERO
	# Buscar jugador en rango
	if target and global_position.distance_to(target.global_position) <= detection_range:
		current_state = State.CHASE


func _state_patrol(_delta: float) -> void:
	# Override en clases hijas para comportamiento de patrulla
	pass


func _state_chase(delta: float) -> void:
	if not target:
		current_state = State.IDLE
		return

	var distance = global_position.distance_to(target.global_position)

	if distance <= attack_range:
		current_state = State.ATTACK
	elif distance > detection_range * 1.5:
		target = null
		current_state = State.IDLE
	else:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed


func _state_attack(_delta: float) -> void:
	velocity = Vector2.ZERO
	# Override en clases hijas para ataques específicos


func take_damage(amount: int, attacker: Node2D = null) -> void:
	if is_dead:
		return

	var actual_damage = maxi(amount - defense, 1)
	health -= actual_damage

	_on_damaged(actual_damage, attacker)

	if health <= 0:
		die()


func die() -> void:
	is_dead = true
	current_state = State.STUNNED
	velocity = Vector2.ZERO

	# Reducir cordura del jugador al presenciar la muerte
	SanitySystem.on_enemy_death_witnessed()

	died.emit(self)
	_on_death()

	# Animación de muerte y luego eliminar
	await _death_animation()
	queue_free()


func _on_damaged(_amount: int, _attacker: Node2D) -> void:
	# Flash de daño
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE


func _on_death() -> void:
	# Override para drops, efectos, etc.
	pass


func _death_animation() -> void:
	# Animación simple de desvanecimiento
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	await tween.finished


func _setup_detection_area() -> void:
	if detection_area:
		var shape = CircleShape2D.new()
		shape.radius = detection_range
		var collision = CollisionShape2D.new()
		collision.shape = shape
		detection_area.add_child(collision)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		# Primera vez que el jugador ve este horror
		if not has_been_seen:
			has_been_seen = true
			SanitySystem.on_see_horror(horror_level)


func _on_player_visible() -> void:
	# Llamar cuando el jugador puede ver este enemigo
	if not has_been_seen:
		has_been_seen = true
		SanitySystem.on_see_horror(horror_level)
