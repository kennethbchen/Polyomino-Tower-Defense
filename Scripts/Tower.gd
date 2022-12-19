extends Node2D

export(PackedScene) var projectile

export(PackedScene) var super_projectile

export var max_durability: int = 24
var durability: int

# durability decreases on each shot
# display_steps is how many different sprites the tower has to display
# how low its durability is (example: gets more cracks, breaks down)
export var display_steps: int = 4

export var cooldown_time: float

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
	durability = max_durability
	
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
					
					change_durability(-1)
					
				else: return
				
				if timer.is_stopped():
					timer.start(cooldown_time)
					
				
				current_state = State.COOLDOWN
				
			State.COOLDOWN:
				pass
			

func change_durability(delta):
	durability = max(0, min(durability + delta, max_durability))
	
	modulate = Color.white.linear_interpolate(Color.black, max(1 - float(get_display_index() + 1) / display_steps, 0.2))
	
	if durability <= 0:
		destroy()

func get_display_index():
	return int((float(durability) / max_durability) * display_steps)

func destroy(super = false):
	emit_signal("tower_removed", position)
	
	if super:
		
		# Spawn a super projectile here before the tower is destroyed
		var up = super_projectile.instance()
		up.position = position
		up.rotation_degrees = -90
		get_tree().root.add_child(up)
		
		var down = super_projectile.instance()
		down.position = position
		down.rotation_degrees = 90
		get_tree().root.add_child(down)
		

	queue_free()

func _on_body_entered_range(body: PhysicsBody2D):
	
	if body == null: return
	
	detected_enemies.append(body)

func _on_body_exited_range(body: PhysicsBody2D):
	
	if body == null: return
	
	var ind = detected_enemies.find(body)
	if ind != -1:
		detected_enemies.remove(ind)

func _on_timer_completed():
	if current_state == State.COOLDOWN:
		current_state = State.SHOOTING
