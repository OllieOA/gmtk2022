extends Node2D

export (NodePath) onready var player_reference = get_node(player_reference) as PlayerDice
export (NodePath) onready var block_reference = get_node(block_reference) as Node2D

export (NodePath) onready var win_sound = get_node(win_sound) as AudioStreamPlayer

export (NodePath) onready var cloud_layer = get_node(cloud_layer) as Node2D
export (PackedScene) var cloud_generator

var rng = RandomNumberGenerator.new()

export (int) var level_number := 0
export (String) var next_scene := ""

var _camera_limit_bottom_right := Vector2.ZERO
const _MAX_CLOUD_HEIGHT = -8192
const _MIN_CLOUD_HEIGHT = -1024
var _max_cloud_width
var cloud_timer = Timer.new()

var cloud_step := 200
var cloud_x := 0
var num_clouds: int
var y_spawn_pos: int
var new_cloud: Cloud

const _SCORE_TRACKER_PATH = "user://score_tracker.tres"
var score_tracker: Resource

func _ready() -> void:
	rng.randomize()
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
		score_tracker = ResourceLoader.load(_SCORE_TRACKER_PATH)
	else:
		score_tracker = ScoreTracker.new()

	score_tracker.refresh_score(level_number)


	Event.connect("player_launched", self, "_handle_player_launched")
	Event.connect("level_won", self, "_handle_level_won")
	Event.connect("next_level_requested", self, "_handle_next_level_requested")

	Event.emit_signal("update_best", score_tracker.get_best_score(level_number))
	Event.emit_signal("level_setup_complete", level_number)

	# Init clouds

	while cloud_x <= _camera_limit_bottom_right.x:
		cloud_x += cloud_step * (rng.randf() + 0.5)

		num_clouds = rng.randi_range(2, 5)
		for _i in range(num_clouds):
			y_spawn_pos = rng.randi_range(_MAX_CLOUD_HEIGHT, _MIN_CLOUD_HEIGHT)

			new_cloud = cloud_generator.instance()
			cloud_layer.add_child(new_cloud)
			if new_cloud != null:
				new_cloud.global_position = Vector2(cloud_x, y_spawn_pos)
				new_cloud.set_frame(rng.randi_range(0, 6))
				new_cloud.z_index = -10

	cloud_timer.wait_time = 2.0
	cloud_timer.one_shot = false
	add_child(cloud_timer)
	cloud_timer.connect("timeout", self, "_spawn_cloud")
	cloud_timer.start()


func _process(delta: float) -> void:
	if player_reference.global_position.y > 10:
		SceneManager.load_scene("level%d" % level_number)

	if Input.is_action_pressed("restart"):
		SceneManager.load_scene("level%d" % level_number)

	elif Input.is_action_pressed("quit_to_menu"):
		SceneManager.load_scene("title_screen")

	
func _handle_player_launched(score_to_add: int) -> void:
	score_tracker.add_stroke(level_number, score_to_add)


func _handle_level_won() -> void:
	score_tracker.set_best_score(level_number)
	var result = ResourceSaver.save(_SCORE_TRACKER_PATH, score_tracker)
	assert(result == OK)
	win_sound.play()


func _handle_next_level_requested() -> void:
	SceneManager.load_scene(next_scene)


func _spawn_cloud() -> void:
	num_clouds = rng.randi_range(2, 5)
	for _i in range(num_clouds):
		y_spawn_pos = rng.randi_range(_MAX_CLOUD_HEIGHT, _MIN_CLOUD_HEIGHT)

		new_cloud = cloud_generator.instance()
		cloud_layer.add_child(new_cloud)
		if new_cloud != null:
			new_cloud.global_position = Vector2(_camera_limit_bottom_right.x + 100.0, y_spawn_pos)
			new_cloud.set_frame(rng.randi_range(0, 6))
			new_cloud.z_index = -10