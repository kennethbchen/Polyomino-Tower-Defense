extends VBoxContainer

export(NodePath) var queue_handler_path; onready var queue_handler = get_node(queue_handler_path)

var displays = []

signal queue_display_selected()

# Automatically connects QueueDisplay to BlockQueueHandler signal
func _ready():	
	find_queue_displays(self)
		

func find_queue_displays(node):
	for child in node.get_children():
		if child is QueueDisplay:
			displays.append(child)
			queue_handler.connect("queue_changed", child, "_on_queue_changed")
			continue
		
		if child.get_child_count() != 0:
			find_queue_displays(child)
	
func _on_tower_affordability_changed(can_afford):

	for child in displays:
		
		if can_afford:
			child.modulate = Color.white
		else:
			child.modulate = Color.darkgray
			
func _gui_input(event):
	
	if event.is_action_pressed("game_select"):
		emit_signal("queue_display_selected")
