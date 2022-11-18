extends KinematicBody2D

export var max_health = 4
export var speed = 40

var health: int

onready var nav_agent = $NavigationAgent2D

var destination: Vector2


signal on_enemy_destroyed()

func _ready():
	health = max_health

func init(start_pos, end_pos):
	position = start_pos
	destination = end_pos
	nav_agent.set_target_location(destination)

func set_stats(new_health = -1, new_speed = -1):
	if new_health > 0:
		max_health = new_health
		health = max_health
	
	if new_speed > 0:
		speed = new_speed
		


func _physics_process(delta):
	
	# Set velocity eventually emits the velocity_comptued signal
	nav_agent.set_velocity(global_position.direction_to(nav_agent.get_next_location()) * speed)

func take_damage(damage):
	health = max(0, health - damage)
	
	if health <= 0:
		destroy()
		
func destroy():
	emit_signal("on_enemy_destroyed")
	queue_free()

func _on_velocity_computed(safe_velocity: Vector2):
	move_and_slide(safe_velocity)



