extends AnimatedSprite

var currentFileName
var currentFileNum
signal button_down
signal button_up

func _on_Button_button_down():
	if UniversalFunctions.locked == true:
		return
	emit_signal("button_down", currentFileNum,currentFileName)


func _on_Button_button_up():
	if UniversalFunctions.locked == true:
		return
	emit_signal("button_up", currentFileNum,currentFileName)
