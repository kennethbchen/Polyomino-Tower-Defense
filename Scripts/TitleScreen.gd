extends Control

func _on_start_game():
	get_tree().change_scene("res://Game.tscn")

func _on_how_to_play():
	OS.shell_open("https://itch.io/t/2567723/how-to-play")

