extends Node

export var enemy: PackedScene

onready var wave_timer = $WaveTimer
onready var spawn_timer = $SpawnTimer

# Copied from root
var enemy_start = Vector2(1024, -352)
var enemy_end = Vector2(1024, 352)

# Wave State Strings
var wave_countdown_message = "Next Wave In: %ss."
var wave_count_message = "Wave %s"

# Wave Parameters
var wave_cooldown = 25
var spawn_delay = 0.5
var enemies_per_round = 10
var enemy_health = 4
var enemy_speed = 40

# Wave State
var wave_count = 0
var time_left_int: int = 0
var enemies_to_spawn: int = 0
var enemies_alive: int = 0

signal wave_count_changed(new_wave)
signal wave_status_changed(new_time)

signal enemy_killed()

func _ready():
	wave_timer.start(10)
	emit_signal("wave_count_changed", wave_count_message % wave_count)
	
func _process(delta):
	
	if int(wave_timer.time_left) != time_left_int and wave_timer.wait_time > 0:
		time_left_int = int(wave_timer.time_left)
		emit_signal("wave_status_changed", wave_countdown_message % time_left_int)

		
func _on_wave_timer_timeout():
	
	
	
	# Modify Spawn Parameters
	if wave_count > 0:
		enemies_per_round += 2
		
		if wave_count % 4 == 0:
			enemy_health += 1
		
		enemy_speed += 2
	
	wave_count += 1
	
	print("Wave ", wave_count)
	print("Enemies: ", enemies_per_round)
	print("Enemy Health: ", enemy_health)
	print("Enemy Speed: ", enemy_speed)
	print("-----")
	
	# -0.001 to avoid wave timer display flickering from n to n-1 in a frame
	wave_timer.start(wave_cooldown - 0.001)
	
	# Start Spawning Enemies
	enemies_to_spawn = enemies_per_round
	spawn_timer.start(spawn_delay)
	
	emit_signal("wave_count_changed", wave_count_message % wave_count)

func _spawn_enemy():
	var new_enemy = enemy.instance()
	add_child(new_enemy)
	new_enemy.init(enemy_start, enemy_end)
	new_enemy.set_stats(enemy_health, enemy_speed)
	new_enemy.connect("enemy_destroyed", self, "_on_enemy_destroyed")
	enemies_to_spawn -= 1
	enemies_alive += 1
	

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
	
func _on_player_died():
	wave_timer.paused = true
	spawn_timer.paused = true
