extends AnimatedSprite

func _process(_delta):
	self.position = get_global_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
