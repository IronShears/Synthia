# DialogBox.gd
extends Node

# Variables
onready var cursor = get_tree().get_root().get_node_or_null("/root/world/cursor")
signal done
signal option_pressed
var options

var pastDialogue = [{"name":"start", "text":"start"}]
var playerName = "Ada"

onready var textBox : RichTextLabel = $Dialogue
onready var timer : Timer = $Timer
onready var text: String
onready var time = 0.05
onready var closetime = 1
onready var dialogue
onready var page = null
var color
onready var endpoint 
var firstline
var rng = RandomNumberGenerator.new()
var clip1
var clip2
var clip3
var optionsVisible = false
var currentTree
var mood = ""
var prevOption = 0

var objectName = "Room"
var colorName = "Blue"
var styleName = "Cool"


func _play_dialog():
	set_up()
	$Options.visible = false
#	$Voice.playing = false
	textBox.set_process_input(true)
	textBox.set_bbcode(text)
	textBox.set_visible_characters(0)
	timer.wait_time = time
	$AutoCloseTimer.wait_time = closetime



func _on_SkipInput_pressed():
	if dialogue != null:
		if textBox.get_visible_characters() < textBox.get_total_character_count():
			textBox.set_visible_characters(textBox.get_total_character_count())
			$AutoCloseTimer.start()
		else:
			skip_input()

func skip_input():
	if page < endpoint:
		UniversalFunctions.dialoguePlaying = true
		UniversalFunctions.nervousTimer.stop()
		_play_dialog()
	else:
		emit_signal("done")
		if dialogue[page].has("continue"):
			UniversalFunctions.play_dialogue_JSON(dialogue[page]["continue"])

func set_up():
	first_line()
#	$Voice.stream = load("res://Resources/Voices/"+currentTree+str(page)+".wav")
#	$Voice.play()
	if dialogue[page].has("split"):
		get_tree().get_root().get_node_or_null("/root/world/").split = dialogue[page]["split"]
	else:
		get_tree().get_root().get_node_or_null("/root/world/").split = null
		
		
	#changes all the variables in text
	text = dialogue[page]["text"]
	text = text.replace("{insertText}",pastDialogue[-1]["text"])
	text = text.replace("{object}",UniversalFunctions.dialogueJson[objectName])
	text = text.replace("{color}",UniversalFunctions.dialogueJson[colorName])
	text = text.replace("{style}",UniversalFunctions.dialogueJson[styleName])
	if currentTree == "newObjectPerfect" or currentTree == "newObjectGood" or currentTree == "newObjectBad" or currentTree == "newObjectNeutral":
		if UniversalFunctions.dialogueJson.has(colorName+styleName+objectName):
			text = text.replace("{styleObject}",UniversalFunctions.dialogueJson[colorName+styleName+objectName])
		else:
			text = text.replace("{styleObject}",UniversalFunctions.dialogueJson[styleName+objectName])
	text = text.replace("{nameReaction}", UniversalFunctions.dialogueJson[UniversalFunctions.nameReaction])
	text = text.replace("{name}", playerName)
	text = text.replace("Ada", UniversalFunctions.dialogueJson["ada"])
	text = text.replace("{emptyFilled}", UniversalFunctions.dialogueJson[UniversalFunctions.emptyFilled])
	text = text.replace("{missingDialogue}", currentTree)
	
	#changes the color of the text and plays sprites
	if dialogue[page]["color"] == "Teal":
		text = "[color=#306082]"+text+"[/color]"
	if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia") != null:
		if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia").animation != dialogue[page]["sprite"]:
			if dialogue[page]["sprite"] != "null":
				get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia").play(dialogue[page]["sprite"])
		
	#sets the options
	optionsVisible = dialogue[page]["optionsVisible"]
	if optionsVisible == true:
		if UniversalFunctions.dialogueJson.has(dialogue[page]["options"]):
			options = UniversalFunctions.dialogueJson[dialogue[page]["options"]]
		else:
			if UniversalFunctions.disgust < 20:
				options = UniversalFunctions.dialogueJson["optionsError"]
			if dialogue[page]["options"] == "{variableOption}":
				options = UniversalFunctions.dialogueJson[UniversalFunctions.variableOptions]


		var AlreadyUsed = []
		var counter = options.size()
		for i in options:
			if UniversalFunctions.TalkAbout.has(i["name"]): 
				if UniversalFunctions.TalkAbout[i["name"]] == true:
					AlreadyUsed.append(i)
			if not AlreadyUsed.has(i):
				var optText = ">"+i["text"]
				optText = optText.replace("{missingOptions}",dialogue[page]["options"])
				optText = optText.replace("{name}",UniversalFunctions.firstName)
				get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option"+str(counter)).visible = true
				get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option"+str(counter)).text = optText
				get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option"+str(counter)).currentTopic = i
			
				counter-=1
	color = dialogue[page]["color"]
	time = dialogue[page]["tickSpeed"]
	closetime = dialogue[page]["closeSpeed"]

