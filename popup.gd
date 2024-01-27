extends Sprite

onready var cursor = get_tree().get_root().get_node_or_null("/root/world/cursor")

func _on_mouse_entered():
	if cursor.animation == "default":
		cursor.play("locked")


func _on_mouse_exited():
	if cursor.animation == "locked":
		cursor.play("default")

func _on_TextureButton_pressed():
	pass # Replace with function body.
