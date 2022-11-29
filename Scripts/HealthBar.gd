extends Node2D

onready var bar = $TextureProgress

func _on_health_changed(current_health, max_health):
	bar.max_value = max_health
	bar.value = current_health
