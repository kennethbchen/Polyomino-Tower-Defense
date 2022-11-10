extends Area2D

export var damage = 1

export var move_speed = 350

export var time_to_live = 3

onready var ttl_timer = $TTLTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	ttl_timer.wait_time = time_to_live
	ttl_timer.start()
	
func _physics_process(delta):
	position += transform.x * move_speed * delta


func _on_time_to_live_timeout():
	destroy()
	
func destroy():
	queue_free()

func _on_body_entered(body: Node):
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
	destroy()
	
