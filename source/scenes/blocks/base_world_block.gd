tool
class_name BaseWorldBlock extends Node2D

enum TerrainType {
    GREEN,
    FAIRWAY,
    ROUGH,
    BUNKER,
}

export (NodePath) onready var base_shape = get_node(base_shape) as SS2D_Shape_Closed
export (TerrainType) var terrain_type

var terrain_modifier: int
var terrain_name: String

const TERRAIN_MODIFIERS = {
	Globals.TerrainType.FAIRWAY: 1.0,
	Globals.TerrainType.ROUGH: 0.8,
	Globals.TerrainType.BUNKER: 0.5,
	Globals.TerrainType.GREEN: 1.0,
}

const TERRAIN_NAMES = {
	Globals.TerrainType.FAIRWAY: "fairway",
	Globals.TerrainType.ROUGH: "rough",
	Globals.TerrainType.BUNKER: "bunker",
	Globals.TerrainType.GREEN: "green",
}

func _ready() -> void:
	terrain_modifier = TERRAIN_MODIFIERS[terrain_type]
	terrain_name = TERRAIN_NAMES[terrain_type]
	base_shape.add_to_group(terrain_name)
