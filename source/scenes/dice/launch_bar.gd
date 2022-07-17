class_name LaunchBar extends Node2D

export (NodePath) onready var launch_bar = get_node(launch_bar) as TextureProgress

var max_value := 100.0 setget set_max_value
var my_dice: BaseDice
var launch_bar_offset: Vector2
var launch_vector: Vector2

const _LAUNCH_BAR_FACTOR = 3.5

# Custom init
func init_launch_bar() -> void:
	launch_bar.max_value = max_value
	launch_bar_offset = global_position - my_dice.global_position

	set_as_toplevel(true)

# ENGINE CALLBACKS
func _ready() -> void:
	hide_launch_bar()


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
	launch_bar.max_value = value


func show_launch_bar() -> void:
	launch_bar.show()


func hide_launch_bar() -> void:
	launch_bar.hide()
