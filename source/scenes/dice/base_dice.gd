class_name BaseDice extends RigidBody2D

export (NodePath) onready var base_sprite = get_node(base_sprite) as Sprite
export (NodePath) onready var face_sprite = get_node(face_sprite) as Sprite

export (NodePath) onready var launch_bar = get_node(launch_bar) as Node2D

export (NodePath) onready var rolling_animator = get_node(rolling_animator) as AnimationPlayer

export (NodePath) onready var hit_sound = get_node(hit_sound) as AudioStreamPlayer
export (NodePath) onready var roll_sound = get_node(roll_sound) as AudioStreamPlayer

export (NodePath) onready var grass_sound = get_node(grass_sound) as AudioStreamPlayer
var grass_sound_timeout := true
var grass_sound_timeout_timer: Timer

onready var dicebag = Dicebag.new()

# Effect modifiers
var _max_power_modifier := 1.0 setget _set_max_power
var _bounce_modifier := 1.0 setget _set_bounce_modifier
var _friction_modifier := 1.0 setget _set_friction_modifier
var _score_modifier := 1 setget _set_score_modifier

# Need to be programmatic
var _bounce_modifier_base: float
var _friction_modifier_base: float

const _MAX_POWER_INCREASE = 1.4
const _MAX_POWER_DECREASE = 0.7
const _FRICTION_DECREASE = 0.1
const _BOUNCE_INCREASE = 2.0

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
	WON,
}

const _NEXT_PLAYER_STATE = {
	State.CHANGING_PROPERTIES: State.AIMING,
}

const _NEXT_AI_STATE = {
	State.CHANGING_PROPERTIES: State.AI_WAITING,
}

var _state: int = State.START

# Movement variables
const _VELOCITY_STOP_THRESHOLD = 5
const _BASE_LAUNCH_THRUST := 150
var _slowed_enough := false

# Display stuff
var _launch_bar_offset: Vector2
var _face_value := 0

# END OF VARIABLES

func _ready() -> void:
	dicebag.set_up_rng()
	# Dependency injection
	launch_bar.my_dice = self
	launch_bar.init_launch_bar()

	# Get physics modifier resets
	_bounce_modifier_base = physics_material_override.bounce
	_friction_modifier_base = physics_material_override.friction

	Event.connect("level_won", self, "_handle_level_won")

	grass_sound_timeout_timer = Timer.new()
	grass_sound_timeout_timer.wait_time = 0.5
	grass_sound_timeout_timer.one_shot = true
	grass_sound_timeout_timer.connect("timeout", self, "_handle_grass_timeout")
	add_child(grass_sound_timeout_timer)


func _physics_process(_delta: float) -> void:
	_slowed_enough = linear_velocity.length() < _VELOCITY_STOP_THRESHOLD

	match _state:
		State.START:
			apply_random_torque(50000)
			rolling_animator.play("random_rolling")
			roll_sound.play()
			_state = State.ROLLING

		State.AIMING:
			launch_bar.show_launch_bar()

		State.FLYING:
			# Launched by launce_dice() method
			pass

		State.LANDED:
			rolling_animator.play("random_rolling")
			roll_sound.play()
			_state = State.ROLLING

		State.ROLLING:
			rolling_animator.playback_speed = clamp(1 - pow(_VELOCITY_STOP_THRESHOLD / linear_velocity.length(), 2), 0, 1)
			if _slowed_enough:
				rolling_animator.playback_speed = 1.0
				linear_damp = 10
				angular_damp = 10
				rolling_animator.stop()
				roll_sound.stop()
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

			Event.emit_signal("active_effect_changed", _face_value)

			call(_set_method[0], _set_method[1])

			next_state()

		State.WON:
			launch_bar.hide_launch_bar()
			roll_sound.stop()
			rolling_animator.stop()


func _process(_delta: float) -> void:
	pass


