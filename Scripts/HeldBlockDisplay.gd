extends Control

onready var display = $ContentContainer/Display

signal hold_display_selected()

func _on_held_block_changed(img):
	display.texture = img

func _gui_input(event):
	
	if event.is_action_pressed("game_select"):
		emit_signal("hold_display_selected")
