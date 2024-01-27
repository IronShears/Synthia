extends Button

onready var cursor = get_tree().get_root().get_node_or_null("/root/world/cursor")




func _on_mouse_entered():
	if cursor.animation == "default":
		cursor.play("ibar")


func _on_mouse_exited():
	if cursor.animation == "ibar":
		cursor.play("default")
