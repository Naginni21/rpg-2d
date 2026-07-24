extends Area2D
class_name Collectible
## Collectible - Item que el jugador puede recoger

signal collected(item: Collectible)

enum ItemType { HEALTH, SANITY, KEY, GOLD, WEAPON }

@export var item_type: ItemType = ItemType.HEALTH
@export var value: int = 20
@export var item_name: String = "Item"
@export var bob_amplitude: float = 2.0
@export var bob_speed: float = 3.0
@export var weapon_resource: Resource  # Para items tipo WEAPON

var initial_y: float
var time_passed: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("interactable")
	initial_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	# Efecto de flotación
	time_passed += delta
	position.y = initial_y + sin(time_passed * bob_speed) * bob_amplitude


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_apply_effect(body)
		collected.emit(self)
		_pickup_animation()


func _apply_effect(player: Node2D) -> void:
	match item_type:
		ItemType.HEALTH:
			GameManager.heal_player(value)
		ItemType.SANITY:
			SanitySystem.restore_sanity(value)
		ItemType.KEY:
			GameManager.add_item({"id": item_name, "type": "key"})
		ItemType.GOLD:
			GameManager.add_item({"id": "gold", "type": "gold", "amount": value})
		ItemType.WEAPON:
			if weapon_resource and player.has_method("equip_weapon"):
				player.equip_weapon(weapon_resource)


func _pickup_animation() -> void:
	# Desactivar colisión
	set_deferred("monitoring", false)

	# Animación de recolección
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.15)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.15)
	tween.parallel().tween_property(self, "position:y", position.y - 10, 0.15)

	await tween.finished
	queue_free()


func interact(_player: Node2D) -> void:
	# Si se interactúa manualmente
	_on_body_entered(_player)
