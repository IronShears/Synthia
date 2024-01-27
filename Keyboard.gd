extends Sprite

signal key_entered
var letters = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]

func _on_pressed_data(key):
	emit_signal("key_entered", key)


func _on_case_pressed():
	if $"1/Label".text == "A":
		for i in letters:
			get_tree().get_root().get_node_or_null("/root/world/Keyboard/"+str(i)+"/Label").text = get_tree().get_root().get_node_or_null("/root/world/Keyboard/"+str(i)+"/Label").text.to_lower()
			$case/ArrowButton.flip_v = true
	else:
		for i in letters:
			get_tree().get_root().get_node_or_null("/root/world/Keyboard/"+str(i)+"/Label").text = get_tree().get_root().get_node_or_null("/root/world/Keyboard/"+str(i)+"/Label").text.to_upper()
			$case/ArrowButton.flip_v = false
		
