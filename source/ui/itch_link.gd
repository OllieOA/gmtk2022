extends Button

const ITCH_LINK = "https://ollieoa.itch.io/"

func _on_ItchLink_pressed() -> void:
	OS.shell_open(ITCH_LINK)
