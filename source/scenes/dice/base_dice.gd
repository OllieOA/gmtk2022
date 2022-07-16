class_name BaseDice extends RigidBody2D

export (NodePath) onready var base_sprite = get_node(base_sprite) as Sprite
export (NodePath) onready var face_sprite = get_node(face_sprite) as Sprite

export (NodePath) onready var launch_bar = get_node(launch_bar) as TextureProgress

onready var dicebag = Dicebag.new()

# Effect modifiers
var _max_power_modifier := 1.0
var _bounce_modifier := 1.0
var _friction_modifier := 1.0
var _score_modifier := 1

# Some variables require resetting
var _reset_bounce: float
var _reset_friction: float

const _MAX_POWER_INCREASE = 1.5
const _MAX_POWER_DECREASE = 0.5
const _FRICTION_DECREASE = 0.5
const _BOUNCE_INCREASE = 1.5

# Terrain modifiers
var _terrain_max_power_modifier := 1.0
var _terrain_friction_modifier := 1.0
var _terrain_linear_damp_modifier := 1.0

# States
enum State {
	START,  # Exit to aiming when ready
	AIMING,  # Enables aiming UI
	LAUNCHING,  
	FLYING,
	ROLLING,  # Enter this state, roll dice, exit to CHANGING_PROPERTIES
	WAITING,  # Utility state for if the AI is still deciding what to do - PLAYER ONLY
	CHANGING_PROPERTIES,  # Enter this state, make change, and exit to AIMING
}

var _state: int = State.START

# Movement variables
const _VELOCITY_STOP_THRESHOLD = 50
var _max_launch_force := 150
var _slowed_enough := false


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	_slowed_enough = linear_velocity.length() < _VELOCITY_STOP_THRESHOLD

	match _state:
		State.START:
			pass

		State.AIMING:
			pass

		State.LAUNCHING:
			pass

		State.FLYING:
			pass

		State.ROLLING:
			pass

		State.WAITING:
			pass

		State.CHANGING_PROPERTIES:
			pass



# CUSTOM METHODS
func _change_face_random():
	# Called by an animation player
	pass
