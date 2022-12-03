extends Position2D

export var speed = 4
export var direction = Vector2(0, 1)
export var duration = 2

onready var label = $Label
onready var tween = $Tween

func init(text, pos):
	label.text = text
	position = pos
	
	tween.interpolate_property(self, "position", position, position + (direction * speed), duration)
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), duration, 1)
	tween.start()


	

func _on_all_tweens_completed():
	queue_free()

