extends TileMapLayer

# These come directly from your screenshot
var tree_source_id: int = 28
var tree_atlas_coords: Vector2i = Vector2i(0, 0)
@export var respawn_time: float = 10.0 # Change this to how long you want to wait

func harvest_tree(map_pos: Vector2i):
	# 1. Check if there is actually a tree at this grid position
	if get_cell_source_id(map_pos) == -1:
		return # No tree here, do nothing
	
	# 2. Remove the tree (Set to -1)
	set_cell(map_pos, -1)
	print("Tree cut at: ", map_pos)
	
	# 3. Wait for the respawn time
	await get_tree().create_timer(respawn_time).timeout
	
	# 4. Grow the tree back using your Source 28 and Atlas (0,0)
	set_cell(map_pos, tree_source_id, tree_atlas_coords)
	print("Tree grew back at: ", map_pos)
