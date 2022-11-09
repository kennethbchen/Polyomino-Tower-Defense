extends Node2D

# These signals connect with Board.gd to handle pathfinding
signal tower_created(pos)
signal tower_removed(pos)

var detected_enemies = []

func init(pos, board_node):
	position = pos

	connect("tower_created", board_node, "_on_tower_created")
	connect("tower_removed", board_node, "_on_tower_removed")
	emit_signal("tower_created", position)
	
func _ready():
	pass
	
func _process(delta):
	if !detected_enemies.empty():
		print("go")
		pass


func destroy():
	emit_signal("tower_removed", position)
	queue_free()

func _on_body_entered_range(area: Area2D):
	detected_enemies.append(area)

func _on_body_exited_range(area: Area2D):
	var ind = detected_enemies.find(area)
	if ind != -1:
		detected_enemies.remove(ind)
