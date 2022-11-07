extends Node2D

export var cursor_speed = 10

var target = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	
	position = lerp(position, target, delta * cursor_speed)
	
	pass
	
func set_target(position : Vector2):
	target = position
