extends Resource

@export var texture: Texture = null
@export var max_hp: float = 0.0
@export var current_hp: float = 0.0
@export var min_damage: float = 0.0
@export var max_damage: float = 0.0
@export var defend: float = 0.0
@export var is_defending: bool = false
@export var mp: float = 0.0
@export var skills: Array[MagicSkill] = []
