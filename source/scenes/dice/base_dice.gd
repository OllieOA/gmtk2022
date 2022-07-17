class_name BaseDice extends RigidBody2D

export (NodePath) onready var base_sprite = get_node(base_sprite) as Sprite
export (NodePath) onready var face_sprite = get_node(face_sprite) as Sprite

export (NodePath) onready var launch_bar = get_node(launch_bar) as Node2D

export (NodePath) onready var rolling_animator = get_node(rolling_animator) as AnimationPlayer

onready var dicebag = Dicebag.new()

# Effect modifiers
var _max_power_modifier := 1.0 setget _set_max_power
var _bounce_modifier := 1.0 setget _set_bounce_modifier
var _friction_modifier := 1.0 setget _set_friction_modifier
var _score_modifier := 1 setget _set_score_modifier

# Need to be programmatic
var _bounce_modifier_base: float
var _friction_modifier_base: float

const _MAX_POWER_INCREASE = 1.5
const _MAX_POWER_DECREASE = 0.5
const _FRICTION_DECREASE = 0.5
const _BOUNCE_INCREASE = 1.5

# Effects
#	This is a dictionary of a set method and a reset method, with their binds
const _EFFECTS = {
	1: [["_set_max_power", _MAX_POWER_DECREASE], ["_set_max_power", 1.0]],
	2: [["_set_score_modifier", 2], ["_set_score_modifier", 1]],
	3: [["_set_bounce_modifier", _BOUNCE_INCREASE], ["_set_bounce_modifier", 1.0]],
	4: [["_set_friction_modifier", _FRICTION_DECREASE], ["_set_friction_modifier", 1.0]],
	5: [["_set_score_modifier", 0], ["_set_score_modifier", 1]],
	6: [["_set_max_power", _MAX_POWER_INCREASE], ["_set_max_power", 1.0]],
}

var _set_method := []
var _reset_method := []

# Terrain modifiers
var _terrain_launch_power_modifier := 1.0
var _terrain_friction_modifier := 1.0
var _terrain_linear_damp_modifier := 1.0

# States
enum State {
	START,  # Exit to aiming when ready
	AIMING,  # Enables aiming UI
	FLYING,
	LANDED,  # Starts the random rolling
	ROLLING,  # Enter this state, roll dice, exit to CHANGING_PROPERTIES
	WAITING,  # Utility state for if the AI is still deciding what to do - PLAYER ONLY
	AI_WAITING,
	CHANGING_PROPERTIES,  # Enter this state, make change, and exit to AIMING
}

const _NEXT_PLAYER_STATE = {
	State.CHANGING_PROPERTIES: State.AIMING,
}

const _NEXT_AI_STATE = {
	State.CHANGING_PROPERTIES: State.AI_WAITING,
}

var _state: int = State.START

# Movement variables
const _VELOCITY_STOP_THRESHOLD = 2
const _BASE_LAUNCH_THRUST := 150
var _slowed_enough := false

# Display stuff
var _launch_bar_offset: Vector2
var _face_value := 0

# END OF VARIABLES

func _ready() -> void:
	# Dependency injection
	launch_bar.my_dice = self
	launch_bar.init_launch_bar()

	# Get physics modifier resets
	_bounce_modifier_base = physics_material_override.bounce
	_friction_modifier_base = physics_material_override.friction


func _physics_process(_delta: float) -> void:
	_slowed_enough = linear_velocity.length() < _VELOCITY_STOP_THRESHOLD

	match _state:
		State.START:
			_state = State.AIMING  # TODO: REPLACE WITH SIGNAL

		State.AIMING:
			launch_bar.show_launch_bar()

		State.FLYING:
			# Launched by launce_dice() method
			pass

		State.LANDED:
			rolling_animator.play("random_rolling")
			_state = State.ROLLING

		State.ROLLING:
			rolling_animator.playback_speed = clamp(1 - pow(_VELOCITY_STOP_THRESHOLD / linear_velocity.length(), 2), 0, 1)
			if _slowed_enough:
				rolling_animator.playback_speed = 1.0
				linear_damp = 10
				rolling_animator.stop()
				_state = State.CHANGING_PROPERTIES

		State.WAITING:
			_state = State.AIMING

		State.AI_WAITING:
			pass

		State.CHANGING_PROPERTIES:
			if _reset_method != []:
				call(_reset_method[0], _reset_method[1])

			_set_method = _EFFECTS[_face_value][0]
			_reset_method = _EFFECTS[_face_value][1]

			call(_set_method[0], _set_method[1])

			next_state()


func _process(_delta: float) -> void:
	pass


# CUSTOM METHODS
func _change_face_random():
	var new_value = dicebag.roll_dice(1, 6, 0)
	face_sprite.frame = new_value
	_face_value = new_value


func launch_dice(normal_launch_vector: Vector2, launch_factor) -> void:
	launch_bar.hide_launch_bar()
	linear_damp = -1

	var launch_thrust = normal_launch_vector * _BASE_LAUNCH_THRUST * launch_factor * _terrain_launch_power_modifier
	
	apply_central_impulse(launch_thrust)
	
	if dicebag.flip_coin():
		apply_torque_impulse(100000)
	else:
		apply_torque_impulse(-100000)
	
	Event.emit_signal("player_launched")
	_state = State.FLYING


func next_state() -> void:
	if is_in_group("player"):
		_state = _NEXT_PLAYER_STATE[_state]
	else:
		_state = _NEXT_AI_STATE[_state]


func _update_physics_material() -> void:
	physics_material_override.bounce = _bounce_modifier * _bounce_modifier_base
	physics_material_override.friction = _friction_modifier * _friction_modifier_base


func _on_base_dice_body_entered(body: Node) -> void:
	if body.is_in_group("terrain") and _state == State.FLYING:
		# TODO: ADD TERRAIN MODIFIERS
		print("CHANGING STATE TO LANDED")
		_state = State.LANDED

# SETTERS AND GETTERS

func _set_max_power(val: float) -> void:
	_max_power_modifier = val
	print("NEW MAX POWER: ", _max_power_modifier)
	
	
func _set_bounce_modifier(val: float) -> void:
	_bounce_modifier = val
	_update_physics_material()
	print("NEW BOUNCE MODIFIER: ", _bounce_modifier)


func _set_friction_modifier(val: float) -> void:
	_friction_modifier = val
	_update_physics_material()
	print("NEW FRICTION MODIFIER: ", _friction_modifier)


func _set_score_modifier(val: int) -> void:
	_score_modifier = val
	print("NEW SCORE MODIFIER: ", _score_modifier)



