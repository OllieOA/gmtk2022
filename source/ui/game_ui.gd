class_name GameUI extends CanvasLayer

export (NodePath) onready var active_dice_effect_icon = get_node(active_dice_effect_icon) as TextureRect
export (NodePath) onready var active_dice_effect_text = get_node(active_dice_effect_text) as Label

export (NodePath) onready var terrain_dice_effect_icon = get_node(terrain_dice_effect_icon) as TextureRect
export (NodePath) onready var terrain_dice_effect_text = get_node(terrain_dice_effect_text) as Label

export (NodePath) onready var score_current = get_node(score_current) as Label
export (NodePath) onready var score_best = get_node(score_best) as Label

func _ready() -> void:
	pass 

