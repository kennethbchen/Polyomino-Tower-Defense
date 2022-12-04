extends Node2D

# Valid rotations are only multiples of 90 and 0
# Store valid rotations instead of rotating by +90 to avoid floating point error pain
# 360 and 450 are needed to hide resetting the rotation when clamping value
var rotations = [0, 90, 180, 270, 360, 450]
var rotation_index = 0

export var cursor_speed = 10

var target_pos = Vector2.ZERO
var target_rot: int = 0 # In Degrees

onready var pos_tween = $PosTween
onready var rot_tween = $RotTween

onready var sprite = $Sprite
	
func set_target_pos(new_pos : Vector2):
	
	if target_pos == new_pos: return
	
	target_pos = new_pos
	pos_tween.interpolate_property(self, "position", position, target_pos, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	pos_tween.start()
	
func _set_target_rot(new_rot: int):
	
	if target_rot == new_rot:
		return
		
	target_rot = new_rot
	
	rot_tween.interpolate_property(self, "rotation_degrees", rotation_degrees, target_rot, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	rot_tween.start()

func shake_effect():
	var duration = 0.2
	
	if is_moving(): force_complete_tweens()
	
	var orig_rot = target_rot
	rot_tween.interpolate_property(self, "rotation_degrees", rotation_degrees, orig_rot + 15, duration, Tween.TRANS_BACK, Tween.EASE_OUT)
	rot_tween.interpolate_property(self, "rotation_degrees", rotation_degrees, orig_rot - 15, duration, Tween.TRANS_BACK, Tween.EASE_OUT, duration)
	rot_tween.interpolate_property(self, "rotation_degrees", rotation_degrees, orig_rot, duration, Tween.TRANS_BACK, Tween.EASE_OUT, duration * 2)
	
	#pos_tween.start()
	rot_tween.start()
	
func rotate_90():

	# Animation Cancelling:
	# If the cursor is already rotating, then instantly finish that rotation and start a new one
	if rot_tween.is_active():
		rot_tween.remove_all()
		rotation_degrees = rotations[rotation_index]
		

	# Calculate new rotation index
	rotation_index = (rotation_index + 1) % len(rotations)
	
	# 450 means the current rotation is 360 and the next is 450
	# We can reset the current rotation back to zero because it is currently 360 and then rotate to 90
	if rotations[rotation_index] == 450: 
		rotation_index = 1 # Next target is 90
		rotation_degrees = 0
		

	
	_set_target_rot(rotations[rotation_index])
	

func reset_rotation():
	rotation_index = 0
	rotation_degrees = 0
	target_rot = 0

	
func is_moving():
	if pos_tween.is_active() or rot_tween.is_active(): 
		return true
	else:
		return false
		
func force_complete_tweens():
	pos_tween.remove_all()
	rot_tween.remove_all()
	
	position = target_pos
	rotation_degrees = target_rot

func show_sprite(new_sprite):
	sprite.texture = new_sprite
	sprite.visible = true
	
func hide_sprite():
	sprite.visible = false
	

