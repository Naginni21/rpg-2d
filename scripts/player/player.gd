extends CharacterBody2D
class_name Player
## Player - Controlador principal del personaje jugable

signal interacted
signal attacked
signal weapon_changed(weapon: Resource)

@export var speed: float = 100.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0
@export var base_attack_damage: int = 10

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN
var facing: String = "down"
var can_move: bool = true
var is_interacting: bool = false
var is_attacking: bool = false

# Sistema de armas
var equipped_weapon: Resource = null
var attack_damage: int:
	get:
		if equipped_weapon and equipped_weapon.has("damage"):
			return equipped_weapon.damage
		return base_attack_damage

# Referencias a interactuables cercanos
var nearby_interactables: Array[Node2D] = []


func _ready() -> void:
	# Conectar señales del sistema de cordura
	SanitySystem.sanity_changed.connect(_on_sanity_changed)
	SanitySystem.hallucination_triggered.connect(_on_hallucination)

	# Conectar señal de animación terminada
	sprite.animation_finished.connect(_on_animation_finished)

	# Iniciar con idle
	sprite.play("idle_down")


func _physics_process(delta: float) -> void:
	if is_attacking:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
		return

	if not can_move:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
		return

	# Obtener input
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		last_direction = direction
		_update_facing()
		# Acelerar hacia la dirección
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		_play_animation("walk")
	else:
		# Aplicar fricción
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		_play_animation("idle")

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_move and not is_attacking:
		_try_interact()

	if event.is_action_pressed("attack") and can_move and not is_attacking:
		_attack()


func _update_facing() -> void:
	if abs(last_direction.x) > abs(last_direction.y):
		facing = "right" if last_direction.x > 0 else "left"
	else:
		facing = "down" if last_direction.y > 0 else "up"

	# Flip sprite para izquierda/derecha
	if facing == "left":
		sprite.flip_h = true
	elif facing == "right":
		sprite.flip_h = false


func _play_animation(state: String) -> void:
	var anim_name = state + "_" + _get_anim_direction()

	if sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)


func _get_anim_direction() -> String:
	# Para sprites que solo tienen down/up/side
	match facing:
		"left", "right":
			return "side"
		_:
			return facing


func _attack() -> void:
	is_attacking = true
	can_move = false

	# Posicionar el área de ataque según la dirección
	_position_attack_area()
	attack_collision.disabled = false

	# Reproducir animación de ataque
	var anim_name = "attack_" + _get_anim_direction()
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		# Si no hay animación de ataque, usar idle y terminar rápido
		_on_animation_finished()

	# Detectar enemigos múltiples veces durante el ataque para mejor detección
	for i in range(3):
		await get_tree().create_timer(0.1).timeout
		if is_attacking:
			_deal_damage()
	attacked.emit()


func _position_attack_area() -> void:
	match facing:
		"down":
			attack_collision.position = Vector2(0, 20)
		"up":
			attack_collision.position = Vector2(0, -20)
		"left":
			attack_collision.position = Vector2(-20, 0)
		"right":
			attack_collision.position = Vector2(20, 0)


func _deal_damage() -> void:
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(attack_damage)


func _on_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		can_move = true
		attack_collision.disabled = true
		_play_animation("idle")


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


func equip_weapon(weapon: Resource) -> void:
	equipped_weapon = weapon
	weapon_changed.emit(weapon)
	if weapon.has("weapon_name") and weapon.has("damage"):
		print("Equipped: ", weapon.weapon_name, " (Damage: ", weapon.damage, ")")
