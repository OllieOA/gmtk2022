extends Button

const TWITCH_LINK = "https://www.twitch.tv/ollieboyoa"


func _on_TwitchLink_pressed() -> void:
	OS.shell_open(TWITCH_LINK)
