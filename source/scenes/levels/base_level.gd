extends Node2D

export (NodePath) onready var player_reference = get_node(player_reference) as PlayerDice
export (NodePath) onready var block_reference = get_node(block_reference) as Node2D

export (NodePath) onready var ambient_sound = get_node(ambient_sound) as AudioStreamPlayer
export (NodePath) onready var win_sound = get_node(win_sound) as AudioStreamPlayer

export (int) var level_number := 0

var _camera_limit_bottom_right := Vector2.ZERO

const _SCORE_TRACKER_PATH = "user://score_tracker.tres"
var score_tracker: Resource

func _ready() -> void:
	var limit_set := false
	for child in block_reference.get_children():
		if child.is_in_group("terrain"):
			if child.last_block:
				_camera_limit_bottom_right = Vector2(child.bottom_right_limit.global_position.x, 0)
				Event.emit_signal("camera_limit_set", _camera_limit_bottom_right)
				limit_set = true
	
	if not limit_set:
		print("ERROR! NO LAST BLOCK")

	# Load score tracker
	if File.new().file_exists(_SCORE_TRACKER_PATH):
		# Working my ass off here, let's g0000000
		score_tracker = ResourceSaver.load(_SCORE_TRACKER_PATH)
	else:
		score_tracker = ScoreTracker.new()

	Event.connect("player_launched", self, "_handle_player_launched")
	Event.connect("level_won", self, "_handle_level_won")

	ambient_sound.play()

	
func _handle_player_launched(score_to_add: int) -> void:
	score_tracker.add_stroke(level_number, score_to_add)


func _handle_level_won() -> void:
	win_sound.play()
