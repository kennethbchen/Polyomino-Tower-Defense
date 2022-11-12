extends VBoxContainer

export(NodePath) var queue_handler_path; onready var queue_handler = get_node(queue_handler_path)

# Automatically connects QueueDisplay to BlockQueueHandler signal

func _ready():
	
	for child in get_children():
		if child is QueueDisplay:
			queue_handler.connect("queue_changed", child, "_on_queue_changed")
	

