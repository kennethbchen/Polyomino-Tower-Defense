extends Control

onready var label = $Label

func _on_wave_state_changed(message):
	label.text = message
