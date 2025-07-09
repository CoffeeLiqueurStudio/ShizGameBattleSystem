extends Node2D

@export var enemy_res: Resource = null
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var enemy_1_progress_bar: ProgressBar = $"../CanvasLayer/HBoxContainer/HpContainer/Enemy1ProgressBar"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var enemy_damage_label: Label = $"../CanvasLayer/EnemyDamageLabel"
@onready var animation_player_text: AnimationPlayer = $"../AnimationPlayerText"

func _ready() -> void:
	sprite_2d.texture = enemy_res.texture
	set_health(enemy_1_progress_bar, enemy_res.current_hp, enemy_res.max_hp)
	
func take_damage(damage):
	enemy_res.current_hp = max(0, enemy_res.current_hp - damage)
	set_health(enemy_1_progress_bar, enemy_res.current_hp, enemy_res.max_hp)
	enemy_damage_label.text = str(damage)
	animation_player_text.play(str(name)+"_damage")
	
func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]
