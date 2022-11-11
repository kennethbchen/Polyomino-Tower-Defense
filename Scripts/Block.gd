extends Node2D

var tower: Resource

# Blocks do not come with visuals by default so the selected tower can override visuals
# For now, just made each block with temp art
var temp_visual = load("res://icon.svg")


func init(tower_res: Resource):
	tower = tower_res
	
	# Replace each block placeholder with tower sprite
	for child in self.get_children():
		var new_sprite = Sprite.new()
		new_sprite.texture = temp_visual
		child.add_child(new_sprite)


func get_children_global_pos():
	var output = []
	for i in self.get_children():
		output.append(i.global_position)
		
	return output
