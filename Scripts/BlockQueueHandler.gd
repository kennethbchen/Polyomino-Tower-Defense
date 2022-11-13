extends Node


export(Array, Resource) var blocks

var queue = [] # Array of Packed Scenes

signal queue_ready()
signal queue_changed(block_queue)

func _ready():
	randomize()
	
	queue.append_array(_generate_bag())
	queue.append_array(_generate_bag())
	
	refresh_displays()
	
	
func pop_next_block():
	var output = queue.pop_front()
	
	if queue.size() <= blocks.size():
		queue.append_array(_generate_bag())
		
	refresh_displays()
	
	return output
	
func peek_next_block():
	return queue[0]

func push_front(block):
	queue.push_front(block)
	refresh_displays()

# A bag is a set of all possible blocks in a random order
# Returns an array of resources (packed scenes)
func _generate_bag() -> Array:
	var packed_scenes = blocks.duplicate()
	packed_scenes.shuffle()
	var output = []
	for scene in packed_scenes:
		output.append(scene.instance())
	return output

func refresh_displays():
	emit_signal("queue_changed", queue)
