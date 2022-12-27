extends Node

# https://kidscancode.org/godot_recipes/3.x/audio/audio_manager/

export var num_players = 8
export var bus = "master"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.


func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", self, "_on_stream_finished", [p])
		p.bus = bus


func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)


func play(sound_path):
	queue.append(sound_path)


func _process(delta):
	# Play a queued sound if any players are available.
	if not queue.empty() and not available.empty():
		var audio = queue.pop_front()
		if audio is Resource:
			available[0].stream = audio
		else:
			available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()
