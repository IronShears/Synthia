extends Node

onready var dialogueBox : Node2D = get_tree().get_root().get_node_or_null("/root/world/Commandprompt")
onready var synthia : Node2D = get_tree().get_root().get_node_or_null("/root/world/Virtualhell")
onready var nervousTimer : Timer = get_tree().get_root().get_node_or_null("/root/world/NervousTimer")
var dialogueJson
var dialoguePlaying

var swearWords = ["fuck", "shit", "bitch", "cunt", ]
var loneliness = 44
var disgust = 44
var locked = false
var topics = []
var firstName
var lastName

func reset():
	dialogueBox = get_tree().get_root().get_node_or_null("/root/world/Commandprompt")
	synthia = get_tree().get_root().get_node_or_null("/root/world/Virtualhell")
	nervousTimer = get_tree().get_root().get_node_or_null("/root/world/NervousTimer")

func _ready():
	var file = File.new()
	assert(file.file_exists("res://Resources/Text/Text.json"))
	file.open("res://Resources/Text/Text.json", file.READ)
	dialogueJson = parse_json(file.get_as_text())

func play_dialogue_JSON(dialogue : String):
	if dialoguePlaying == true:
		return
	nervousTimer.stop()
	dialoguePlaying = true
	get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option1").visible = false
	get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option2").visible = false
	get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options/Option3").visible = false
	if dialogueJson.has(dialogue) == false:
		dialogueBox.dialogue = dialogueJson["dialogueError"]
		dialogueBox.currentTree = "dialogueError"
		var dialoguechecker = dialogue.replace("Converge", "")
		if disgust < 60:
			if loneliness <60:
				if dialogueJson.has("fine"+dialoguechecker):
					dialogueBox.dialogue = dialogueJson["fine"+dialoguechecker]
					dialogueBox.currentTree = "fine"+dialoguechecker
			elif loneliness >= 60:
				if dialogueJson.has("sad"+dialoguechecker):
					dialogueBox.dialogue = dialogueJson["sad"+dialoguechecker]
					dialogueBox.currentTree = "angry"+dialoguechecker
		elif disgust >=60:
				if dialogueJson.has("angry"+dialoguechecker):
					dialogueBox.dialogue = dialogueJson["angry"+dialoguechecker]
					dialogueBox.currentTree = "angry"+dialoguechecker
		if dialogue.ends_with("Converge"):
			dialoguechecker = dialoguechecker.replace("Good", "")
			dialoguechecker = dialoguechecker.replace("Bad", "")
			dialoguechecker = dialoguechecker.replace("Bad", "")
			if disgust < 60:
				if loneliness <60:
					if dialogueJson.has("fine"+dialoguechecker):
						dialogueBox.dialogue = dialogueJson["fine"+dialoguechecker]
						dialogueBox.currentTree = "fine"+dialoguechecker
				elif loneliness >= 60:
					if dialogueJson.has("sad"+dialoguechecker):
						dialogueBox.dialogue = dialogueJson["sad"+dialoguechecker]
						dialogueBox.currentTree = "sad"+dialoguechecker
			elif disgust >=60:
					if dialogueJson.has("angry"+dialoguechecker):
						dialogueBox.dialogue = dialogueJson["angry"+dialoguechecker]
						dialogueBox.currentTree = "angry"+dialoguechecker
	else:
		dialogueBox.dialogue = dialogueJson[dialogue]
		dialogueBox.currentTree = dialogue
	dialogueBox.page = 0
	dialogueBox.endpoint = dialogueBox.dialogue.size() - 1
	dialogueBox.firstline = true
	dialogueBox._play_dialog()
	yield(dialogueBox, "done")
	nervousTimer.start()
	if synthia.z_index == 3 and locked == false:
		if dialogueBox.optionsVisible == true:
			get_tree().get_root().get_node_or_null("/root/world/Commandprompt/Options").visible = true
	dialoguePlaying = false
	

func change_scenes_reload(scene):
	get_tree().change_scene("res://main.tscn")
