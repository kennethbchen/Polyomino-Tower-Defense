extends Node2D

export(PackedScene) var projectile

export var cooldown_time = 2

onready var aim_system = $AimSystem

onready var timer = $Timer

# These signals connect with Board.gd to handle pathfinding
signal tower_created(pos)
signal tower_removed(pos)

var detected_enemies = []

var current_state = State.SHOOTING

enum State {SHOOTING = 1, COOLDOWN = 2}

func init(pos, board_node):
	position = pos

	connect("tower_created", board_node, "_on_tower_created")
	connect("tower_removed", board_node, "_on_tower_destroyed")
	emit_signal("tower_created", position)
	
func _ready():
	pass
	
func _process(delta):
	
	if !detected_enemies.empty():
		
		aim_system.aim_at_position(detected_enemies[0].position)
		
		match(current_state):
			State.SHOOTING:
				
				if aim_system.angle_error_deg() <= 5:
					# Shoot
					var proj = projectile.instance()
					proj.position = position
					proj.rotation = aim_system.rotation
					get_tree().root.add_child(proj)
					
				else: return
				
				if timer.is_stopped():
					timer.start(cooldown_time)
					
				
				current_state = State.COOLDOWN
				
			State.COOLDOWN:
				pass
			


func destroy():
	emit_signal("tower_removed", position)
	queue_free()

func _on_body_entered_range(body: PhysicsBody2D):
	detected_enemies.append(body)

func _on_body_exited_range(body: PhysicsBody2D):
	var ind = detected_enemies.find(body)
	if ind != -1:
		detected_enemies.remove(ind)

func _on_timer_completed():
	if current_state == State.COOLDOWN:
		current_state = State.SHOOTING
