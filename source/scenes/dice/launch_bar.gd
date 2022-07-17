class_name LaunchBar extends Node2D

export (NodePath) onready var launch_bar = get_node(launch_bar) as TextureProgress

var _BASE_MAX_VALUE = 100.0
var max_value := 100.0 setget set_max_value
var my_dice: BaseDice
var launch_bar_offset: Vector2
var launch_vector: Vector2

const _LAUNCH_BAR_FACTOR = 3.0

enum Modifiers {
	HALF,
	NORMAL,
	MORE,
}

const _BASE_BAR_LOOKUP = {
	Modifiers.HALF: preload("res://assets/dice/launch_bar_base_half.png"),
	Modifiers.NORMAL: preload("res://assets/dice/launch_bar_base_normal.png"),
	Modifiers.MORE: preload("res://assets/dice/launch_bar_base_more.png"),
}

const _FILL_BAR_LOOKUP = {
	Modifiers.HALF: preload("res://assets/dice/launch_bar_fill_half.png"),
	Modifiers.NORMAL: preload("res://assets/dice/launch_bar_fill_normal.png"),
	Modifiers.MORE: preload("res://assets/dice/launch_bar_fill_more.png"),
}

const _FILL_BAR_COLORS = {
	Modifiers.HALF: Color("475981"),  # BLUE
	Modifiers.NORMAL: Color("ff8600"),  # YELLOW
	Modifiers.MORE: Color("f10d0d"),  # RED
}

# Custom init
func init_launch_bar() -> void:
	launch_bar.max_value = max_value
	launch_bar_offset = global_position - my_dice.global_position

	set_as_toplevel(true)

# ENGINE CALLBACKS
func _ready() -> void:
	hide_launch_bar()
	Event.connect("max_power_modifier_updated", self, "_handle_max_power_update")
	_handle_max_power_update(1.0)


func _process(_delta: float) -> void:
	if launch_bar.visible:	
		global_position = my_dice.global_position + launch_bar_offset
		launch_vector = get_global_mouse_position() - position
		launch_bar.rect_rotation = rad2deg(launch_vector.angle() + PI)

		if Input.is_action_pressed("launch_click"):
			launch_bar.value = -20 + global_position.distance_to(get_global_mouse_position()) / _LAUNCH_BAR_FACTOR

		if Input.is_action_just_released("launch_click"):
			my_dice.launch_dice(launch_vector.normalized().rotated(PI), launch_bar.value)


# SETTERS AND GETTERS
func set_max_value(value: float) -> void:
	launch_bar.value = value * _BASE_MAX_VALUE
	launch_bar.max_value = value * _BASE_MAX_VALUE


func show_launch_bar() -> void:
	launch_bar.show()


func hide_launch_bar() -> void:
	launch_bar.hide()


# SIGNAL HANDLING

func _handle_max_power_update(new_val: float) -> void:
	set_max_value(new_val)
	if new_val == 1.0:
		launch_bar.texture_under = _BASE_BAR_LOOKUP[Modifiers.NORMAL]
		launch_bar.texture_progress = _BASE_BAR_LOOKUP[Modifiers.NORMAL]
		launch_bar.modulate = _FILL_BAR_COLORS[Modifiers.NORMAL]
	elif new_val < 1.0:
		launch_bar.texture_under = _BASE_BAR_LOOKUP[Modifiers.HALF]
		launch_bar.texture_progress = _BASE_BAR_LOOKUP[Modifiers.HALF]
		launch_bar.modulate = _FILL_BAR_COLORS[Modifiers.HALF]
	else:
		launch_bar.texture_under = _BASE_BAR_LOOKUP[Modifiers.MORE]
		launch_bar.texture_progress = _BASE_BAR_LOOKUP[Modifiers.MORE]
		launch_bar.modulate = _FILL_BAR_COLORS[Modifiers.MORE]