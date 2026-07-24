extends Resource
class_name Weapon
## Weapon - Define las propiedades de un arma

@export var weapon_name: String = "Fists"
@export var damage: int = 10
@export var attack_range: float = 20.0
@export var attack_speed: float = 1.0  # Multiplicador de velocidad
@export var knockback: float = 50.0
@export_multiline var description: String = ""
@export var icon: Texture2D

# Tipos de armas
enum WeaponType { FIST, SWORD, AXE, DAGGER, MACE }
@export var weapon_type: WeaponType = WeaponType.FIST
