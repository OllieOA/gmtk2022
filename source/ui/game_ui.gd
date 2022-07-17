class_name GameUI extends CanvasLayer

export (NodePath) onready var active_dice_effect_icon = get_node(active_dice_effect_icon) as TextureRect
export (NodePath) onready var active_dice_effect_text = get_node(active_dice_effect_text) as Label

export (NodePath) onready var terrain_effect_icon = get_node(terrain_effect_icon) as TextureRect
export (NodePath) onready var terrain_effect_text = get_node(terrain_effect_text) as Label

export (NodePath) onready var score_current = get_node(score_current) as Label
export (NodePath) onready var score_best = get_node(score_best) as Label
export (NodePath) onready var hole_number = get_node(hole_number) as Label

export (NodePath) onready var dice_effect_small_icons = get_node(dice_effect_small_icons)
export (NodePath) onready var terrain_effect_small_icons = get_node(terrain_effect_small_icons)

export (NodePath) onready var win_box = get_node(win_box) as PanelContainer
export (NodePath) onready var terrain_box = get_node(terrain_box) as MarginContainer
export (NodePath) onready var dice_box = get_node(dice_box) as MarginContainer

const _DICE_EFFECT_ICONS = {
	1: preload("res://assets/dice/dice_icon_medium_1.png"),
	2: preload("res://assets/dice/dice_icon_medium_2.png"),
	3: preload("res://assets/dice/dice_icon_medium_3.png"),
	4: preload("res://assets/dice/dice_icon_medium_4.png"),
	5: preload("res://assets/dice/dice_icon_medium_5.png"),
	6: preload("res://assets/dice/dice_icon_medium_6.png"),
}

const _DICE_EFFECT_TEXT = {
	1: "LIMITED TO 50% MAX POWER",
	2: "SHOTS COST DOUBLE",
	3: "EXTRA BOUNCY BALL",
	4: "EXTRA SLIPPERY BALL",
	5: "SHOTS COST NOTHING",
	6: "INCREASED TO 150% MAX POWER",
}

const _terrain_order = [
	BaseWorldBlock.TerrainType.GREEN,
	BaseWorldBlock.TerrainType.FAIRWAY,
	BaseWorldBlock.TerrainType.ROUGH,
	BaseWorldBlock.TerrainType.BUNKER,
]

const _TERRAIN_EFFECT_ICONS = {
	BaseWorldBlock.TerrainType.GREEN: preload("res://assets/tiles/terrain_icon_medium_green.png"),
	BaseWorldBlock.TerrainType.FAIRWAY: preload("res://assets/tiles/terrain_icon_medium_fairway.png"),
	BaseWorldBlock.TerrainType.ROUGH: preload("res://assets/tiles/terrain_icon_medium_rough.png"),
	BaseWorldBlock.TerrainType.BUNKER: preload("res://assets/tiles/terrain_icon_medium_bunker.png"),
}

const _TERRAIN_EFFECT_TEXT = {
	BaseWorldBlock.TerrainType.GREEN: "Green: Watch out! - quite slippery",
	BaseWorldBlock.TerrainType.FAIRWAY: "Fairway: Best ground - extra launch power",
	BaseWorldBlock.TerrainType.ROUGH: "Rough: Hard ground - reduces launch power",
	BaseWorldBlock.TerrainType.BUNKER: "Bunker: Very Hard ground - significantly reduces launch power",
}


func _ready() -> void:
	win_box.hide()
	terrain_box.show()
	dice_box.show()
	Event.connect("strokes_updated", self, "_handle_strokes_updated")
	Event.connect("active_effect_changed", self, "_handle_active_effect_changed")
	Event.connect("terrain_effect_changed", self, "_handle_terrain_effect_changed")
	Event.connect("level_won", self, "_handle_level_won")
	Event.connect("level_setup_complete", self, "_handle_level_setup")
	Event.connect("update_best", self, "_handle_update_best")

	call_deferred("_update_tooltips")

	Event.emit_signal("active_effect_changed", 5)
	Event.emit_signal("terrain_effect_changed", BaseWorldBlock.TerrainType.FAIRWAY)


func _update_tooltips() -> void:
	for i in range(terrain_effect_small_icons.get_child_count()):
		terrain_effect_small_icons.get_child(i).hint_tooltip = _TERRAIN_EFFECT_TEXT[_terrain_order[i]]

	for i in range(dice_effect_small_icons.get_child_count()):
		dice_effect_small_icons.get_child(i).hint_tooltip = _DICE_EFFECT_TEXT[i+1]


# SIGNAL HANDLES
func _handle_level_setup(level_number: int) -> void:
	hole_number.text = "Hole %d" % level_number


func _handle_strokes_updated(new_score: int) -> void:
	score_current.text = "%d Strokes" % new_score


func _handle_active_effect_changed(new_number: int) -> void:
	_set_new_dice_effect(new_number)


func _handle_terrain_effect_changed(terrain_type: int) -> void:
	_set_new_terrain_effect(terrain_type)


func _handle_level_won() -> void:
	win_box.show()
	terrain_box.hide()
	dice_box.hide()


func _handle_update_best(new_best: int) -> void:
	if new_best == -1:
		score_best.text = "(Best: --)"
	else:
		score_best.text = "(Best: %d)" % new_best


# Methods
func _set_new_dice_effect(new_number: int) -> void:
	active_dice_effect_icon.texture = _DICE_EFFECT_ICONS[new_number]
	active_dice_effect_text.text = _DICE_EFFECT_TEXT[new_number]


func _set_new_terrain_effect(terrain_type: int) -> void:
	terrain_effect_icon.texture = _TERRAIN_EFFECT_ICONS[terrain_type]
	terrain_effect_text.text = _TERRAIN_EFFECT_TEXT[terrain_type]


func _on_main_menu_button_pressed() -> void:
	SceneManager.load_scene("title_screen")


func _on_next_level_pressed() -> void:
	Event.emit_signal("next_level_requested")
