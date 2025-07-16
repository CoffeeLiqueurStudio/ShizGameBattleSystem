extends Node2D

var pixel_font: Font = preload("res://assets/fonts/NESCyrillic.ttf")
signal group_turns_ended
signal player_animation
signal enemy_animation
@onready var enemy_1_progress_bar: ProgressBar = $CanvasLayer/Panel/HBoxContainer/HpContainer/Enemy1ProgressBar
@onready var player_1_hp_progress_bar: ProgressBar = $CanvasLayer/Panel/HBoxContainer/HpContainer/Player1HpProgressBar
@onready var player_1_mp_progress_bar: ProgressBar = $CanvasLayer/Panel/HBoxContainer/HpContainer/Player1MpProgressBar
@onready var action_container: VBoxContainer = $CanvasLayer/Panel/HBoxContainer/ActionContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skill_container: VBoxContainer = $CanvasLayer/Panel/HBoxContainer/SkillContainer
@onready var action_label: Label = $CanvasLayer/ActionLabel
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var path_2d: Path2D = $Path2D
@onready var enemy_path_2d: Path2D = $enemyPath2D
@onready var enemy_path_follow_2d: PathFollow2D = $enemyPath2D/enemyPathFollow2D


@export var player1_res: Resource = null
@export var enemy1_res: Resource = null

var group_turn = 0
var active_enemy
var active_player
enum states {PLAYER_TURN, ENEMY_TURN}
var active_state = states.PLAYER_TURN
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	action_container.hide()
	active_enemy = get_tree().get_first_node_in_group("enemy")
	active_player = get_tree().get_first_node_in_group("player")
func _physics_process(delta: float) -> void:
	print(active_player.position)
	match active_state:
		states.PLAYER_TURN:
			action_container.show()
		states.ENEMY_TURN:
			action_container.hide()


func player_turn():
	action_container.show()

func enemy_turn():
	if active_state == states.ENEMY_TURN:
		if active_enemy.is_knockout == true:
			await get_tree().create_timer(1).timeout
			change_turn_to_player_group()
			active_state = states.PLAYER_TURN
		else:
			enemy_path_2d.position = active_enemy.position
			enemy_path_2d.curve = Curve2D.new()
			enemy_path_2d.curve.add_point(active_enemy.position)      
			enemy_path_2d.curve.add_point(active_player.position)  
			active_enemy.reparent(enemy_path_follow_2d)
			emit_signal("enemy_animation")
			active_player.take_damage(rng.randi_range(active_enemy.enemy_res.min_damage, active_enemy.enemy_res.max_damage))
			await get_tree().create_timer(1).timeout
			active_state = states.PLAYER_TURN
func _on_attack_button_pressed() -> void:
	if active_state == states.PLAYER_TURN:
		path_2d.position = active_player.position
		path_2d.curve = Curve2D.new()
		path_2d.curve.add_point(active_player.position)      
		path_2d.curve.add_point(active_enemy.position)  
		active_player.reparent(path_follow_2d)
		emit_signal("player_animation")
		active_enemy.take_damage(rng.randi_range(active_player.player_res.min_damage, active_player.player_res.max_damage))
		active_state = states.ENEMY_TURN
		#change_turn_to_enemy_group()
func _on_defend_button_pressed() -> void:
	if active_state == states.PLAYER_TURN:
		active_player.player_res.is_defending = true
		active_state = states.ENEMY_TURN
		change_turn_to_enemy_group()
func _on_skill_button_pressed() -> void:
	skill_container.show()
	populate_skills(player1_res.skills)


func populate_skills(skills_array: Array[MagicSkill]):
	# очистим старые кнопки
	for child in skill_container.get_children():
		child.queue_free()

	for skill in skills_array:
		var btn = Button.new()
		btn.add_theme_font_size_override("font_size", 20)
		btn.add_theme_font_override("font", pixel_font)
		btn.text = "%s (MP: %d)" % [skill.name, skill.mp_cost]
		btn.tooltip_text = skill.effect
		btn.pressed.connect(func(): _on_skill_selected(skill))
		skill_container.add_child(btn)
		
func _on_skill_selected(skill: MagicSkill):
	cast_skill(skill)
	skill_container.visible = false

func cast_skill(skill: MagicSkill):
	if player1_res.current_mp < skill.mp_cost:
		action_label.text = ("Недостаточно MP!")
		return
	player1_res.current_mp -= skill.mp_cost
	# простой эффект — наносим уро1н врагу
	var damage = skill.power
	var effect = skill.effect
	var effect_max_duration = skill.max_effect_duration
	active_player.set_mana()
	active_enemy.take_effect_damage(damage, effect, effect_max_duration)
	action_label.text = ("Player use %s! and damage %d to enemy and apply effect %s!" % [skill.name, damage, skill.effect])
	change_turn_to_enemy_group()

func change_turn_to_enemy_group():
	await get_tree().create_timer(1).timeout
	active_state = states.ENEMY_TURN
	group_turn += 1
	enemy_turn()
	if group_turn >= 2:
		emit_signal('group_turns_ended')
		group_turn = 0
func change_turn_to_player_group():
	await get_tree().create_timer(1).timeout
	active_state = states.PLAYER_TURN
	group_turn += 1
	player_turn()
	if group_turn >= 2:
		emit_signal('group_turns_ended')
		group_turn = 0
		

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]


func _on_path_2d_player_animation_end() -> void:
	active_player.reparent(self)
	change_turn_to_enemy_group()



func _on_enemy_path_2d_enemy_animation_end() -> void:
	active_enemy.reparent(self)
	change_turn_to_player_group()
