extends Node

export (NodePath) onready var ambient_sound = get_node(ambient_sound) as AudioStreamPlayer


func _ready() -> void:
	ambient_sound.play()
