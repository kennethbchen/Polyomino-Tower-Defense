extends Node2D

var cell_size = 32

var cell_offset = Vector2(cell_size / 2, cell_size / 2)

onready var camera = $Camera2D

onready var cursor = $Cursor

onready var board = $BoardData

onready var block_queue = $BlockQueueHandler

onready var enemy_orchestrator = $EnemyOrchestrator

export var deletetion_cursor: Texture

export(PackedScene) var floating_text

export(int, LAYERS_2D_PHYSICS) var tower_physics_layer


# Enemy Stuff
var temp_enemy: Resource

var enemy_start = Vector2(1024, -352)
var enemy_end = Vector2(1024, 352)


# Player State

var health = 10
var money = 8

enum CursorState {IDLE, PLACING, DELETING, DEAD} # Probably should be PlayerState
var cursor_state = CursorState.IDLE

var selected_block: Node2D = null
var held_block: Node2D = null
var selected_tower: Resource

# Currency Stuff

var tower_cost = 4
var delete_cost = 2

var kill_reward = 1


signal health_changed(health)
signal held_block_changed(image)
signal money_amount_changed(money_amount)
signal tower_affordability_changed(can_afford)
signal player_died()

func _ready():
	
	selected_tower = load("res://Scenes/Tower.tscn")
	temp_enemy = load("res://Scenes/Enemy.tscn")
	
	_init_ui()

func _init_ui():
	emit_signal("money_amount_changed", money)
	emit_signal("health_changed", health)

# Game Actions

func select_next_block():
	
	if cursor_state == CursorState.PLACING: return

	_select_block(_get_next_block())

func deselect_block():
	# Clear Selection and put selected block back in the queue
	if cursor_state != CursorState.PLACING: return
	
	# The selected block goes back on the queue
	block_queue.push_front(_clear_selection())
	
func attempt_place():

				
	if !board.is_in_board(get_selected_tile()): 
		cursor.shake_effect()
		_create_floating_text("Out Of Bounds!")
		return # Cursor can't be out of bounds
		
	
	
	# TODO, There's a bug where you can bypass checks if you go fast
	
	# Verify that individual block squares are valid
	for pos in selected_block.get_children_global_pos():
		if !board.is_in_board(board.global_to_tile(pos)): 
			cursor.shake_effect()
			_create_floating_text("Out Of Bounds!")
			return
		
		if !board.is_walkable_tile(board.global_to_tile(pos)):
			cursor.shake_effect()
			_create_floating_text("Space Occupied!")
			return # Some block is out of bounds
	
	if money < tower_cost: 
		cursor.shake_effect()
		_create_floating_text("Not Enough Money!")
		
		return # Not enough money
	
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
			_create_floating_text("Blocks Path!")
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
	
	_change_money(-tower_cost)
	_create_floating_text("-$" + str(tower_cost))
	
	# The selected block is no longer needed
	selected_block.queue_free()
	_clear_selection()

func attempt_hold():
	# Hold Block
	# TODO: Move to separate function like the other actions?
	if cursor_state == CursorState.DELETING: _end_delete_mode()
	
	var block_selected = cursor_state == CursorState.PLACING
	var block_held = held_block != null
	
	if !block_selected and !block_held: return
	
	if !block_selected and block_held:
		
		# Select the held block
		
		_select_block(held_block)
		held_block = null
		emit_signal("held_block_changed", null)
	
	if block_selected and block_held:
		# Swap selected and held
		var temp = _clear_selection()
		_select_block(held_block)
		held_block = temp
		emit_signal("held_block_changed", held_block.preview_image)
		

	
	# Block selected + no held block
	if block_selected and !block_held:
		
		# Put selected block in held
		held_block = _clear_selection()
		emit_signal("held_block_changed", held_block.preview_image)
	
func attempt_delete():
				
	if money < delete_cost: 
		cursor.shake_effect()
		_create_floating_text("Not Enough Money!")
		
		return # Not enough money	
	
	if !board.is_in_board(board.global_to_tile(get_mouse_pos())):
		cursor.shake_effect()
		_create_floating_text("Out of Bounds!")
			
		return # Not enough money	
	
	
	# Check if there is a tower where the cursor is
	# Prepare to circle cast
	
	# TODO: General casting function?
	var space_state = get_world_2d().direct_space_state
			
	# Find the tower
	var hits = space_state.intersect_point(get_quantized_cursor_pos(), 1, [], tower_physics_layer, true, true)
	
	# Delete the tower, if found
	if !hits.empty():
		hits[0].collider.get_parent().destroy()
		_change_money(-delete_cost)

func toggle_delete_mode():
	if cursor_state == CursorState.DELETING:
		_end_delete_mode()
	else:
		_start_delete_mode()

