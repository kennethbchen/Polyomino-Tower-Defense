extends Node2D

var cell_size = 32

var cell_offset = Vector2(cell_size / 2, cell_size / 2)

var root

onready var camera = $Camera2D

onready var cursor = $Cursor

onready var board = $Board

var current_block: Node2D
var current_tower: Resource


func _ready():
	
	root = get_tree().root
	
	current_block = load("res://Blocks/T-Piece.tscn").instance()
	current_tower = load("res://Scenes/Tower.tscn")
	
	cursor.add_child(current_block)



func _process(delta):
	pass
	
func _input(event):
	
	if event is InputEventMouseMotion:
		# Move the cursor
		var cursor_pos = Vector2.ZERO
		
		if board.is_in_board(get_selected_tile()):
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
			
			if !board.is_in_board(get_selected_tile()): 
				cursor.shake_effect()
				return
			
			# TODO, verify that there aren't blocks already there
			# Verify that individual block squares are valid
			for pos in current_block.get_children_global_pos():
				if !board.is_in_board(board.global_to_tile(pos)) or !board.is_free_space(board.world_to_map(board.to_local(pos))): 
					cursor.shake_effect()
					return
				
				
			
			# Animation Cancelling:
			# Make sure that the cursor is not tweening
			# If they are, instantly finish any animation
			if cursor.is_moving(): cursor.force_complete_tweens()
			
			# Place
			for pos in current_block.get_children_global_pos():
				var new_tower = current_tower.instance()
				add_child(new_tower)
				new_tower.init(board.quantize_position(pos) + cell_offset, board)
				
				
			
			
		if event.button_index == 2:
			
			# Rotate the block
			cursor.rotate_90()
			
			

func get_mouse_pos():
	return camera.get_global_mouse_position()

# Returns global coordinates
func get_quantized_cursor_pos():
	return board.quantize_position(get_mouse_pos())

# Returns tilemap coordinates
func get_selected_tile():
	return board.global_to_tile(get_mouse_pos())


