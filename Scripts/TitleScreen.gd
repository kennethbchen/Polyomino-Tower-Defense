extends Control

onready var instruction_panel = $InstructionPanel

func _on_start_game():
	get_tree().change_scene("res://Game.tscn")

func _on_how_to_play():
	instruction_panel.popup()

