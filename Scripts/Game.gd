extends Node2D

var cell_size = 32

var cell_offset = Vector2(cell_size / 2, cell_size / 2)

onready var camera = $Camera2D

onready var cursor = $Cursor

onready var board = $BoardData

onready var block_queue = $BlockQueueHandler

onready var enemy_orchestrator = $EnemyOrchestrator

export(int, LAYERS_2D_PHYSICS) var tower_physics_layer


# Enemy Stuff
var temp_enemy: Resource

var enemy_start = Vector2(1024, -352)
var enemy_end = Vector2(1024, 352)


# Player Selected Block State

var selected_block: Node2D = null
var held_block: Node2D = null
var selected_tower: Resource

# Currency Stuff
var money = 8

var tower_cost = 4

var kill_reward = 1


signal held_block_changed(image)

func _ready():
	
	selected_tower = load("res://Scenes/Tower.tscn")
	
	temp_enemy = load("res://Scenes/Enemy.tscn")

func _get_next_block():

	return block_queue.pop_next_block()

func _select_block(block):
	selected_block = block
	block.init(selected_tower)
	cursor.add_child(block)

# Un-selects the currently selected block
# Does not do anything to the selected_block node itself
# It has to be dealt with separately
func _clear_selection():
	
	cursor.reset_rotation()
	cursor.remove_child(selected_block)
	selected_block = null


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
		
		if selected_block == null:
			pass
		else:
			
			# Left Click
			if event.button_index == 1:
				
				# Attempt to place a block
				
				if selected_block == null: return # No block to place
				
				if money < tower_cost: 
					print("no money")
					return # Not enough money
				
				if !board.is_in_board(get_selected_tile()): 
					cursor.shake_effect()
					return # Cursor can't be out of bounds
				
				# TODO, There's a bug where you can bypass checks if you go fast
				
				# Verify that individual block squares are valid
				for pos in selected_block.get_children_global_pos():
					if !board.is_in_board(board.global_to_tile(pos)) or !board.is_walkable_tile(board.global_to_tile(pos)): 
						cursor.shake_effect()
						return # Some block is out of bounds
				
				# Verify that placing this block does not cut off the path from start to finish
				var proposed_block_positions = [] # The tilemap positions each tile in the block takes up
				var rows_changed = [] # The y positions of the rows will be changed by this block
				var clears_line = false # Whether or not the new block will clear a line
				var full_rows = [] # The y positions of the rows that are completed by the new block
				var towers_to_delete = [] # The towers that are a part of a cleared line
				
				# Record data based on the tiles in the block
				for pos in selected_block.get_children_global_pos():
					var tilemap_pos = board.global_to_tile(pos)
					proposed_block_positions.append(tilemap_pos)
					
					if !rows_changed.has(tilemap_pos.y):
						rows_changed.append(tilemap_pos.y) 
				
				# Verify that this placement does not completely block off the enemy's route
				if !board.is_traversable(board.global_to_tile(enemy_start), board.global_to_tile(enemy_end), proposed_block_positions):
					
					# Board is not traversable, check if there is a complete line
					# If there is a complete line, then placement can happen because rows will be cleared
					for y in rows_changed:
						if board.is_complete_line(y, proposed_block_positions):
							clears_line = true
							if !full_rows.has(y):
								full_rows.append(y)
						
					if !clears_line:
						# Fail to place
						cursor.shake_effect()
						return
				
				# Block placement can happen at this point
				
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
					
					if clears_line:
						towers_to_delete.append(new_tower)
					
				if clears_line:
					# Get all of the towers in cleared lines and destroy them
					
					# Prepare to segment cast
					var space_state = get_world_2d().direct_space_state
					var segment = SegmentShape2D.new()
					var query = Physics2DShapeQueryParameters.new()
					query.collide_with_areas = true
					
					# For each completed row
					for row in full_rows:
						
						# Set endpoints of cast
						var start = board.tile_to_global(Vector2(-1, row)) + cell_offset
						var end = board.tile_to_global(Vector2(40, row)) + cell_offset
						segment.set_a(start)
						segment.set_b(end)
						
						query.set_shape(segment)
						query.collision_layer = tower_physics_layer
						
						# Find all towers in the row
						var hits = space_state.intersect_shape(query, 20)
						
						# Add them to the list of towers to delete
						for hit in hits:
							towers_to_delete.append(hit.collider.get_parent())
					
					
					# Delete towers
					for tower in towers_to_delete:
						
						if board.global_to_tile(tower.position).y in full_rows:
							tower.destroy(true)
						else:
							tower.destroy()
				
				money -= tower_cost
				
				# The selected block is no longer needed
				selected_block.queue_free()
				_clear_selection()
					
			
			# Right Click
			if event.button_index == 2:
				
				cursor.rotate_90()
				
				
			
	# Debug Stuff
	if event is InputEventKey:
		
		if !event.pressed: return
		
		if event.scancode == KEY_SPACE:
			enemy_orchestrator._spawn_enemy()
		
		# Simulate clicking stuff to select blocks
		if event.scancode == KEY_A:
			
			# Select from queue
			if selected_block != null: return
			_select_block(_get_next_block())
		
		if event.scancode == KEY_S:
			
			# Clear Selection and put selected block back in the queue
			if selected_block == null: return
			
			# The selected block goes back on the queue
			block_queue.push_front(selected_block)
			_clear_selection()
			
		
		if event.scancode == KEY_D:
			
			# Hold Block
			
			var block_selected = selected_block != null
			var block_held = held_block != null
			
			if !block_selected and !block_held: return
			
			if !block_selected and block_held:
				
				# Select the held block
				
				_select_block(held_block)
				held_block = null
				emit_signal("held_block_changed", null)
			
			if block_selected and block_held:
				# Swap selected and held
				var temp = selected_block
				_clear_selection()
				_select_block(held_block)
				held_block = temp
				emit_signal("held_block_changed", held_block.preview_image)
				

			
			# Block selected + no held block
			if block_selected and !block_held:
				
				# Put selected block in held
				held_block = selected_block
				_clear_selection()
				emit_signal("held_block_changed", held_block.preview_image)
		
			

func get_mouse_pos():
	return camera.get_global_mouse_position()

# Returns global coordinates
func get_quantized_cursor_pos():
	return board.quantize_position(get_mouse_pos())

# Returns tilemap coordinates
func get_selected_tile():
	return board.global_to_tile(get_mouse_pos())


func _on_enemy_killed():
	money += kill_reward
