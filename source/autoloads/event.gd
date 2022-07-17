extends Node

signal player_launched(score_modifier)
signal strokes_updated(new_stroke_number)
signal level_setup_complete
signal camera_limit_set(camera_limit)

signal active_effect_changed(new_effect)
signal terrain_effect_changed(new_effect)

signal win_area_loaded(win_location)