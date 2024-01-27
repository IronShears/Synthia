extends TextureButton

signal pressed_data

func _on_key_pressed():
	emit_signal("pressed_data", $Label.text)
