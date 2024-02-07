extends AnimatedSprite
var cursorDisabled = false

func _process(_delta):
	if cursorDisabled == false:
		self.position = get_global_mouse_position()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