# Input Handling

func _input(event):
	if event is InputEventMouseMotion:
		# Move the cursor
		var cursor_pos = Vector2.ZERO
		
		if board.is_in_board(get_selected_tile()):
			cursor_pos = get_quantized_cursor_pos() + cell_offset
			
		else:
			cursor_pos = get_mouse_pos()
			
		cursor.set_target_pos(cursor_pos)

func _unhandled_input(event):
	
	if cursor_state == CursorState.DEAD:
		return
	
	if cursor_state == CursorState.IDLE:
		
		if event.is_action_pressed("game_select_next_block"): select_next_block()
			
		if event.is_action_pressed("game_hold"): attempt_hold()
		
		if event.is_action_pressed("game_toggle_delete_mode"): toggle_delete_mode()

	elif cursor_state == CursorState.PLACING:
		
		# Maybe should be ui_select?
		if event.is_action_pressed("game_select"): attempt_place()
		
		if event.is_action_pressed("game_deselect"): deselect_block()
		
		if event.is_action_pressed("game_rotate"): cursor.rotate_90()
			
		if event.is_action_pressed("game_hold"): attempt_hold()
		
		if event.is_action_pressed("game_toggle_delete_mode"): toggle_delete_mode()
			
	elif cursor_state == CursorState.DELETING:
		
		if event.is_action_pressed("game_select_next_block"): select_next_block()
				
		if event.is_action_pressed("game_select"): attempt_delete()
				
		if event.is_action_pressed("game_toggle_delete_mode"): toggle_delete_mode()		
			
	# Debug Stuff
	if event is InputEventKey:
		
		if !event.pressed: return
		
		if event.scancode == KEY_SPACE:
			enemy_orchestrator._spawn_enemy()
			
		if event.scancode == KEY_Q:
			print(CursorState.keys()[cursor_state])
			
		if event.scancode == KEY_M:
			_change_money(9000)
			
		if event.scancode == KEY_N:
			_on_player_died()
		
			
		
		

func get_mouse_pos():
	return camera.get_global_mouse_position()

# Returns global coordinates
func get_quantized_cursor_pos():
	return board.quantize_position(get_mouse_pos())

func _get_next_block():
	return block_queue.pop_next_block()

# Un-selects the currently selected block
# Returns selected_block
# Does not do anything to the selected_block node itself other than return it
# It has to be dealt with separately
# TODO: Rename to _pop_selection()?
func _clear_selection():
	
	# Nothing selected
	if cursor_state != CursorState.PLACING: return
	
	cursor_state = CursorState.IDLE
	
	var temp = selected_block
	
	cursor.reset_rotation()
	cursor.remove_child(selected_block)
	
	selected_block = null
	
	return temp

func _select_block(block):
	
	# Already selecting a block
	if cursor_state == CursorState.PLACING: return
	
	if cursor_state == CursorState.DELETING: _end_delete_mode()
	
	cursor_state = CursorState.PLACING
	
	selected_block = block
	block.init(selected_tower)
	cursor.add_child(block)

func _start_delete_mode():
	
	if cursor_state == CursorState.PLACING:
		deselect_block()
		
	cursor.show_sprite(deletetion_cursor)
	
	cursor_state = CursorState.DELETING

func _end_delete_mode():
	cursor.hide_sprite()
	
	cursor_state = CursorState.IDLE

func _change_money(amount):
	
	money += amount
	
	emit_signal("money_amount_changed", money)
	
	if money >= tower_cost:
		emit_signal("tower_affordability_changed", true)
	else:
		emit_signal("tower_affordability_changed", false)
		
func _create_floating_text(message):
	var new_text = floating_text.instance()
	add_child(new_text)
	new_text.init(message, get_quantized_cursor_pos() + cell_offset + Vector2(0, -20))

# Returns tilemap coordinates
func get_selected_tile():
	return board.global_to_tile(get_mouse_pos())

func restart_game():
	get_tree().reload_current_scene()

# Signal Functions

func _on_player_died():
	emit_signal("player_died")
	
	if cursor_state == CursorState.PLACING:
		deselect_block()

	cursor_state = CursorState.DEAD

func _on_queue_display_selected():
	if cursor_state == CursorState.IDLE or cursor_state == CursorState.DELETING:
		select_next_block()
	elif cursor_state == CursorState.PLACING:
		deselect_block()
		
func _on_hold_display_selected():
	attempt_hold()

func _on_enemy_killed():
	_change_money(kill_reward)

func _on_body_entered_base(body):
	if body is Enemy:
		health = max(0, health - 1)
		
		emit_signal("health_changed", health)
		
		if health <= 0:
			_on_player_died()

