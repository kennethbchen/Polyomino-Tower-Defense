extends KinematicBody2D

class_name Enemy

export var max_health = 4
export var speed = 40
export var money_on_kill = 1

export(Array, Resource) var hit_sounds

var health: int

onready var nav_agent = $NavigationAgent2D

onready var sprite = $Sprite
onready var hit_tween = $HitTween

var destination: Vector2

var rand = RandomNumberGenerator.new()

signal health_changed(current_health, max_health)
signal hit(sound)

# Enemies that were shot by towers 
# and had their HP reach 0 were killed, otherwise they were not
# for example, enemies that reach the base are not "killed"
signal enemy_destroyed(was_killed) 

func _ready():
	health = max_health
	rand.randomize()

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
	
	_on_hit()

func _on_hit():
	show_hit_effect()
	emit_signal("hit", hit_sounds[rand.randi_range(0, hit_sounds.size() - 1)])

func show_hit_effect():
	
	hit_tween.interpolate_property(sprite.material, "shader_param/weight", 1, 0, 0.35, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	var scale_target = Vector2(0.5, 1.2)
	var duration = 0.1
	hit_tween.interpolate_property(sprite, "scale", Vector2(1,1), scale_target, duration, Tween.TRANS_BACK, Tween.EASE_OUT)
	hit_tween.interpolate_property(sprite, "scale", scale_target, Vector2(1,1), duration, Tween.TRANS_BACK, Tween.EASE_OUT, duration)
	
	hit_tween.start()


func _destroy(killed=false):
	
	emit_signal("enemy_destroyed", killed)
	queue_free()

func _on_velocity_computed(safe_velocity: Vector2):
	move_and_slide(safe_velocity)



