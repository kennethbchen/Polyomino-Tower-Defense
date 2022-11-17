extends Node

export var enemy: PackedScene

onready var wave_timer = $WaveTimer
onready var spawn_timer = $SpawnTimer

# Wave Status Strings
var wave_countdown_message = "Next Wave In: %ss."
var wave_progressing_message = "Wave in progress..."
var wave_complete_message = "Wave Complete!"

# Wave Parameters
var wave_cooldown = 5
var spawn_delay = 0.5
var enemies_per_round = 10

# Wave State
var wave_number = 1
var time_left_int: int
var enemies_to_spawn: int
var enemies_alive: int

signal wave_status_changed(new_time)


func _ready():
	wave_timer.start(wave_cooldown)
	
func _process(delta):
	
	if int(wave_timer.time_left) != time_left_int and wave_timer.wait_time > 0:
		time_left_int = int(wave_timer.time_left)
		emit_signal("wave_status_changed", wave_countdown_message % time_left_int)

	if wave_timer.wait_time <= 0 and enemies_alive == 0:
		emit_signal("wave_status_changed", wave_complete_message)
		
func _on_wave_timer_timeout():


	# Modify Spawn Parameters
	
	# Start Spawning Enemies
	enemies_to_spawn = enemies_per_round
	spawn_timer.start(spawn_delay)
	
	emit_signal("wave_status_changed", wave_progressing_message)
	
func _on_spawn_timer_timeout():
	# Spawn Enemies until the desired number is reached
	if enemies_to_spawn > 0:
		print("spawn")
		
		enemies_to_spawn -= 1
		enemies_alive += 1
	else:
		spawn_timer.stop()

func _on_enemy_destroyed():
	enemies_alive = max(0, enemies_alive - 1)
