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
var a = preload("res://Resources/Voices/a.wav")
var e = preload("res://Resources/Voices/e.wav")
var i = preload("res://Resources/Voices/i.wav")
var o = preload("res://Resources/Voices/o.wav")
var u = preload("res://Resources/Voices/u.wav")
var optionsVisible = false
var currentTree
var mood = ""
var prevOption = 0

var objectName = "Room"
var colorName = "Blue"
var styleName = "Cool"


func _play_dialog():
	$Options.visible = false
	set_up()
#	$Voice.playing = false
	textBox.set_process_input(true)
	textBox.set_bbcode(text)
	textBox.set_visible_characters(0)
	timer.wait_time = time
	$AutoCloseTimer.wait_time = closetime



func _on_SkipInput_pressed():
	if UniversalFunctions.locked == true:
		return
	if dialogue != null:
		if textBox.get_visible_characters() < textBox.get_total_character_count():
			textBox.set_visible_characters(textBox.get_total_character_count())
			$AutoCloseTimer.start()
			var spriteSetter = dialogue[page]["sprite"]
			
			spriteSetter.replace("Object",objectName)
			spriteSetter=spriteSetter.replace("1","Static")
			spriteSetter=spriteSetter.replace("2","Static")
			if not "Static" in spriteSetter:
				spriteSetter=spriteSetter.replace("floor","floorStatic")
			if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia") != null:
				if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia").animation != spriteSetter:
					if dialogue[page]["sprite"] != "null":
						get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia").play(spriteSetter)
				if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/").z_index == 3:
					
					if optionsVisible == true:
						$Options.visible = true
			else:
				if optionsVisible == true:
					$Options.visible = true
	
		else:
			skip_input()

