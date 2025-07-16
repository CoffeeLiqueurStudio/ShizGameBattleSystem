extends Node2D

@export var enemy_res: Resource = null
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var enemy_1_progress_bar: ProgressBar = $"../CanvasLayer/Panel/HBoxContainer/HpContainer/Enemy1ProgressBar"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var enemy_1_damage_label: Label = $Enemy1DamageLabel
@onready var animation_player_text: AnimationPlayer = $"../AnimationPlayerText"
@onready var action_label: Label = $"../CanvasLayer/ActionLabel"

enum states {IDLE, TAKE_DAMAGE}
var active_state = states.IDLE
var is_knockout: bool = false
var is_blind: bool = false
var on_effect1: String = ""
var on_effect_duration1: int = 0
var on_effect_max_duration1: int = 0
var on_effect2: String = ""
var on_effect_duration2: int = 0
var on_effect_max_duration2: int = 0

func _ready() -> void:
	sprite_2d.texture = enemy_res.texture
	set_health(enemy_1_progress_bar, enemy_res.current_hp, enemy_res.max_hp)
	
func take_damage(damage,):
	active_state = states.TAKE_DAMAGE
	enemy_res.current_hp = max(0, enemy_res.current_hp - damage)
	set_health(enemy_1_progress_bar, enemy_res.current_hp, enemy_res.max_hp)
	action_label.text = ("Player attack and damage %d to enemy." % [damage])
	enemy_1_damage_label.text = str(damage)
	animation_player_text.play(str(name)+"_damage")
func take_effect_damage(damage, effect, effect_max_duration):
	active_state = states.TAKE_DAMAGE
	print(effect)
	match effect:
		"knockout":
			if on_effect1 == "" and on_effect2 != "is_" + effect:
				
				on_effect_max_duration1 = effect_max_duration
				on_effect1 = "is_knockout"
				is_knockout = true
			elif on_effect2 == "" and on_effect1 != "is_" + effect:
				on_effect_max_duration2 = effect_max_duration
				on_effect2 = "is_knockout"
				is_knockout = true
			else:
				pass
		"bleeding":
			if on_effect1 == "" and on_effect2 !=  "is_" + effect:
				on_effect_max_duration1 = effect_max_duration
				on_effect1 = "is_bleeding"
			elif on_effect2 == "" and on_effect1 != "is_" + effect:
				on_effect_max_duration2 = effect_max_duration
				on_effect2 = "is_bleeding"
			else:
				pass
		"blind":
			if on_effect1 == "" and on_effect1 != "is_" + effect:
				on_effect_max_duration1 = effect_max_duration
				on_effect1 = "is_blind"
				is_blind = true
			elif on_effect2 == "" and on_effect2 != "is_" + effect:
				on_effect_max_duration2 = effect_max_duration
				on_effect2 = "is_blind"
				is_blind = true
			else:
				pass
	enemy_res.current_hp = max(0, enemy_res.current_hp - damage)
	set_health(enemy_1_progress_bar, enemy_res.current_hp, enemy_res.max_hp)
	enemy_1_damage_label.text = str(damage)
	animation_player_text.play(str(name)+"_damage")
func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]


func _on_battle_controller_group_turns_ended() -> void:
	on_effect_duration1 += 1
	match on_effect1:
		"is_bleeding":
			take_damage(5)
	if on_effect_duration1 >= on_effect_max_duration1:
		match on_effect1:
			"blind":
				is_blind = false
			"is_knockout":
				is_knockout = false
		on_effect1 = ""
		on_effect_duration1 = 0

	on_effect_duration2 += 1
	match on_effect2:
		"is_bleeding":
			take_damage(5)
	if on_effect_duration2 >= on_effect_max_duration1:
		match on_effect2:
			"blind":
				is_blind = false
			"is_knockout":
				is_knockout = false
		on_effect2 = ""
		on_effect_duration2 = 0
		

func _physics_process(delta: float) -> void:
	match active_state:
		states.IDLE:
			pass
		states.TAKE_DAMAGE:
			animation_player.play(str(name)+"_take_damage")
			await animation_player.animation_finished
			active_state = states.IDLE