func first_line():
	if firstline == true:
		firstline = false
	else:
		page += 1


func _on_Timer_timeout():
	if dialogue != null:
		if textBox.visible_characters < textBox.get_total_character_count():
			if  textBox.visible_characters < textBox.get_total_character_count()-1:
				if text[textBox.visible_characters+1] == " ":
					textBox.set_visible_characters(textBox.get_visible_characters()+1)
#			if color == "pink":
#				if $Voice.playing == false and text[textBox.visible_characters] != ".": 
#					rng.randomize()
#					var pitch 
#					if dialogue[page]["tickSpeed"] == 0.05:
#						pitch = rng.randf_range(0.90, 1.05)
#					elif  dialogue[page]["tickSpeed"] > 0.5:
#						pitch = rng.randf_range(0.90 - (dialogue[page]["tickSpeed"]*15), 1.05 - (dialogue[page]["tickSpeed"]*15))
#					elif  dialogue[page]["tickSpeed"] < 0.5:
#						pitch = rng.randf_range(0.90 + (abs(dialogue[page]["tickSpeed"]-0.10) *4), 1.05 + (abs(dialogue[page]["tickSpeed"]-0.10) *4))
#					$Voice.pitch_scale =  pitch
#					var aeiouy = ["a", "e", "i", "o", "u", "y", "A", "E", "I", "O", "U", "Y"]
#					var bcdfghjklmn = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "B", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N"]
#					var clip = clip3
#
#					for i in aeiouy:
#						if text[textBox.visible_characters] == i:
#							clip = clip1
#					for i in bcdfghjklmn:
#						if text[textBox.visible_characters] == i:
#							clip = clip2
#					$Voice.stream = clip
#					$Voice.play()
				
		textBox.set_visible_characters(textBox.get_visible_characters()+1)
		if textBox.visible_characters == textBox.get_total_character_count():
			$AutoCloseTimer.start()
			var spriteSetter = dialogue[page]["sprite"]
			spriteSetter=spriteSetter.replace("1","Static")
			spriteSetter=spriteSetter.replace("2","Static")
			spriteSetter=spriteSetter.replace("floor","floorStatic")
			if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia") != null:
				if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia").animation != spriteSetter:
					if dialogue[page]["sprite"] != "null":
						get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia").play(spriteSetter)
			
		


func _on_AutoCloseTimer_timeout():
#	if $Voice.playing == true:
#		yield($Voice,"finished")
#	$Voice.playing = false
	UniversalFunctions.dialoguePlaying = false
	UniversalFunctions.nervousTimer.start()
	#skip_input()
	


func _on_Voice_finished():
	if textBox.visible_characters == textBox.get_total_character_count():
		$AutoCloseTimer.start()

func set_mood():
	cursor.play("default")
	if UniversalFunctions.disgust < 20:
		if UniversalFunctions.loneliness <60:
			mood = "fine"
		elif UniversalFunctions.loneliness >= 60:
			mood = "sad"
	else:
			mood = "angry"

func _on_Option3_pressed(currentNode):
	
	set_mood()
	if not get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/"+currentNode).currentTopic["name"].ends_with("forgotten"):
		pastDialogue.append({"name": get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/"+currentNode).currentTopic["name"],
							"text": get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/"+currentNode).currentTopic["text"],
							"mood": mood
			})

	if UniversalFunctions.TalkAbout.has(get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/"+currentNode).currentTopic["name"]): 
		UniversalFunctions.TalkAbout[get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/"+currentNode).currentTopic["name"]] = true
	prevOption = get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/"+currentNode).currentTopic
	emit_signal("option_pressed", get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/"+currentNode).currentTopic["name"])


