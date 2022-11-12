extends Control

class_name QueueDisplay

export var queue_position = 0

onready var preview_sprite = $PreviewImage

var test = load("res://Sprites/Tower.png")

func _on_queue_changed(block_queue):
	if preview_sprite == null: return
	preview_sprite.texture = block_queue[queue_position].instance().preview_image
