extends Node2D

@export var player_res: Resource = null
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player_1_progress_bar: ProgressBar = $"../CanvasLayer/HBoxContainer/HpContainer/Player1ProgressBar"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var player_damage_label: Label = $"../CanvasLayer/PlayerDamageLabel"
@onready var animation_player_text: AnimationPlayer = $"../AnimationPlayerText"

func _ready() -> void:
	sprite_2d.texture = player_res.texture
	set_health(player_1_progress_bar, player_res.current_hp, player_res.max_hp)
func take_damage(damage):
	if player_res.is_defending == true:
		damage = max(0, damage - player_res.defend/2)
		player_res.is_defending = false
		player_damage_label.text = str(damage)
		animation_player_text.play(str(name)+"_damage")
	else:
		pass
	player_res.current_hp = max(0, player_res.current_hp - damage)
	set_health(player_1_progress_bar, player_res.current_hp, player_res.max_hp)
	player_damage_label.text = str(damage)
	animation_player_text.play(str(name)+"_damage")
func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]


func _on_battle_controller_group_turns_ended() -> void:
	pass
