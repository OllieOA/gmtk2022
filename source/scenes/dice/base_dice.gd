class_name BaseDice extends RigidBody2D

export (NodePath) onready var base_sprite = get_node(base_sprite) as Sprite
export (NodePath) onready var face_sprite = get_node(face_sprite) as Sprite

onready var dicebag = Dicebag.new()


enum State {
	START,
	AIMING,  # Enables aiming UI
	LAUNCHING,  
	FLYING,
	ROLLING,  # Enter this state, roll dice, exit to CHANGING_PROPERTIES
	WAITING,  # Utility state for if the AI is still deciding what to do - PLAYER ONLY
	CHANGING_PROPERTIES,  # Enter this state, make change, and exit to AIMING
}

var _state: int = State.START


func _ready() -> void:
	pass # Replace with function body.


func _physics_process(_delta: float) -> void:
	pass


# CUSTOM METHODS
func _change_face_random():
	# Called by an animation player
	pass
