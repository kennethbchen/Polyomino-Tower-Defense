extends Node2D

export var cursor_speed = 10

onready var pos_tween = $PosTween
onready var rot_tween = $RotTween


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	print(rotation_degrees)
	pass
	
func set_target_pos(new_pos : Vector2):
	
	pos_tween.interpolate_property(self, "position", position, new_pos, 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	pos_tween.start()
	
func set_target_rot(new_rot):
	
	if rot_tween.is_active(): return
	
	
	
	rot_tween.interpolate_property(self, "rotation_degrees", rotation_degrees, new_rot, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	rot_tween.start()
	

