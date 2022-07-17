extends Node2D

# export (NodePath)
var rng = RandomNumberGenerator.new()
var dice_bag = Dicebag.new()

func _ready() -> void:
	dice_bag.set_up_rng()
	rng.randomize()
	if rng.randf() < 0.5:
		queue_free()
	else:
		pass
		# var frame = dice_bag.roll_dice()

