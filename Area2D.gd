extends Area2D

func _on_Selection_input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion:
		emit_signal("mouse_entered")
