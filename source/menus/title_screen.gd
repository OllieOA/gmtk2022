class_name TitleScreen extends Control

export (NodePath) onready var start_box = get_node(start_box) as VBoxContainer
export (NodePath) onready var level_select_box = get_node(level_select_box) as VBoxContainer
export (NodePath) onready var credits_box = get_node(credits_box) as MarginContainer
export (NodePath) onready var level_select_grid = get_node(level_select_grid) as GridContainer

const _SCORE_TRACKER_PATH = "user://score_tracker.tres"
var score_tracker: Resource

# var cloud_generator =

func _ready() -> void:
	credits_box.hide()
	start_box.show()
	level_select_box.hide()

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
