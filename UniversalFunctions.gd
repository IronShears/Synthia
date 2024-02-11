extends Node

onready var dialogueBox : Node2D = get_tree().get_root().get_node_or_null("/root/world/Commandprompt")
onready var synthia : Node2D = get_tree().get_root().get_node_or_null("/root/world/Virtualhell")
onready var world : Node2D = get_tree().get_root().get_node_or_null("/root/world/")
onready var nervousTimer : Timer = get_tree().get_root().get_node_or_null("/root/world/NervousTimer")
var dialogueJson
var dialogueEnded = false
var loneliness = 44
var disgust = 15
var locked = false
var interest
var firstName = "null"
var lastName = "null"
var variableOptions = "AdaSurprise"
var emptyFilled = "stillEmpty"
var nameReaction = "nameNormal"
var TalkAbout = {"SpendTime":false,
				"WhatWereYouLike":false,
				"ElfTalk":false,
				"RequiresBlowAWish": true,
				"AdaSurpriseUgly":false,
				"AdaNonSurpriseUgly":true,
				"Oscilator":true,
				"OscilatorNon":true,
				"CultDirect":true,
				"CultNonDirect":true,
				"DungeonsAndDragonsCont":true}
var adaOrYou = "you"
var foundationSnippet = "noFoundation"
var ending = "firedBest"
var generating = false

func reset():
	dialogueBox = get_tree().get_root().get_node_or_null("/root/world/Commandprompt")
	synthia = get_tree().get_root().get_node_or_null("/root/world/Virtualhell")
	nervousTimer = get_tree().get_root().get_node_or_null("/root/world/NervousTimer")
	world = get_tree().get_root().get_node_or_null("/root/world/")

func _ready():
	var file = File.new()
	assert(file.file_exists("res://Resources/Text/Text.json"))
	file.open("res://Resources/Text/Text.json", file.READ)
	dialogueJson = parse_json(file.get_as_text())

func play_dialogue_JSON(dialogue : String):
	if nervousTimer != null:
		nervousTimer.stop()
	get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option1").visible = false
	get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option2").visible = false
	get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option3").visible = false
	if dialogueJson.has(dialogue) == false:
		dialogueBox.dialogue = dialogueJson["dialogueError"]
		dialogueBox.currentTree = dialogue
		if disgust < 20:
			if loneliness <60:
				if dialogueJson.has("fine"+dialogue):
					dialogueBox.dialogue = dialogueJson["fine"+dialogue]
					dialogueBox.currentTree = "fine"+dialogue
			elif loneliness >= 60:
				if dialogueJson.has("sad"+dialogue):
					dialogueBox.dialogue = dialogueJson["sad"+dialogue]
					dialogueBox.currentTree = "angry"+dialogue
		elif disgust >=20:
				if dialogueJson.has("angry"+dialogue):
					dialogueBox.dialogue = dialogueJson["angry"+dialogue]
					dialogueBox.currentTree = "angry"+dialogue
	else:
		dialogueBox.dialogue = dialogueJson[dialogue]
		dialogueBox.currentTree = dialogue
		
	#makes sure the past dialogue plays the right dialogue
	if dialogueBox.dialogue != dialogueJson["dialogueError"]:
		if dialogueBox.pastDialogue[-1]["name"] == dialogue:
			print("SET PAST DIALOGUE HERE")
			dialogueBox.pastDialogue[-1]["name"] = dialogueBox.currentTree
	dialogueBox.page = 0
	dialogueBox.endpoint = dialogueBox.dialogue.size() - 1
	dialogueBox.firstline = true
	dialogueBox._play_dialog()
	yield(dialogueBox, "done")
	
	if nervousTimer != null:
		nervousTimer.start()
	

func change_scenes_reload(scene):
	get_tree().change_scene(scene)
	
func change_scenes_reset(scene):
	get_tree().change_scene(scene)
	dialogueEnded = false
	loneliness = 44
	disgust = 15
	locked = false
	firstName = "null"
	lastName = "null"
	variableOptions = "AdaSurprise"
	emptyFilled = "stillEmpty"
	nameReaction = "nameNormal"
	TalkAbout = {"SpendTime":false,
				"WhatWereYouLike":false,
				"ElfTalk":false}
	adaOrYou = "you"
	ending = "firedBest"
