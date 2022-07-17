class_name ZoomingCamera2D extends Camera2D


export var min_zoom := 1.5
export var max_zoom := 3.0
export var zoom_factor := 0.2
export var zoom_duration := 0.2


var _zoom_level := 1.5 setget _set_zoom_level
var full_zoom_camera_pos := Vector2(0, 0)
var required_full_zoom := 10.0
var looking_at_map := false

var map_centre := Vector2(0.0, 0.0)

onready var player_reference := get_parent()
export (NodePath) onready var zoom_tween = get_node(zoom_tween) as Tween
export (NodePath) onready var pos_tween = get_node(pos_tween) as Tween


func _ready() -> void:
	Event.connect("level_setup_complete", self, "_handle_level_setup")


func _process(delta: float) -> void:
	if not looking_at_map:
		global_position = lerp(global_position, player_reference.global_position, 0.2)


# Setting and handling
func _set_zoom_level(value: float) -> void:
	_zoom_level = clamp(value, min_zoom, max_zoom)
	_use_zoom_tween(_zoom_level)


func _handle_level_setup(full_rect: Rect2) -> void:
	var full_rect_top_left = full_rect.position
	var full_rect_bottom_right = full_rect.size

	var full_rect_x = full_rect_bottom_right.x - full_rect_top_left.x
	var full_rect_y = full_rect_bottom_right.y - full_rect_top_left.y
	
	full_zoom_camera_pos = Vector2(full_rect_x / 2.0, full_rect_y / 2.0)
	var current_viewport_size = get_viewport_rect().size
	
	var x_zoom_factor = full_rect_x / current_viewport_size.x
	var y_zoom_factor = full_rect_y / current_viewport_size.y

	required_full_zoom = max(x_zoom_factor, y_zoom_factor) * 1.2


# TWEENING
func _use_zoom_tween(zoom_val):
	zoom_tween.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(zoom_val, zoom_val),
		zoom_duration,
		zoom_tween.TRANS_SINE,
		zoom_tween.EASE_OUT
	)
	zoom_tween.start()


func _use_pos_tween(desired_pos):
	pos_tween.interpolate_property(
		self,
		"global_position",
		global_position,
		desired_pos,
		zoom_duration,
		pos_tween.TRANS_SINE,
		pos_tween.EASE_OUT
	)
	pos_tween.start()


func _input(event):
	if event.is_action_pressed("zoom_in"):
		if _zoom_level <= max_zoom and not looking_at_map:
			_set_zoom_level(_zoom_level - zoom_factor)
		elif looking_at_map:
			_return_from_map()
	if event.is_action_pressed("zoom_out"):
		if _zoom_level < max_zoom:
			_set_zoom_level(_zoom_level + zoom_factor)
		elif _zoom_level == max_zoom and not looking_at_map:
			_centre_map()
			
			
func _centre_map() -> void:
	looking_at_map = true
	_use_zoom_tween(required_full_zoom)
	_use_pos_tween(full_zoom_camera_pos)


func _return_from_map() -> void:
	looking_at_map = false
	_use_zoom_tween(max_zoom)
	_use_pos_tween(player_reference.global_position)