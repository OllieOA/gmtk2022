extends Node2D

export (NodePath) onready var player_reference = get_node(player_reference) as PlayerDice
export (NodePath) onready var block_reference = get_node(block_reference) as Node2D

var _camera_limit_bottom_right := Vector2.ZERO


func _ready() -> void:
	var limit_set := false
	for child in block_reference.get_children():
		if child.is_in_group("terrain"):
			if child.last_block:
				_camera_limit_bottom_right = Vector2(child.bottom_right_limit.x, 0)
				Event.emit_signal("camera_limit_set", _camera_limit_bottom_right)
				limit_set = true

	if not limit_set:
		print("ERROR! NO LAST BLOCK")
