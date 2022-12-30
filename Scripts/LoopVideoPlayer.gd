extends VideoPlayer

func _process(delta):
	if !is_playing():
		play()

func _on_VideoPlayer_finished():
	play()
