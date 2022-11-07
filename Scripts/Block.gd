extends Node2D

var data = [
[1, 1, 1],
[0, 1, 0]
]

var center = Vector2(1, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_children_global_pos():
	var output = []
	for i in self.get_children():
		output.append(i.global_position)
		
	return output
