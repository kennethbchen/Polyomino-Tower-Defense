extends Node2D


var root

onready var camera = $Camera2D

onready var cursor = $Cursor

onready var board = $Board

# Called when the node enters the scene tree for the first time.
func _ready():
	
	root = get_tree().root
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	
	if event is InputEventMouseMotion:
		var cursor_pos = board.to_global(board.map_to_world(board.world_to_map(camera.get_local_mouse_position())))
		cursor.set_target(cursor_pos)
		print(cursor_pos)
		
	
