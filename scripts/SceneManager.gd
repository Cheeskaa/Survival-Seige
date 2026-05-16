extends Node

# Holds the active instance reference to your Master World script
var world_node: Node2D = null

func travel_to(map_path: String, portal_name: String):
	if world_node and world_node.has_method("load_map"):
		world_node.load_map(map_path, portal_name)
