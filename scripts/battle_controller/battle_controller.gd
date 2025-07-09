extends Node2D
@onready var enemy1_progress_bar: ProgressBar = $CanvasLayer/HBoxContainer/HpContainer/Enemy1ProgressBar
@onready var player1_progress_bar: ProgressBar = $CanvasLayer/HBoxContainer/HpContainer/Player1ProgressBar
@onready var action_container: VBoxContainer = $CanvasLayer/HBoxContainer/ActionContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var player1_res: Resource = null
@export var enemy1_res: Resource = null

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
	match active_state:
		states.PLAYER_TURN:
			action_container.show()
		states.ENEMY_TURN:
			action_container.hide()

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]

func player_turn():
	action_container.show()

func enemy_turn():
	if active_state == states.ENEMY_TURN:
		active_player.take_damage(rng.randf_range(active_enemy.enemy_res.min_damage, active_enemy.enemy_res.max_damage))
		await get_tree().create_timer(1).timeout
		active_state = states.PLAYER_TURN
		player_turn()
func _on_attack_button_pressed() -> void:
	if active_state == states.PLAYER_TURN:
		active_enemy.take_damage(rng.randf_range(active_player.player_res.min_damage, active_player.player_res.max_damage))
		active_state = states.ENEMY_TURN
		await get_tree().create_timer(1).timeout
		enemy_turn()
func _on_defend_button_pressed() -> void:
	if active_state == states.PLAYER_TURN:
		active_player.player_res.is_defending = true
		active_state = states.ENEMY_TURN
		await get_tree().create_timer(1).timeout
		enemy_turn()
