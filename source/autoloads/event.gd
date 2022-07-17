extends Node

signal player_launched(score_modifier)
signal strokes_updated(new_stroke_number)
signal level_setup_complete(level_number)
signal camera_limit_set(camera_limit)

signal active_effect_changed(new_effect)
signal terrain_effect_changed(new_effect)

signal win_area_loaded(win_location)
signal level_won
signal update_best(new_best)

signal max_power_modifier_updated(new_value)

signal next_level_requested

signal a_button_pressed