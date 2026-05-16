extends Area2D

# These slots will show up in your Gem inspector to hold your PNG images
@export var copper_png: Texture2D
@export var diamond_png: Texture2D
@export var emerald_png: Texture2D

var gem_type: String = "" # Passed automatically by the ore when it breaks

func _ready():
	# Tell Godot to run '_on_body_entered' when a physics body touches this item
	body_entered.connect(_on_body_entered)
	
	# Swap the visual sprite texture depending on what type of gem this is
	if gem_type == "copper":
		$Sprite2D.texture = copper_png
	elif gem_type == "diamond":
		$Sprite2D.texture = diamond_png
	elif gem_type == "emerald":
		$Sprite2D.texture = emerald_png

func _on_body_entered(body):
	# Check if the thing touching the gem belongs to the "player" group
	if body.is_in_group("player"):
		# 1. Add +1 to the global inventory tracking script
		if CraftingSystem.inventory.has(gem_type):
			CraftingSystem.inventory[gem_type] += 1
			print("Global inventory added +1 ", gem_type, ". Total: ", CraftingSystem.inventory[gem_type])
		
		# 2. Sync it with your local player inventory if your player script tracks it too
		if body.has_method("collect_item"):
			body.collect_item(gem_type)
			
		# 3. Delete the gem from the ground so you can't pick it up again
		queue_free()
