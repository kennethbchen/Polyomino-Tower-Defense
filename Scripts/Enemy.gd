extends KinematicBody2D

export var health = 2

onready var nav_agent = $NavigationAgent2D

var destination: Vector2

func init(start_pos, end_pos):
	position = start_pos
	destination = end_pos
	nav_agent.set_target_location(destination)



func _physics_process(delta):
	
	# Set velocity eventually emits the velocity_comptued signal
	nav_agent.set_velocity(global_position.direction_to(nav_agent.get_next_location()) * 40)

func take_damage(damage):
	health = max(0, health - damage)
	
	if health <= 0:
		destroy()
		
func destroy():
	queue_free()

func _on_velocity_computed(safe_velocity: Vector2):
	move_and_slide(safe_velocity)
	

