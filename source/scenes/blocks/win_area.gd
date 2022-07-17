class_name WinArea extends Area2D


func _ready() -> void:
	Event.emit_signal("win_area_loaded", global_position)
