extends Node2D

var cell_size = 32

var cell_offset = Vector2(cell_size / 2, cell_size / 2)

var root

onready var camera = $Camera2D

onready var cursor = $Cursor

onready var board = $BoardData

onready var block_queue = $BlockQueueHandler

var temp_enemy: Resource

var enemy_start = Vector2(1024, -352)
var enemy_end = Vector2(1024, 352)


var selected_block: Node2D
var selected_tower: Resource


enum CursorState {FREE = 1, SELECTED_BLOCK = 2}
var cur_cursor_state = CursorState.FREE

func _ready():
	
	root = get_tree().root
	
	selected_tower = load("res://Scenes/Tower.tscn")
	
	temp_enemy = load("res://Scenes/Enemy.tscn")

func _get_next_block():
		
	var output = block_queue.peek_next_block().instance()
	output.init(selected_tower)
	cursor.add_child(output)
	return output

func _clear_selection():
	
	cursor.reset_rotation()
	selected_block.queue_free()
	cur_cursor_state = CursorState.FREE

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
		
		match(cur_cursor_state):
			CursorState.FREE:
				pass
			CursorState.SELECTED_BLOCK:
		
				if event.button_index == 1:
					
					if selected_block == null: return
					
					if !board.is_in_board(get_selected_tile()): 
						cursor.shake_effect()
						return
					
					# TODO, There's a bug where you can bypass checks if you go fast
					
					# Verify that individual block squares are valid
					for pos in selected_block.get_children_global_pos():
						if !board.is_in_board(board.global_to_tile(pos)) or !board.is_walkable_tile(board.global_to_tile(pos)): 
							cursor.shake_effect()
							return
					
					# Verify that placing this block does not cut off the path from start to finish
					var proposed_block_positions = []
					for pos in selected_block.get_children_global_pos():
						proposed_block_positions.append(board.global_to_tile(pos))
					
					# Verify that this placement does not completely block off the enemy's route
					if !board.is_traversable(board.global_to_tile(enemy_start), board.global_to_tile(enemy_end), proposed_block_positions):
						cursor.shake_effect()
						return
						
					# Animation Cancelling:
					# Make sure that the cursor is not tweening
					# If they are, instantly finish any animation
					if cursor.is_moving(): cursor.force_complete_tweens()
					
					# Place the block
					# The global position of the tiles in the selected_block (block.gd) are
					# used to calculate the placed tiles positions with board.world_to_map()
					# So, since the current block follows the cursor, what you see is basically what you get
					# except for quantizing the positions to fit on the grid
					for pos in selected_block.get_children_global_pos():
						var new_tower = selected_tower.instance()
						add_child(new_tower)
						new_tower.init(board.quantize_position(pos) + cell_offset, board)
					
					
					block_queue.pop_next_block() # We just placed this block
					
					_clear_selection()
					
				if event.button_index == 2:
					
					# Rotate the block
					cursor.rotate_90()
			
	# Debug Stuff
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			var new_enemy = temp_enemy.instance()
			add_child(new_enemy)
			new_enemy.init(enemy_start, enemy_end)
		
		# Simulate clicking stuff to select blocks
		if event.pressed and event.scancode == KEY_A:
			
			if cur_cursor_state == CursorState.SELECTED_BLOCK: return
			
			selected_block = _get_next_block()
			cur_cursor_state = CursorState.SELECTED_BLOCK
		
		if event.pressed and event.scancode == KEY_S:
			
			if cur_cursor_state == CursorState.FREE: return
		
			_clear_selection()


func get_mouse_pos():
	return camera.get_global_mouse_position()

# Returns global coordinates
func get_quantized_cursor_pos():
	return board.quantize_position(get_mouse_pos())

# Returns tilemap coordinates
func get_selected_tile():
	return board.global_to_tile(get_mouse_pos())
