class_name ScoreTracker extends Resource

export var score_data = {}
export var best_score_tracker = {}


func refresh_score(level_number: int) -> void:
		score_data[level_number] = 0


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

	Event.emit_signal("update_best", get_best_score(level_number))


func get_best_score(level_number: int) -> int:
	if best_score_tracker.has(level_number):
		return best_score_tracker[level_number]
	else:
		return -1