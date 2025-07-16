extends Resource

@export var texture: Texture
@export var max_hp: int
@export var current_hp: int
@export var min_damage: int
@export var max_damage: int
@export var defend: int 
@export var is_defending: bool = false
@export var current_mp: int
@export var max_mp: int
@export var skills: Array[MagicSkill] = []