# CUSTOM METHODS
func _change_face_random():
	var new_value = dicebag.roll_dice(1, 6, 0)
	face_sprite.frame = new_value
	_face_value = new_value


func launch_dice(normal_launch_vector: Vector2, launch_factor) -> void:
	hit_sound.play()
	launch_bar.hide_launch_bar()
	linear_damp = -1
	angular_damp = -1

	print("TERRAIN_MOD = ", _terrain_launch_power_modifier)
	var launch_thrust = normal_launch_vector * _BASE_LAUNCH_THRUST * launch_factor * _terrain_launch_power_modifier
	
	apply_central_impulse(launch_thrust)
	
	apply_random_torque(100000)
	
	if is_in_group("player"):
		Event.emit_signal("player_launched", _score_modifier)
		_state = State.FLYING


func apply_random_torque(amount: float) -> void:
	if dicebag.flip_coin():  # Add random torque to encourage a roll
		apply_torque_impulse(amount)
	else:
		apply_torque_impulse(-amount)


func next_state() -> void:
	if is_in_group("player"):
		_state = _NEXT_PLAYER_STATE[_state]
	else:
		_state = _NEXT_AI_STATE[_state]


func _update_physics_material() -> void:
	physics_material_override.bounce = _bounce_modifier * _bounce_modifier_base
	physics_material_override.friction = _friction_modifier * _friction_modifier_base


func _on_base_dice_body_entered(body: Node) -> void:
	if _state == State.FLYING:
		if body.is_in_group("terrain"):
			_state = State.LANDED
	else:
		if body.is_in_group("terrain"):
			if body.is_in_group("rough"):
				Event.emit_signal("terrain_effect_changed", BaseWorldBlock.TerrainType.ROUGH)
				_terrain_launch_power_modifier = BaseWorldBlock.TERRAIN_MODIFIERS[BaseWorldBlock.TerrainType.ROUGH]
			elif body.is_in_group("green"):
				Event.emit_signal("terrain_effect_changed", BaseWorldBlock.TerrainType.GREEN)
				_terrain_launch_power_modifier = BaseWorldBlock.TERRAIN_MODIFIERS[BaseWorldBlock.TerrainType.GREEN]
			elif body.is_in_group("fairway"):
				Event.emit_signal("terrain_effect_changed", BaseWorldBlock.TerrainType.FAIRWAY)
				_terrain_launch_power_modifier = BaseWorldBlock.TERRAIN_MODIFIERS[BaseWorldBlock.TerrainType.FAIRWAY]
			elif body.is_in_group("bunker"):
				Event.emit_signal("terrain_effect_changed", BaseWorldBlock.TerrainType.BUNKER)
				_terrain_launch_power_modifier = BaseWorldBlock.TERRAIN_MODIFIERS[BaseWorldBlock.TerrainType.BUNKER]

	if linear_velocity.length() > 200 and grass_sound_timeout:
		grass_sound_timeout_timer.start()
		grass_sound.play()
		grass_sound_timeout = false
	

func _handle_level_won() -> void:
	_state = State.WON


func _handle_grass_timeout() -> void:
	grass_sound_timeout = true


# SETTERS AND GETTERS

func _set_max_power(val: float) -> void:
	_max_power_modifier = val
	Event.emit_signal("max_power_modifier_updated", _max_power_modifier)
	# print("NEW MAX POWER: ", _max_power_modifier)
	
	
func _set_bounce_modifier(val: float) -> void:
	_bounce_modifier = val
	_update_physics_material()
	# print("NEW BOUNCE MODIFIER: ", _bounce_modifier)


func _set_friction_modifier(val: float) -> void:
	_friction_modifier = val
	_update_physics_material()
	# print("NEW FRICTION MODIFIER: ", _friction_modifier)


func _set_score_modifier(val: int) -> void:
	_score_modifier = val
	# print("NEW SCORE MODIFIER: ", _score_modifier)



