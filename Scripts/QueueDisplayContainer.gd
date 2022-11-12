extends VBoxContainer

export(NodePath) var queue_handler_path; onready var queue_handler = get_node(queue_handler_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in get_children():
		if child is QueueDisplay:
			print("child")
			queue_handler.connect("queue_changed", child, "_on_queue_changed")
	

