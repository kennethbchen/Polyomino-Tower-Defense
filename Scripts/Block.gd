extends Node2D

var tower: Resource

export var block_texture_path: Resource

export var preview_image: Texture

export var block_texture: Texture = load("res://Sprites/Blocks/Block.png")


func init(tower_res: Resource):
	tower = tower_res
	
	# Each child is a block placeholder
	# Put a sprite where each placeholder is
	for child in self.get_children():
		var new_sprite = Sprite.new()
		new_sprite.texture = block_texture
		child.add_child(new_sprite)

func get_children_global_pos():
	var output = []
	for i in self.get_children():
		output.append(i.global_position)
		
	return output
