extends Node

onready var wave_timer = $WaveTimer
onready var spawn_timer = $SpawnTimer

# Wave Parameters
var wave_cooldown = 30
var enemies_per_round = 1

# Wave State
var wave_number = 1
var time_left_int: int
var enemies_to_spawn: int
var enemies_alive: int

signal time_left_int_changed(new_time)

func _process(delta):
	
	if int(wave_timer.time_left) != time_left_int:
		time_left_int = int(wave_timer.time_left)
		emit_signal("time_left_int_changed", time_left_int)

func _on_wave_timer_timeout():
	# Start Spawning Enemies
	# Modify Spawn Parameters
	pass
	
func _on_spawn_timer_timeout():
	# Spawn Enemy
	pass
