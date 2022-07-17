extends Button


const DISCORD_LINK = "https://discord.gg/yhQEzQtQ4K"


func _on_DiscordLink_pressed() -> void:
	OS.shell_open(DISCORD_LINK)
