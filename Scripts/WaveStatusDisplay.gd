extends Control

onready var label = $Label

func _on_wave_status_changed(message):
	label.text = message
