extends Node2D

var cell_size = 32

var cell_offset = Vector2(cell_size / 2, cell_size / 2)

var root

onready var camera = $Camera2D

onready var cursor = $Cursor

onready var board = $Board

var current_block: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	root = get_tree().root
	
	current_block = load("res://Blocks/T-Piece.tscn").instance()
	cursor.add_child(current_block)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	
	if event is InputEventMouseMotion:
		var cursor_pos = board.to_global(board.map_to_world(board.world_to_map(camera.get_local_mouse_position())))
		cursor.set_target_pos(cursor_pos + cell_offset)
		#print(cursor_pos + cell_offset)
		
	if event is InputEventMouseButton:
		
		if !event.pressed: return
		
		if event.button_index == 1:
			if current_block == null: return
			
			var rotated_data = current_block.data
			var rotated_center = current_block.center + Vector2(1,1)
			
			if cursor.target_rot % 360 == 0:
				pass
			elif cursor.target_rot % 360 == 90:
				pass
			elif cursor.target_rot % 360 == 180:
				pass
			elif cursor.target_rot % 360 == 270:
				pass
				
			for row in len(rotated_data):
					for col in len(rotated_data[row]):
						if rotated_data[row][col] == 1:
							var array_coord = (Vector2(col,row) + Vector2(1,1))
							print(array_coord)
							print(rotated_center)
							print(array_coord - rotated_center)
							print()
							var tile_pos = board.world_to_map(cursor.position) + (array_coord - rotated_center)
							set_tile(tile_pos)
							
			cursor.set_target_rot(0)
			
		if event.button_index == 2:
			cursor.set_target_rot(cursor.rotation_degrees + 90)
			
		
		
func set_tile(tilemap_position: Vector2):
	board.set_cellv(tilemap_position, 0)


# Rotates array 90 degrees clockwise, assuming that array is a full rectangle (all rows same size)
# https://godotengine.org/qa/92697/how-can-i-rotate-an-array-of-array
func rotate_array(arr) -> Array:
	var new_arr = []
	for i in range(len(arr[0])):
		var row = []
		for j in range(len(arr)):
			row.append(arr[len(arr) - j - 1][i])
		new_arr.append(row)
	return new_arr
