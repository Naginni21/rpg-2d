extends CharacterBody2D
class_name BaseEnemy
## BaseEnemy - Clase base para todos los enemigos

signal died(enemy: BaseEnemy)

@export var enemy_name: String = "Unknown Horror"
@export var max_health: int = 30
@export var attack_damage: int = 5
@export var defense: int = 2
@export var speed: float = 50.0
@export var horror_level: int = 1  # Cuánta cordura drena al ser visto
@export var detection_range: float = 80.0
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 1.0

var health: int
var target: Node2D = null
var is_dead: bool = false
var has_been_seen: bool = false
var can_attack: bool = true
var facing_right: bool = true

enum State { IDLE, PATROL, CHASE, ATTACK, HURT, DEAD }
var current_state: State = State.IDLE

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
	health = max_health
	add_to_group("enemies")

	# Configurar timer de ataque
	if attack_timer:
		attack_timer.wait_time = attack_cooldown
		attack_timer.one_shot = true
		attack_timer.timeout.connect(_on_attack_timer_timeout)

	# Iniciar animación idle
	if sprite and sprite.sprite_frames:
		sprite.play("idle")


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
		State.HURT:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
		State.DEAD:
			pass

	move_and_slide()


func _state_idle(_delta: float) -> void:
	velocity = Vector2.ZERO
	_play_animation("idle")

	# Buscar jugador en rango
	if target and global_position.distance_to(target.global_position) <= detection_range:
		current_state = State.CHASE


func _state_patrol(_delta: float) -> void:
	_play_animation("run")
	# Override en clases hijas para comportamiento de patrulla


func _state_chase(_delta: float) -> void:
	if not target or not is_instance_valid(target):
		target = null
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
		_update_facing(direction)
		_play_animation("run")


func _state_attack(_delta: float) -> void:
	velocity = Vector2.ZERO

	if not target or not is_instance_valid(target):
		target = null
		current_state = State.IDLE
		return

	var distance = global_position.distance_to(target.global_position)

	if distance > attack_range * 1.5:
		current_state = State.CHASE
		return

	# Mirar hacia el objetivo
	var direction = (target.global_position - global_position).normalized()
	_update_facing(direction)

	if can_attack:
		_perform_attack()


func _perform_attack() -> void:
	can_attack = false
	_play_animation("idle")  # O attack si existe

	# Hacer daño al jugador
	if target and target.has_method("take_damage"):
		target.take_damage(attack_damage)

	if attack_timer:
		attack_timer.start()


func _on_attack_timer_timeout() -> void:
	can_attack = true


func _update_facing(direction: Vector2) -> void:
	if direction.x > 0.1:
		facing_right = true
		sprite.flip_h = false
	elif direction.x < -0.1:
		facing_right = false
		sprite.flip_h = true


func _play_animation(anim_name: String) -> void:
	if sprite and sprite.sprite_frames:
		if sprite.sprite_frames.has_animation(anim_name):
			if sprite.animation != anim_name:
				sprite.play(anim_name)


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
	current_state = State.DEAD
	velocity = Vector2.ZERO

	# Reducir cordura del jugador al presenciar la muerte
	SanitySystem.on_enemy_death_witnessed()

	died.emit(self)
	_on_death()

	# Animación de muerte
	await _death_animation()
	queue_free()


func _on_damaged(_amount: int, _attacker: Node2D) -> void:
	current_state = State.HURT

	# Flash de daño
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.15).timeout
	sprite.modulate = Color.WHITE

	if not is_dead:
		current_state = State.CHASE


func _on_death() -> void:
	# Override para drops, efectos, etc.
	pass


func _death_animation() -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished
	else:
		# Animación simple de desvanecimiento
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		await tween.finished


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		# Primera vez que el jugador ve este horror
		if not has_been_seen:
			has_been_seen = true
			SanitySystem.on_see_horror(horror_level)


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		# Mantener persiguiendo por un momento
		await get_tree().create_timer(2.0).timeout
		if current_state == State.IDLE:
			target = null
