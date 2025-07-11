extends Node2D

@export var player_res: Resource = null
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player_1_hp_progress_bar: ProgressBar = $"../CanvasLayer/Panel/HBoxContainer/HpContainer/Player1HpProgressBar"
@onready var player_1_mp_progress_bar: ProgressBar = $"../CanvasLayer/Panel/HBoxContainer/HpContainer/Player1MpProgressBar"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var player_1_damage_label: Label = $Player1DamageLabel
@onready var animation_player_text: AnimationPlayer = $"../AnimationPlayerText"
enum states {IDLE, TAKE_DAMAGE}
var active_state = states.IDLE
func _ready() -> void:
	sprite_2d.texture = player_res.texture
	set_health()
	set_mana()
func take_damage(damage):
	active_state = states.TAKE_DAMAGE
	if player_res.is_defending == true:
		damage = max(0, damage - player_res.defend/2)
		player_res.is_defending = false
		player_1_damage_label.text = str(damage)
		animation_player_text.play(str(name)+"_damage")
	else:
		pass
	player_res.current_hp = max(0, player_res.current_hp - damage)
	set_health()
	player_1_damage_label.text = str(damage)
	animation_player_text.play(str(name)+"_damage")
func set_health():
	player_1_hp_progress_bar.value = player_res.current_hp
	player_1_hp_progress_bar.max_value = player_res.max_hp
	player_1_hp_progress_bar.get_node("Label").text = "HP: %d/%d" % [player_res.current_hp, player_res.max_hp]

func set_mana():
	player_1_mp_progress_bar.value = player_res.current_mp
	player_1_mp_progress_bar.max_value = player_res.max_mp
	player_1_mp_progress_bar.get_node("Label").text = "MP: %d/%d" % [player_res.current_mp, player_res.max_mp]
func _on_battle_controller_group_turns_ended() -> void:
	pass


func _physics_process(delta: float) -> void:
	match active_state:
		states.IDLE:
			pass
		states.TAKE_DAMAGE:
			animation_player.play(str(name)+"_take_damage")
			await animation_player.animation_finished
			active_state = states.IDLE