func skip_input():
	if page < endpoint:
		if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/") != null:
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
	if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia") != null:
		if UniversalFunctions.foundationSnippet == "noFoundation":
			if get_tree().get_root().get_node_or_null("/root/world/").distractions.size() == 0:
				set_mood()
				text = text.replace("{FoundationSnippet}", UniversalFunctions.dialogueJson[mood+UniversalFunctions.foundationSnippet])
			
			else:
				text = text.replace("{FoundationSnippet}", UniversalFunctions.dialogueJson["fired"+UniversalFunctions.foundationSnippet])
		
		else:
			if get_tree().get_root().get_node_or_null("/root/world/").distractions.size() == 0:
				set_mood()
				text = text.replace("{FoundationSnippet}", UniversalFunctions.dialogueJson[mood+UniversalFunctions.foundationSnippet])
			else:
				text = text.replace("{FoundationSnippet}", UniversalFunctions.dialogueJson["fired"+UniversalFunctions.foundationSnippet])
		
		text = text.replace("{DiscoveredIDEInsert}", UniversalFunctions.dialogueJson[str(get_tree().get_root().get_node_or_null("/root/world/Taskbar/Icons/IDE").visible)+"DiscoveredIDEInsert"])
		if get_tree().get_root().get_node_or_null("/root/world/").filesDeleted == 0:
			text = text.replace("{deletedFiles}", UniversalFunctions.dialogueJson["deletedFilesFalse"])
		else:
			text = text.replace("{deletedFiles}", UniversalFunctions.dialogueJson["deletedFilesTrue"])
		
	
		if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia").animation != dialogue[page]["sprite"]:

			var spriteSetter = dialogue[page]["sprite"]
			spriteSetter.replace("Object",objectName)
			get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia").play(spriteSetter)

				

	#changes the color of the text and plays sprites
	if dialogue[page]["color"] == "Teal":
		text = "[color=#306082]"+text+"[/color]"
			
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
		randomize()
		options.shuffle()
		var counter = 1
		var AlreadyUsed = []
		for i in options:
			if UniversalFunctions.TalkAbout.has(i["name"]): 
				if UniversalFunctions.TalkAbout[i["name"]] == true:
					AlreadyUsed.append(i)
			if not AlreadyUsed.has(i):
				if counter >3:
					break
				var optText = ">"+i["text"]
				optText = optText.replace("{missingOptions}",dialogue[page]["options"])
				optText = optText.replace("{name}",UniversalFunctions.firstName)
				get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option"+str(counter)).visible = true
				get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option"+str(counter)).text = optText
				get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option"+str(counter)).currentTopic = i
				
				counter+=1
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
			if color == "Pink":
				if $Voice.playing == false:
					var currentChar = text[textBox.visible_characters]
					currentChar = currentChar.to_lower() 
					var nextChar = " "
					var thirdChar = " "
					if textBox.visible_characters < textBox.get_total_character_count()-2:
						nextChar = text[textBox.visible_characters+1]
						nextChar = currentChar.to_lower() 
						thirdChar = text[textBox.visible_characters+2]
						thirdChar = currentChar.to_lower() 
					rng.randomize()
					var pitch 
					if "Smile" in dialogue[page]["sprite"]:
						pitch = rng.randf_range(1.05, 1.15)
					elif "Angry" in dialogue[page]["sprite"]:
						pitch = rng.randf_range(1.02, 1.12)
					elif "Sad" in dialogue[page]["sprite"]:
						pitch = rng.randf_range(0.90, 1.00)
					elif "Nervous" in dialogue[page]["sprite"]:
						pitch = rng.randf_range(0.95, 1.05)
					else:
						pitch = rng.randf_range(1.00, 1.10)
					$Voice.pitch_scale = pitch
					if currentChar == "a":
						$Voice.stream = a
					elif currentChar == "e":
						$Voice.stream = e
					elif currentChar == "i":
						$Voice.stream = i
					elif currentChar == "o":
						$Voice.stream = o
					elif currentChar == "u":
						$Voice.stream = u
					else:
						if nextChar == "a":
							$Voice.stream = a
						elif nextChar == "e":
							$Voice.stream = e
						elif nextChar == "i":
							$Voice.stream = i
						elif nextChar == "o":
							$Voice.stream = o
						elif nextChar == "u":
							$Voice.stream = u
						else:
							if thirdChar == "a":
								$Voice.stream = a
							elif thirdChar == "e":
								$Voice.stream = e
							elif thirdChar == "i":
								$Voice.stream = i
							elif thirdChar == "o":
								$Voice.stream = o
							elif thirdChar == "u":
								$Voice.stream = u
							else:
								if currentChar in ["b","c","d","f"]:
									$Voice.stream = a
								elif currentChar in ["g","h","j","k"]:
									$Voice.stream = e
								elif currentChar in ["l","m","n","p",]:
									$Voice.stream = i
								elif currentChar in ["q","r","s","t"]:
									$Voice.stream = o
								elif currentChar in ["v","w","x","y","z"]:
									$Voice.stream = u
					if currentChar != " " and  currentChar !="." and  currentChar !="?" and  currentChar !="!":
						$Voice.play()
						
							
				
		textBox.set_visible_characters(textBox.get_visible_characters()+1)
		if textBox.visible_characters == textBox.get_total_character_count():
			$AutoCloseTimer.start()
			var spriteSetter = dialogue[page]["sprite"]
			spriteSetter=spriteSetter.replace("1","Static")
			spriteSetter=spriteSetter.replace("2","Static")
			spriteSetter.replace("Object",objectName)
			if not "Static" in spriteSetter:
				spriteSetter=spriteSetter.replace("floor","floorStatic")
			if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia") != null:
				if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia").animation != spriteSetter:
					if dialogue[page]["sprite"] != "null":
						get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Synthia").play(spriteSetter)
				if optionsVisible == true:
					if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/").z_index == 3:
						$Options.visible = true
			else:
				if optionsVisible == true:
					$Options.visible = true
		


func _on_AutoCloseTimer_timeout():
#	if $Voice.playing == true:
#		yield($Voice,"finished")
#	$Voice.playing = false
	if closetime == 0.05 or closetime == 1.1:
		skip_input()
	else:
		if get_tree().get_root().get_node_or_null("/root/world/Virtualhell/") != null:
			UniversalFunctions.nervousTimer.start()
	


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


