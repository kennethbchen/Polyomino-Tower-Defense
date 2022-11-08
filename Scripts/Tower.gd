extends Node2D

# These signals connect with Board.gd to handle pathfinding
signal tower_created(pos)
signal tower_removed(pos)

func init(pos, board_node):
	position = pos

	connect("tower_created", board_node, "_on_tower_created")
	connect("tower_removed", board_node, "_on_tower_removed")
	emit_signal("tower_created", position)
	
func _ready():
	pass


func destroy():
	emit_signal("tower_removed", position)
	queue_free()
