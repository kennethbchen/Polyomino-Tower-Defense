extends TileMap


func _on_tower_created(global_pos):
	# Could be built in function
	
	# Set the navigation tile in the right place for navigation
	set_cellv(world_to_map(to_local(global_pos)), Util.NAV_BLOCKED_TILE)

func _on_tower_destroyed(global_pos):
	
	# Could be built in function
	
	# Set the navigation tile in the right place for navigation
	set_cellv(world_to_map(to_local(global_pos)), Util.NAV_ALLOWED_TILE)

func is_in_board(tilemap_coordinate: Vector2):

	if 0 <= tilemap_coordinate.x and tilemap_coordinate.x <= Util.board_width - 1 and \
		0 <= tilemap_coordinate.y and tilemap_coordinate.y <= Util.board_height - 1:
		return true
	else:
		return false
		
func is_free_space(tilemap_coord: Vector2):
	if is_in_board(tilemap_coord) and get_cellv(tilemap_coord) == Util.NAV_ALLOWED_TILE:
		return true
	else:
		return false
		
func global_to_tile(global_position: Vector2):
	return world_to_map(to_local(global_position))
	
func set_tile(tilemap_position: Vector2):
	set_cellv(tilemap_position, 0)

# Returns global coordinates
func quantize_position(global_position: Vector2):
	return map_to_world(world_to_map(global_position))
