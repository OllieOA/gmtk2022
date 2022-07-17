class_name Cloud extends Node2D

export (NodePath) onready var sprite = get_node(sprite) as Sprite
var rng = RandomNumberGenerator.new()

const _MOVE_SPEED = 100

const _KILL_AT = -300

func _ready() -> void:
	rng.randomize()
	if rng.randf() < 0.65:
		queue_free()


func _process(delta) -> void:
	global_position -= Vector2(delta * _MOVE_SPEED, 0)
	if global_position.x < _KILL_AT:
		queue_free()


func set_frame(frame_num: int) -> void:
	sprite.frame = frame_num

