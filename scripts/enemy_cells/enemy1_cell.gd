extends Node2D

@export var enemy_res: Resource = null
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var enemy_1_progress_bar: ProgressBar = $"../CanvasLayer/HBoxContainer/HpContainer/Enemy1ProgressBar"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var enemy_damage_label: Label = $"../CanvasLayer/EnemyDamageLabel"
@onready var animation_player_text: AnimationPlayer = $"../AnimationPlayerText"
var on_effect: String = "is_nothing"
var on_effect_duration: int = 0
var on_effect_max_duration: int = 0
func _ready() -> void:
	sprite_2d.texture = enemy_res.texture
	set_health(enemy_1_progress_bar, enemy_res.current_hp, enemy_res.max_hp)
	
func take_damage(damage, effect, effect_max_duration):
	match effect:
		"knockout":
			on_effect_max_duration = effect_max_duration
			on_effect = "is_knockout"
		"bleeding":
			on_effect_max_duration = effect_max_duration
			on_effect = "is_bleeding"
	enemy_res.current_hp = max(0, enemy_res.current_hp - damage)
	set_health(enemy_1_progress_bar, enemy_res.current_hp, enemy_res.max_hp)
	enemy_damage_label.text = str(damage)
	animation_player_text.play(str(name)+"_damage")
	

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]


func _on_battle_controller_group_turns_ended() -> void:
	print(on_effect_duration)
	on_effect_duration += 1
	match on_effect:
		"is_bleeding":
			take_damage(5, "is_nothing", 0)
		"is_knockout":
			pass
	if on_effect_duration >= on_effect_max_duration:
		on_effect = "is_nothing"
		on_effect_duration = 0
	print(on_effect_duration)
