extends Node2D

export var cursor_speed = 10

var target_pos = Vector2.ZERO
var target_rot: int = 0 # In Degrees

onready var pos_tween = $PosTween
onready var rot_tween = $RotTween


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	pass
	
func set_target_pos(new_pos : Vector2):
	
	if target_pos == new_pos: return
	
	target_pos = new_pos
	pos_tween.interpolate_property(self, "position", position, target_pos, 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	pos_tween.start()
	
func set_target_rot(new_rot):
	
	if rot_tween.is_active(): return
	if target_rot == new_rot: return
	
	target_rot = new_rot
	
	rot_tween.interpolate_property(self, "rotation_degrees", rotation_degrees, target_rot, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	rot_tween.start()

func is_moving():
	if pos_tween.is_active() or rot_tween.is_active(): 
		return true
	else:
		return false
		
func force_complete_tweens():
	pos_tween.stop_all()
	rot_tween.stop_all()
	
	position = target_pos
	rotation_degrees = target_rot

