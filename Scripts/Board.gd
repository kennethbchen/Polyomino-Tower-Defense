extends TileMap


func _on_tower_created(global_pos):	
	# Set the navigation tile in the right place for navigation
	set_cellv(world_to_map(to_local(global_pos)), Util.NAV_BLOCKED_TILE)

func _on_tower_destroyed(global_pos):
	# Set the navigation tile in the right place for navigation
	set_cellv(world_to_map(to_local(global_pos)), Util.NAV_ALLOWED_TILE)

# In board means within allowed block placing area
func is_in_board(tilemap_coordinate: Vector2):

	if 0 <= tilemap_coordinate.x and tilemap_coordinate.x <= Util.board_width - 1 and \
		0 <= tilemap_coordinate.y and tilemap_coordinate.y <= Util.board_height - 1:
		return true
	else:
		return false

func is_walkable_tile(tilemap_coordinate: Vector2):
	return get_cellv(tilemap_coordinate) == Util.NAV_ALLOWED_TILE

func global_to_tile(global_position: Vector2):
	return world_to_map(to_local(global_position))

func tile_to_global(tilemap_position: Vector2):
	return to_global(map_to_world(tilemap_position))

# Returns global coordinates
func quantize_position(global_position: Vector2):
	return map_to_world(world_to_map(global_position))


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

# This assumes that 0,0 is the top left tile in the area where placing blocks is allowed
func is_complete_line(row, proposed_blocks: Array):
	var current_tile = Vector2(0, row)
	
	# Keep checking if there is a continuous chain of blocked tiles
	while(get_cellv(current_tile) == Util.NAV_BLOCKED_TILE or proposed_blocks.has(current_tile)):
		current_tile += Vector2(1,0)
		
	# If the line is completed, then current_tile should now be an empty tile
	if get_cellv(current_tile) == -1:
		return true
	else:
		return false
