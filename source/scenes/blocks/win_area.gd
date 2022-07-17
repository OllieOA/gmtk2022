class_name WinArea extends Area2D


var level_won := false


func _ready() -> void:
	Event.emit_signal("win_area_loaded", global_position)
	

func _on_win_area_body_entered(body:Node) -> void:
	if body.is_in_group("player") and not level_won:
		level_won = true
		Event.emit_signal("level_won")
