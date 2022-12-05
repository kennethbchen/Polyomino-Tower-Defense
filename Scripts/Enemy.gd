extends KinematicBody2D

class_name Enemy

export var max_health = 4
export var speed = 40
export var money_on_kill = 1

var health: int

onready var nav_agent = $NavigationAgent2D

var destination: Vector2

signal health_changed(current_health, max_health)

# Enemies that were shot by towers 
# and had their HP reach 0 were killed, otherwise they were not
# for example, enemies that reach the base are not "killed"
signal enemy_destroyed(was_killed) 

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
	
	if damage <= 0: return
	
	health = max(0, health - damage)
	
	if health <= 0:
		_destroy(true)
	
	emit_signal("health_changed", health, max_health)

func _destroy(killed=false):
	
	emit_signal("enemy_destroyed", killed)
	queue_free()

func _on_velocity_computed(safe_velocity: Vector2):
	move_and_slide(safe_velocity)



