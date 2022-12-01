extends Control

export var message = ""

onready var label = $Label

func _on_state_changed(new_message):
	
	if message.empty():
		label.text = new_message
	else:
		label.text = message % new_message
