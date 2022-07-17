extends Button

export (int) var target_level_number := 0
export (NodePath) onready var best_text = get_node(best_text) as Label


func _ready() -> void:
	pass


func _on_base_level_pressed() -> void:
	var level_to_load = "level%d" % target_level_number
	SceneManager.load_scene(level_to_load)


func set_best_text(text: String) -> void:
	best_text.text = text