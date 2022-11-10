extends Node2D

export var aim_speed = 10.0

var aim_direction = Vector2(0,0)

var enabled = true

func _ready():
	pass

func _process(delta):
	
	if enabled:
		rotation = lerp_angle(rotation, aim_angle_rad(), aim_speed * delta) 

func aim_at_position(global_position: Vector2):
	aim_at_direction( (global_position - self.global_position).normalized() )
	
func aim_at_direction(direction: Vector2):
	aim_direction = direction.normalized()

func aim_angle_rad():
	return fmod(aim_direction.angle(), PI)

func aim_angle_deg():
	return rad2deg(aim_angle_rad())
	
# rotation vs aim_direction
func angle_error_rad():
	return abs(_angle_dif(rotation, aim_direction.angle()))
	
func angle_error_deg():
	return rad2deg(angle_error_rad())

# returns a value from -PI to PI
func _angle_dif(from : float, to : float):
	var ans = fposmod(to - from, TAU)
	
	if ans > PI:
		ans -= TAU
	return ans
