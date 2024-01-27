extends Sprite

signal button_up
signal button_down


func _on_systemFile_button_up():
	emit_signal("button_up", name)


func _on_systemFile_button_down():
	emit_signal("button_down", name)
