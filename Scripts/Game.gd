extends Node2D

var board_width = 10
var board_height = 16

var cell_size = 32

var cell_offset = Vector2(cell_size / 2, cell_size / 2)

var root

onready var camera = $Camera2D

onready var cursor = $Cursor

onready var board = $Board

var current_block: Node2D

func _ready():
	
	root = get_tree().root
	
	current_block = load("res://Blocks/T-Piece.tscn").instance()
	cursor.add_child(current_block)



func _process(delta):
	pass
	
func _input(event):
	
	if event is InputEventMouseMotion:
		# Move the cursor
		var cursor_pos = Vector2.ZERO
		
		if is_in_board(get_selected_tile()):
			cursor_pos = get_quantized_cursor_pos() + cell_offset
			
		else:
			cursor_pos = get_mouse_pos()
			
		cursor.set_target_pos(cursor_pos)
		
	if event is InputEventMouseButton:
		
		if !event.pressed: return
		
		if event.button_index == 1:
			
			# Place the block
			# The global position of the tiles in the current_block (block.gd) are
			# used to calculate the placed tiles positions with board.world_to_map()
			# So, since the current block follows the cursor, what you see is basically what you get
			# except for quantizing the positions to fit on the grid
			if current_block == null: return
			
			if !is_in_board(get_selected_tile()): 
				cursor.shake_effect()
				return
			
			# TODO, verify that there aren't blocks already there
			# Verify that individual block squares are valid
			for pos in current_block.get_children_global_pos():
				if !is_in_board(global_to_tile(pos)): 
					cursor.shake_effect()
					return
			
			# Animation Cancelling:
			# Make sure that the cursor is not tweening
			# If they are, instantly finish any animation
			if cursor.is_moving(): cursor.force_complete_tweens()
			
			for pos in current_block.get_children_global_pos():
				set_tile(board.world_to_map(board.to_local(pos)))
			
			
		if event.button_index == 2:
			
			# Rotate the block
			cursor.rotate_90()
			
			

func get_mouse_pos():
	return camera.get_global_mouse_position()

func set_tile(tilemap_position: Vector2):
	board.set_cellv(tilemap_position, 0)

# Returns global coordinates
func quantize_position(global_position: Vector2):
	return board.map_to_world(board.world_to_map(global_position))

# Returns global coordinates
func get_quantized_cursor_pos():
	return quantize_position(get_mouse_pos())

# Returns tilemap coordinates
func get_selected_tile():
	return global_to_tile(get_mouse_pos())

func global_to_tile(global_position: Vector2):
	return board.world_to_map(board.to_local(global_position))
	
func is_in_board(tilemap_coordinate: Vector2):

	if 0 <= tilemap_coordinate.x and tilemap_coordinate.x <= board_width - 1 and \
		0 <= tilemap_coordinate.y and tilemap_coordinate.y <= board_height - 1:
		return true
	else:
		return false
