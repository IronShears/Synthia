extends Sprite
signal generated
var color = "Blue"
var style = "Cool"
var object = "Room"
var currentRoom = "Blue"
var colorMatchesGood = {
	"Red":[ "Red", "Orange", "Green", "Blue", "Violet", "Pink", "Black"],
	"Orange":["Orange", "Yellow", "Violet", "Blue"],
	"Yellow":["Red", "Orange", "Green", "Blue", "Pink"],
	"Green":[ "Green", "Blue", "Violet", "Pink"],
	"Blue":[ "Red", "Orange", "Yellow", "Green", "Blue", "Pink"],
	"Violet":[ "Red", "Orange", "Yellow", "Green", "Violet", "Black", "Pink"],
	"Pink":["Red", "Orange", "Green", "Blue", "Violet","Black", "Pink"],
	"Black":["Blue", "Violet", "Pink","White"],
	"White":["Green", "Blue","Violet","Black"]
}

func reset():
	$select.text = UniversalFunctions.dialogueJson["select"]
	$ScreenOccluder.position = Vector2(67,64)
	$ColorRect.rect_size = Vector2(0,2)
	$Screen.play("default")
	$ScreenOverlay.play("default")
	object = null
	style = null
	color = "Blue"
	$loading.visible = false

func _on_Color_pressed(colorName, palette):
	if UniversalFunctions.dialogueEnded == true:
		return
	if UniversalFunctions.generating == true:
		return
	if UniversalFunctions.locked == true:
		return
	var paletteLoad = load(palette)
	color = colorName
	if object != null:
		if style != null:
			$select.text = UniversalFunctions.dialogueJson[color]+"+"+UniversalFunctions.dialogueJson[style]+"+"+UniversalFunctions.dialogueJson[object]
		else:
			$select.text = UniversalFunctions.dialogueJson[color]+"+???+"+UniversalFunctions.dialogueJson[object]
	elif style != null:
		if object != null:
			$select.text = UniversalFunctions.dialogueJson[color]+"+"+UniversalFunctions.dialogueJson[style]+"+"+UniversalFunctions.dialogueJson[object]
		else:
			$select.text = UniversalFunctions.dialogueJson[color]+"+"+UniversalFunctions.dialogueJson[style]+"+???"

	$Screen.get_material().set_shader_param("palette_out", paletteLoad)
	$ScreenOverlay.get_material().set_shader_param("palette_out", paletteLoad)
	change_model($Screen.frame)

func _on_Style_pressed(nodeName):
	if UniversalFunctions.dialogueEnded == true:
		return
	if UniversalFunctions.generating == true:
		return
	if UniversalFunctions.locked == true:
		return
	style = nodeName
	if object != null:
		$select.text = UniversalFunctions.dialogueJson[color]+"+"+UniversalFunctions.dialogueJson[style]+"+"+UniversalFunctions.dialogueJson[object]
	else:
		$select.text = UniversalFunctions.dialogueJson[color]+"+"+UniversalFunctions.dialogueJson[style]+"+???"
	change_model($Screen.frame)
	
func _on_Object_pressed(nodeName):
	if UniversalFunctions.dialogueEnded == true:
		return
	if UniversalFunctions.generating == true:
		return
	if UniversalFunctions.locked == true:
		return
	object = nodeName
	if style != null:
		$select.text = UniversalFunctions.dialogueJson[color]+"+"+UniversalFunctions.dialogueJson[style]+"+"+UniversalFunctions.dialogueJson[object]
	else:
		$select.text = UniversalFunctions.dialogueJson[color]+"+???+"+UniversalFunctions.dialogueJson[object]
	change_model($Screen.frame)
	
func change_model(screenFrame):
	if style != null and object != null:
		$Screen.play(str(style+object))
		$ScreenOverlay.play(str(style+object))
		$Screen.frame = screenFrame
		$ScreenOverlay.frame = screenFrame



func _on_Generate_pressed():
	if UniversalFunctions.dialogueEnded == true:
		return
	if UniversalFunctions.generating == true:
		return
	if UniversalFunctions.locked == true:
		return
	if style == null:
		return
	if object == null:
		return
	var value = 5
	
	if object == "Room":
		currentRoom = color
		if style == "Cool":
			value+=0
			if color == "Orange":
				value = 25
			elif color == "Violet" or color == "Red":
				value +=10
			elif color == "Green"  or color == "Blue":
				value +=5
			elif color == "Yellow" or color == "Pink" or color == "White" or color == "Black":
				value +=0
		elif style == "Cozy":
			value+=3
			if color == "Blue":
				value = 25
			elif color == "Red" or color == "Orange" or color == "Blue" or color == "Violet" or color == "Pink":
				value +=10
			elif color == "Yellow"  or color == "White":
				value +=5
			elif color == "Black":
				value +=0
		elif style == "Cute":
			value+=6
			if color == "Blue":
				value = 25
			elif color == "Red" or color == "Violet" or color == "Pink" or color == "White":
				value +=10
			elif color == "Yellow"  or color == "Orange" or  color == "Black":
				value +=5
			elif color == "Green":
				value +=0
	else:
		if object == "Chair":
			if style == "Cool":
				value +=10
			elif style == "Cute":
				value +=0
			elif style == "Cozy":
				value +=5
		elif object == "Bed":
			if style == "Cool":
				value +=0
			elif style == "Cute":
				value +=5
			elif style == "Cozy":
				value +=10
		elif object == "Decor":
			value +=10
		
		for i in colorMatchesGood[currentRoom]:
			if i == color:
				value += 10
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
