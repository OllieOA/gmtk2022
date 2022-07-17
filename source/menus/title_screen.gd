class_name TitleScreen extends Control

export (NodePath) onready var start_box = get_node(start_box) as VBoxContainer
export (NodePath) onready var level_select_box = get_node(level_select_box) as VBoxContainer

# var cloud_generator =

func _ready() -> void:
	start_box.show()
	level_select_box.hide()


func _on_start_game_button_pressed() -> void:
	start_box.hide()
	level_select_box.show()
