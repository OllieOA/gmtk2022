class_name TitleScreen extends Control

export (NodePath) onready var start_box = get_node(start_box) as VBoxContainer
export (NodePath) onready var level_select_box = get_node(level_select_box) as VBoxContainer
export (NodePath) onready var credits_box = get_node(credits_box) as MarginContainer
export (NodePath) onready var level_select_grid = get_node(level_select_grid) as GridContainer
export (NodePath) onready var cloud_layer = get_node(cloud_layer) as Node2D


export (PackedScene) var cloud_generator
var rng = RandomNumberGenerator.new()

const _SCORE_TRACKER_PATH = "user://score_tracker.tres"
var score_tracker: Resource

var cloud_timer = Timer.new()

var cloud_step := 200
var cloud_x := 0
var num_clouds: int
var y_spawn_pos: int
var new_cloud: Cloud

var screen_rect: Rect2


func _ready() -> void:
	credits_box.hide()
	start_box.show()
	level_select_box.hide()
	screen_rect = get_viewport_rect()

	# Load score tracker
	if File.new().file_exists(_SCORE_TRACKER_PATH):
		# Working my ass off here, let's g0000000
		score_tracker = ResourceLoader.load(_SCORE_TRACKER_PATH)
	else:
		score_tracker = ScoreTracker.new()

	# GET BEST SCORES
	for child in level_select_grid.get_children():
		var best_score_for_level = score_tracker.get_best_score(child.target_level_number)
		if best_score_for_level == -1:
			var text_to_set = "Best: --"
			child.set_best_text(text_to_set)
		else:
			var text_to_set = "Best: %d" % best_score_for_level
			child.set_best_text(text_to_set)

	# Make clouds!
	while cloud_x <= screen_rect.size.x:
		cloud_x += cloud_step * (rng.randf() + 0.5)

		num_clouds = rng.randi_range(2, 5)
		for _i in range(num_clouds):
			y_spawn_pos = rng.randi_range(0, screen_rect.size.y)

			new_cloud = cloud_generator.instance()
			cloud_layer.add_child(new_cloud)
			if new_cloud != null:
				new_cloud.global_position = Vector2(cloud_x, y_spawn_pos)
				new_cloud.set_frame(rng.randi_range(0, 6))
				new_cloud.sprite.scale = Vector2(0.6, 0.6)
				new_cloud.z_index = -10

	cloud_timer.wait_time = 2.0
	cloud_timer.one_shot = false
	add_child(cloud_timer)
	cloud_timer.connect("timeout", self, "_spawn_cloud")
	cloud_timer.start()


func _on_start_game_button_pressed() -> void:
	start_box.hide()
	level_select_box.show()


func _on_credits_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		credits_box.show()
	else:
		credits_box.hide()


func _on_back_button_pressed() -> void:
	level_select_box.hide()
	start_box.show()


func _spawn_cloud() -> void:
	num_clouds = rng.randi_range(2, 5)
	for _i in range(num_clouds):
		y_spawn_pos = rng.randi_range(0, screen_rect.size.y)
		new_cloud = cloud_generator.instance()
		cloud_layer.add_child(new_cloud)
		if new_cloud != null:
			new_cloud.global_position = Vector2(screen_rect.size.x + 150.0, y_spawn_pos)
			new_cloud.set_frame(rng.randi_range(0, 6))
			new_cloud.sprite.scale = Vector2(0.6, 0.6)
			new_cloud.z_index = -10