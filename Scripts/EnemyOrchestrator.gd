extends Node

export var enemy: PackedScene

onready var spawn_timer = $SpawnTimer

onready var enemy_audio_manager = $AudioStreamManager

# Copied from root
var enemy_start = Vector2(880, -336)
var enemy_end = Vector2(1168, 336)

# Wave State Strings
var wave_countdown_message = "Next Wave In: %ss."
var wave_count_message = "Wave %s"

# Wave Parameters
var wave_cooldown = 25
var spawn_delay = 0.75
var enemies_per_round = 2
var enemy_health = 2
var enemy_speed = 35

var max_health = 8
var max_speed = 65

# Wave State
var wave_count = 0
var time_left_int: int = 0
var enemies_to_spawn: int = 0
var enemies_alive: int = 0

signal wave_count_changed(new_wave)
signal wave_status_changed(new_time)
signal enemy_killed()

func _ready():
	emit_signal("wave_count_changed", wave_count_message % wave_count)
	
	emit_signal("wave_status_changed", "Click \"Send Next Wave\" to begin")
	
func _process(delta):
	print(enemies_alive)
	pass

func _increment_spawn_parameters():
	# Modify Spawn Parameters
	if wave_count > 0:
		enemies_per_round += 2
		
		if wave_count % 4 == 0 and wave_count > 6:
			enemy_health = min(enemy_health + 2, max_health)
		
		enemy_speed = min(enemy_speed + 2, max_speed)
	
	wave_count += 1
	
func _spawn_enemy():
	var new_enemy = enemy.instance()
	add_child(new_enemy)
	new_enemy.init(enemy_start, enemy_end)
	new_enemy.set_stats(enemy_health, enemy_speed)
	new_enemy.connect("enemy_destroyed", self, "_on_enemy_destroyed")
	new_enemy.connect("sound_played", enemy_audio_manager, "play")
	enemies_to_spawn = max(0, enemies_to_spawn - 1)

func send_wave():
	
	_increment_spawn_parameters()
	
	print("Wave ", wave_count)
	print("Enemies: ", enemies_per_round)
	print("Enemy Health: ", enemy_health)
	print("Enemy Speed: ", enemy_speed)
	print("-----")
	
	# -0.001 to avoid wave timer display flickering from n to n-1 in a frame
	#wave_timer.start(wave_cooldown - 0.001)
	
	# Start Spawning Enemies
	enemies_to_spawn += enemies_per_round
	enemies_alive += enemies_per_round
	
	if spawn_timer.is_stopped():
		spawn_timer.start(spawn_delay)
	
	emit_signal("wave_count_changed", wave_count_message % wave_count)	
	emit_signal("wave_status_changed", "Wave " + str(wave_count) + " active...")
	


	
	

func _on_spawn_timer_timeout():
	# Spawn Enemies until the desired number is reached
	if enemies_to_spawn > 0:
		_spawn_enemy()
	else:
		spawn_timer.stop()

func _on_enemy_destroyed(killed):
	
	if killed:
		emit_signal("enemy_killed")
		
	enemies_alive = max(0, enemies_alive - 1)
	
	if enemies_alive <= 0:
		emit_signal("wave_status_changed", "Wave " + str(wave_count) + " complete!")
		
	
func _on_player_died():
	spawn_timer.paused = true
