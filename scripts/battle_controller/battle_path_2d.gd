extends Path2D
@onready var path_follow_2d: PathFollow2D = $PlayerPathFollow2D
signal player_animation_end
var active_player
var animation_player
enum states {idle, attack, move_on, move_off}
var active_state = states.idle
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	active_player = get_tree().get_first_node_in_group("player")
	animation_player = active_player.find_child(str(active_player.name) + "AnimationPlayer", true, false)
	animation_player.play("idle")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match active_state:
		states.idle:
			animation_player.play("idle")
		states.move_on:
			animation_player.play("move")
			path_follow_2d.progress += 20.0
		states.move_off:
			animation_player.play("idle")
			path_follow_2d.progress -= 20.0
			if path_follow_2d.progress_ratio == 0.0:
				active_state = states.idle
				emit_signal("player_animation_end")
		states.attack:
			animation_player.play("attack")
			await animation_player.animation_finished
			active_state = states.move_off

	if path_follow_2d.progress_ratio >= 0.8:
		if active_state == states.move_on:
			active_state = states.attack
			await animation_player.animation_finished
			active_state = states.move_off

func _on_battle_controller_player_animation() -> void:
	active_state = states.move_on
