extends Node2D

var process = false
var setMousePos
var split

func _ready():
	UniversalFunctions.reset()
	if UniversalFunctions.ending == "firedBest":
		$Paper/RichTextLabel.set_bbcode(UniversalFunctions.dialogueJson["firedText"])
	else:
		var text = UniversalFunctions.dialogueJson[UniversalFunctions.ending+"Text"]
		if UniversalFunctions.disgust < 20:
			if UniversalFunctions.loneliness > 60:
				text = text.replace("{moodInsert}", UniversalFunctions.dialogueJson["sadInsert"])
			else:
				text = text.replace("{moodInsert}", UniversalFunctions.dialogueJson["fineInsert"])
		else:
			text = text.replace("{moodInsert}", UniversalFunctions.dialogueJson["angryInsert"])
		$Paper/RichTextLabel.set_bbcode(text)
	$Paper/Label.text = UniversalFunctions.dialogueJson["SCPFoundation"]
	$Commandprompt/shell.visible = false
	$AnimationPlayer.play("loadIn")
	yield($AnimationPlayer,"animation_finished")
	$Paper.visible = true

func _process(_delta):
	if process == true:
		if get_global_mouse_position().y < setMousePos:
			if $Paper.position.y < 200:
				$Paper.position.y += 2
			else:
				$Paper.position.y = 200
		elif  get_global_mouse_position().y > setMousePos:
			
			if $Paper.position.y > 40:
				$Paper.position.y -= 2
			else:
				$Paper.position.y = 40



func _on_Close_pressed():
	$Paper.visible = false
	$AnimationPlayer.play_backwards("loadIn")
	yield($AnimationPlayer,"animation_finished")
	if UniversalFunctions.ending == "firedBest":
		$Commandprompt.visible = true
		UniversalFunctions.play_dialogue_JSON("firedBest")
		yield($Commandprompt,"done")
		$Commandprompt/Options.visible = true
		yield($Commandprompt/Options/Option1,"pressed")
		print("ran")
		$Commandprompt.visible = false
	$AnimationPlayer.play("Credits")
	yield($AnimationPlayer,"animation_finished")
	UniversalFunctions.change_scenes_reset("res://login.tscn")


func _on_PaperScroller_button_down():
	setMousePos = get_global_mouse_position().y
	process = true


func _on_PaperScroller_button_up():
	process = false
