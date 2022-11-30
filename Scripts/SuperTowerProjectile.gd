extends TowerProjectile



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_body_hit(body: Node):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	destroy()
