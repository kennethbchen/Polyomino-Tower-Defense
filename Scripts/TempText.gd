extends Control

func _hide():
	print(visible)
	if visible:
		hide()
