extends Sprite
signal generated
var color = "Blue"
var style = null
var object = null


func reset():
	$IDE/ScreenOccluder.position = Vector2(67,64)
	$IDE/ColorRect.size = Vector2(0,2)
	$IDE/Screen.play("default")
	$IDE/ScreenOverlay.play("default")
	$IDE.object = null
	$IDE.style = null
	$IDE.color = "Blue"
	$IDE/loading.visible = false

func _on_Color_pressed(colorName, palette):
	if UniversalFunctions.locked == true:
		return
	var paletteLoad = load(palette)
	color = colorName
	$Screen.get_material().set_shader_param("palette_out", paletteLoad)
	$ScreenOverlay.get_material().set_shader_param("palette_out", paletteLoad)
	change_model($Screen.frame)

func _on_Style_pressed(nodeName):
	if UniversalFunctions.locked == true:
		return
	style = nodeName
	change_model($Screen.frame)
	
func _on_Object_pressed(nodeName):
	if UniversalFunctions.locked == true:
		return
	object = nodeName
	change_model($Screen.frame)
	
func change_model(screenFrame):
	if style != null and object != null:
		if object != "room":
			$Screen.play(str(style+object))
			$ScreenOverlay.play(str(style+object))
		else:
			$Screen.play(str(object))
		$Screen.frame = screenFrame
		$ScreenOverlay.frame = screenFrame
		pass



func _on_Generate_pressed():
	if style == null:
		return
	if object == null:
		return
	var value = 5
	
	if style == "Cool":
		value+=8
		if color == "Violet":
			value +=4
		elif color == "Orange":
			value +=4
		elif color == "Red":
			value +=3
		elif color == "Green":
			value +=3
		elif color == "White":
			value +=2
		elif color == "Pink":
			value +=2
		elif color == "Black":
			value +=1
		elif color == "Blue":
			value +=1
		elif color == "Yellow":
			value +=0
	elif style == "Cozy":
		value+=12
		if color == "Red":
			value +=4
		elif color == "Green":
			value +=4
		elif color == "Blue":
			value +=3
		elif color == "Orange":
			value +=3
		elif color == "Violet":
			value +=2
		elif color == "Pink":
			value +=2
		elif color == "Black":
			value +=1
		elif color == "White":
			value +=1
		elif color == "Yellow":
			value +=0
	elif style == "Cute":
		value+=16
		if color == "Blue":
			value +=4
		elif color == "Green":
			value +=4
		elif color == "Yellow":
			value +=3
		elif color == "Black":
			value +=3
		elif color == "White":
			value +=2
		elif color == "Orange":
			value +=2
		elif color == "Violet":
			value +=1
		elif color == "Red":
			value +=1
		elif color == "Pink":
			value +=0
		
	
	if color == "Blue" and style == "Cute" and object == "Room":
		value = 25
	elif color == "Orange" and style == "Cool" and object == "Room":
		value = 25
	elif color == "Green" and style == "Cozy" and object == "Room":
		value = 25
	
	
	var data = {
		"color": color,
		"style": style,
		"object": object,
		"value": value
	}
	emit_signal("generated", data)
	


func _on_Screen_animation_finished():
	if style == null:
		return
	if object != null:
		return
	$ScreenOverlay.frame = $Screen.frame


func _on_Screen_frame_changed():
	$ScreenOverlay.frame = $Screen.frame
