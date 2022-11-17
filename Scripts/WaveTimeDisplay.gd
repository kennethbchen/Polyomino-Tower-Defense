extends Control

onready var label = $Label

var format_string = "Next Wave In: %ss."

func _on_time_left_int_changed(new_time):
	label.text = format_string % new_time
