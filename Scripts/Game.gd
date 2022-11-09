extends Node2D

var cell_size = 32

var cell_offset = Vector2(cell_size / 2, cell_size / 2)

var root

onready var camera = $Camera2D

onready var cursor = $Cursor


var enemy_start = Vector2(0, -352)
var enemy_end = Vector2(0, 352)

onready var board = $Board

var current_block: Node2D
var current_tower: Resource
var temp_enemy: Resource


func _ready():
	
	root = get_tree().root
	
	current_block = load("res://Blocks/T-Piece.tscn").instance()
	current_tower = load("res://Scenes/Tower.tscn")
	temp_enemy = load("res://Scenes/Enemy.tscn")
	
	cursor.add_child(current_block)
	
	print(board.map_to_world(Vector2(0,0)) - board.position)



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
			
			# TODO, There's a bug where you can bypass checks if you go fast
			# Verify that individual block squares are valid
			
			
			for pos in current_block.get_children_global_pos():
				if !board.is_in_board(board.global_to_tile(pos)) or !board.is_free_space(board.global_to_tile(pos)): 
					cursor.shake_effect()
					return
			
			# Verify that placing this block does not cut off the path from start to finish
			var proposed_block_positions = []
			for pos in current_block.get_children_global_pos():
				proposed_block_positions.append(board.global_to_tile(pos))
			
			if !is_traversable(board.global_to_tile(enemy_start), board.global_to_tile(enemy_end), proposed_block_positions):
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
			
	# Spawn Enemy for Debug
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			var new_enemy = temp_enemy.instance()
			add_child(new_enemy)
			new_enemy.init(enemy_start, enemy_end)


func get_mouse_pos():
	return camera.get_global_mouse_position()

# Returns global coordinates
func get_quantized_cursor_pos():
	return board.quantize_position(get_mouse_pos())

# Returns tilemap coordinates
func get_selected_tile():
	return board.global_to_tile(get_mouse_pos())

func is_walkable_tile(tilemap_coordinate: Vector2):
	return board.get_cellv(tilemap_coordinate) == Util.NAV_ALLOWED_TILE
	


var relative_neighbors = [Vector2(0, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(0, 1)] # Down, left, right, up

# Uses Depth First Search to determine if there is a valid path between start and end tilemap coordinates 
# on the board considering the list of additional proposed_blocks

# Navigation2DServer is not used because it seems difficult to test for traversable paths while
# agents are also using it

# Built-in Astar is not used because the edges between nodes (tiles) is already naturally
# encoded and maintained by the board's tile data and would have to be re-computed/maintained for the Astar graph
func is_traversable(tilemap_start: Vector2, tilemap_end: Vector2, proposed_blocks: Array):
	
	var to_visit = [] # Array of tilemap positions (V2s)
	var visited = {} # Dictionary of tilemap postitions (V2s)
	
	to_visit.push_front(tilemap_start)
	
	while !to_visit.empty():
		var node = to_visit.pop_front()

		if visited.has(node):
			continue # Ignore already visited nodes
		
		visited[node] = true # Mark this node as visited
		
		
		if node == tilemap_end: return true # Path exists
		else:
			# Add valid neighbors. Proposted block positions are ignored
			for rel_pos in relative_neighbors:
				var pos = node + rel_pos

				if is_walkable_tile(pos) and proposed_blocks.find(pos) == -1:
					to_visit.push_front(pos)

	return false

