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
		# Move the cursor
		var cursor_pos = board.to_global(board.map_to_world(board.world_to_map(camera.get_local_mouse_position())))
		cursor.set_target_pos(cursor_pos + cell_offset)
		
	if event is InputEventMouseButton:
		
		if !event.pressed: return
		
		if event.button_index == 1:
			
			# Place the block
			# The global position of the tiles in the current_block (block.gd) are
			# used to calculate the placed tiles positions with board.world_to_map()
			# So, since the current block follows the cursor, what you see is basically what you get
			# except for quantizing the positions to fit on the grid
			if current_block == null: return
			
			# TODO, verify that there aren't blocks already there
			
			# Animation Cancelling:
			# Make sure that the cursor is not tweening
			# If they are, instantly finish any animation
			if cursor.is_moving(): cursor.force_complete_tweens()
			
			for pos in current_block.get_children_global_pos():
				set_tile(board.world_to_map(pos))
			
			
		if event.button_index == 2:
			
			# Rotate the block
			cursor.rotate_90()
			
		
		
func set_tile(tilemap_position: Vector2):
	board.set_cellv(tilemap_position, 0)

