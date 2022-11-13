extends Control

onready var display = $ContentContainer/Display

func _on_held_block_changed(img):
	display.texture = img
