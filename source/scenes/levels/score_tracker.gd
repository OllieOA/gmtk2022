class_name ScoreTracker extends Resource

var score_data = {}
var best_score_tracker = {}


func add_stroke(level_number: int, strokes_to_add: int) -> void:
	if not score_data.has(level_number):
		score_data[level_number] = 0

	score_data[level_number] += strokes_to_add
	Event.emit_signal("strokes_updated", score_data[level_number])


func set_best_score(level_number: int) -> void:
	if not best_score_tracker.has(level_number):
		best_score_tracker[level_number] = 99

	if score_data[level_number] < best_score_tracker[level_number]:
		best_score_tracker[level_number] = score_data[level_number]