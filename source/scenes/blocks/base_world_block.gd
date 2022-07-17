class_name BaseWorldBlock extends Node2D

export (NodePath) onready var hit_player = get_node(hit_player) as AudioStreamPlayer

enum TerrainType {
	GREEN,
	FAIRWAY,
	ROUGH,
	BUNKER,
}

export (NodePath) onready var base_shape = get_node(base_shape) as StaticBody2D
export (TerrainType) var terrain_type
export (NodePath) onready var bottom_right_limit = get_node(bottom_right_limit) as Position2D

export (bool) var last_block := false  # Used to determine if we are the last block and therefore need to broadcast position

var terrain_modifier: int
var terrain_name: String

const TERRAIN_MODIFIERS = {
	TerrainType.FAIRWAY: 1.2,
	TerrainType.ROUGH: 0.8,
	TerrainType.BUNKER: 0.5,
	TerrainType.GREEN: 1.0,
}

const TERRAIN_NAMES = {
	TerrainType.FAIRWAY: "fairway",
	TerrainType.ROUGH: "rough",
	TerrainType.BUNKER: "bunker",
	TerrainType.GREEN: "green",
}

func _ready() -> void:
	terrain_modifier = TERRAIN_MODIFIERS[terrain_type]
	terrain_name = TERRAIN_NAMES[terrain_type]
	base_shape.add_to_group(terrain_name)