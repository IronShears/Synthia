extends Node2D

var order = ["IDE", "FileSystem", "Virtualhell", "File"]
var intro = "null"
var distractions = []
var rng = RandomNumberGenerator.new()
var warning = null
var warningNode = null
var filesDeleted = 0
var hour = 9
var minute = 00
var frozen = false
var tempData = null
var split = null

func _ready():
	UniversalFunctions.reset()
	$File/ScrollContainer/VBoxContainer/Cynthia/description.text = UniversalFunctions.dialogueJson["SCPTextImage"]
	var scpText = UniversalFunctions.dialogueJson["SCPText"]
	scpText = scpText.replace("{firstName}", UniversalFunctions.firstName)
	scpText = scpText.replace("{lastName}", UniversalFunctions.lastName)
	$File/ScrollContainer/VBoxContainer/SCPText.set_bbcode(scpText)
	$Virtualhell/Paradise.text = UniversalFunctions.dialogueJson["PARADISE"]
	$Commandprompt/shell.text = UniversalFunctions.dialogueJson["SHELL"]
	$FileSystem/FileSystem.text = UniversalFunctions.dialogueJson["FILESYSTEM"]
	$IDE/WISH.text = UniversalFunctions.dialogueJson["WISH"]
	$IDE/Cool/Label.text = UniversalFunctions.dialogueJson["Cool"]
	$IDE/Cozy/Label.text = UniversalFunctions.dialogueJson["Cozy"]
	$IDE/Cute/Label.text = UniversalFunctions.dialogueJson["Cute"]
	$IDE/Room/Label.text = UniversalFunctions.dialogueJson["Room"]
	$IDE/Bed/Label.text = UniversalFunctions.dialogueJson["Bed"]
	$IDE/Chair/Label.text = UniversalFunctions.dialogueJson["Chair"]
	$IDE/Decor/Label.text = UniversalFunctions.dialogueJson["Decor"]
	$IDE/select.text = UniversalFunctions.dialogueJson["Decor"]
	yield($NervousTimer, "timeout")
	intro = "Intro"
	$NervousTimer.wait_time = 3
	UniversalFunctions.play_dialogue_JSON("dialogueIntro")
	yield($Commandprompt,"done")
	

func _on_Commandprompt_option_pressed(optionName:String):
	if UniversalFunctions.locked == true:
		return
	if optionName == "forgotten":
		if $Commandprompt.pastDialogue[-1]["name"] == "start":
			if UniversalFunctions.loneliness <60:
				UniversalFunctions.play_dialogue_JSON("fineGreetingGood")
			elif UniversalFunctions.loneliness >= 60 and UniversalFunctions.loneliness <= 90:
				UniversalFunctions.play_dialogue_JSON("sadGreetingGood")
			return
		if split != null:
			if UniversalFunctions.disgust < 20:
				if UniversalFunctions.loneliness < 60:
					UniversalFunctions.play_dialogue_JSON("fine"+split)
				elif UniversalFunctions.loneliness >= 60 and UniversalFunctions.loneliness <= 90:
					UniversalFunctions.play_dialogue_JSON("sad"+split)
			else:
				UniversalFunctions.play_dialogue_JSON("angry"+split)
			split = null
			return
		if UniversalFunctions.disgust < 20:
			if UniversalFunctions.loneliness < 60:
				UniversalFunctions.play_dialogue_JSON("fineRepeat")
			elif UniversalFunctions.loneliness >= 60 and UniversalFunctions.loneliness <= 90:
				UniversalFunctions.play_dialogue_JSON("sadRepeat")
		else:
			UniversalFunctions.play_dialogue_JSON("angryRepeat")
		yield($Commandprompt,"done")
		if UniversalFunctions.dialogueJson.has($Commandprompt.pastDialogue[-1]["name"]):
			UniversalFunctions.play_dialogue_JSON($Commandprompt.pastDialogue[-1]["name"])
		else: 
			UniversalFunctions.play_dialogue_JSON($Commandprompt.pastDialogue[-1]["mood"]+$Commandprompt.pastDialogue[-1]["name"])
	elif optionName == "GreetingGoodConverge" or optionName == "GreetingBadConverge" or  optionName == "GreetingUglyConverge":
		intro = ""
		$NervousTimer.wait_time = 3
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "AskSupervisorGood" or optionName == "AskSupervisorBad":
		$Commandprompt.playerName = "Mystery Person"
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "GiveNameGood":
		$Commandprompt.playerName = UniversalFunctions.firstName
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "GiveNameBad":
		UniversalFunctions.play_dialogue_JSON(optionName)
		UniversalFunctions.loneliness +=2
	elif optionName == "reactionToGenerationUgly":
		split = null
		UniversalFunctions.topics.append("Simulation")
	elif optionName == "SpendTime" or optionName == "WhatWereYouLike" or optionName == "ElfTalk":
		UniversalFunctions.TalkAbout.append(optionName)
		UniversalFunctions.play_dialogue_JSON(optionName)
	else:
		UniversalFunctions.play_dialogue_JSON(optionName)
		
	var optionChecker = optionName.replace("Converge","")
	UniversalFunctions.loneliness -=1
	if optionChecker.ends_with("Good"):
		UniversalFunctions.disgust -=1
	elif optionChecker.ends_with("Bad"):
		UniversalFunctions.disgust +=1
	


func _on_CurrentTime_timeout():
	if frozen == true:
		return
	minute+=1
	if minute == 60:
		minute = 0
		hour+=1
	var time
	if hour<10:
		time = "0"+str(hour)+":"
	else:
		time = str(hour)+":"
	if minute <10:
		time = time+"0"+str(minute)
	else:
		time=time+str(minute)
	$Taskbar/time.text = time

func _on_NervousTimer_timeout():
	if UniversalFunctions.dialoguePlaying == true:
		return
	
	if intro != "null":
		for i in distractions:
			rng.randomize()
			var roll = rng.randf_range(0, 250.0)
			if roll <= i["value"]:
				print("distraction rolled!")
				$NervousTimer.start()
				return
		if UniversalFunctions.loneliness <= 90:
			UniversalFunctions.loneliness += 1
			if UniversalFunctions.loneliness % 2 == 0:
				if UniversalFunctions.disgust < 20:
					UniversalFunctions.play_dialogue_JSON("lonely"+intro+str(UniversalFunctions.loneliness/2))
			else:
				$NervousTimer.start()
		else:
			$NervousTimer.start()
	
func resetLayers(moveToFront, current):
	if UniversalFunctions.locked == true:
		return
	if moveToFront == false:
		order.erase(current)
		order.insert(0,current)
	else:
		order.erase(current)
		order.append(current)
	var counter = 0
	for i in order:
		if get_tree().get_root().get_node_or_null("/root/world/"+i) != null:
			get_tree().get_root().get_node_or_null("/root/world/"+i).z_index = counter
		counter += 1
	if $Virtualhell.z_index == 3:
		$Commandprompt/Options.visible = $Commandprompt.optionsVisible
		$Virtualhell/Close.disabled = false
		$Virtualhell/Minimize.disabled = false
	else:
		$Commandprompt/Options.visible = false
		$Virtualhell/Close.disabled = true
		$Virtualhell/Minimize.disabled = true
	if $IDE.z_index == 3:
		$IDE/Close.disabled = false
		$IDE/Minimize.disabled = false
		$IDE/Generate.disabled = false
		$IDE/Cool.disabled = false
		$IDE/Cozy.disabled = false
		$IDE/Cute.disabled = false
		$IDE/Room.disabled = false
		$IDE/Bed.disabled = false
		$IDE/Chair.disabled = false
		$IDE/Decor.disabled = false
		$IDE/Red.disabled = false
		$IDE/Orange.disabled = false
		$IDE/Yellow.disabled = false
		$IDE/Green.disabled = false
		$IDE/Blue.disabled = false
		$IDE/Violet.disabled = false
		$IDE/Pink.disabled = false
		$IDE/White.disabled = false
		$IDE/Black.disabled = false
	else:
		$IDE/Close.disabled = true
		$IDE/Minimize.disabled = true
		$IDE/Generate.disabled = true
		$IDE/Cool.disabled = true
		$IDE/Cozy.disabled = true
		$IDE/Cute.disabled = true
		$IDE/Room.disabled = true
		$IDE/Bed.disabled = true
		$IDE/Chair.disabled = true
		$IDE/Decor.disabled = true
		$IDE/Red.disabled = true
		$IDE/Orange.disabled = true
		$IDE/Yellow.disabled = true
		$IDE/Green.disabled = true
		$IDE/Blue.disabled = true
		$IDE/Violet.disabled = true
		$IDE/Pink.disabled = true
		$IDE/White.disabled = true
		$IDE/Black.disabled = true
	if $File.z_index == 3:
		$File/Close.disabled = false
		$File/Minimize.disabled = false
	else:
		$File/Close.disabled = true
		$File/Minimize.disabled = true


func _on_Synthia_Minimize_pressed():
	if UniversalFunctions.locked == true:
		return
	if $AnimationPlayer.current_animation != "":
		return
	$AnimationPlayer.play("SynthiaMinimize")
	yield($AnimationPlayer,"animation_finished")
	resetLayers(false, "Virtualhell")

func _on_File_Minimize_pressed():
	if $AnimationPlayer.current_animation != "":
		return
	$AnimationPlayer.play("FileMinimize")
	yield($AnimationPlayer,"animation_finished")
	resetLayers(false, "File")

func _on_IDE_Minimize_pressed():
	if UniversalFunctions.locked == true:
		return
	if $AnimationPlayer.current_animation != "":
		return
	$AnimationPlayer.play("IDEMinimize")
	yield($AnimationPlayer,"animation_finished")
	resetLayers(false, "IDE")



func _on_FileSystem_Minimize_pressed():
	if UniversalFunctions.locked == true:
		return
	if $AnimationPlayer.current_animation != "":
		return
	$AnimationPlayer.play("FileSystemMinimize")
	yield($AnimationPlayer,"animation_finished")
	resetLayers(false, "FileSystem")



func _on_Synthia_Close_pressed():
	if UniversalFunctions.locked == true:
		return
	UniversalFunctions.locked = true
	$popup.visible = true
	$popup/RichTextLabel.text = UniversalFunctions.dialogueJson["cantClose"]
	$popup/ColorRect.visible = true
	$popup/cancel.visible = false
	$Commandprompt/Options.visible = false
	warning = "synthia"

	
func _on_File_Close_pressed():
	if UniversalFunctions.locked == true:
		return
	if $AnimationPlayer.current_animation != "":
		return
	$File.visible = false
	resetLayers(false, "File")
		

func _on_FileSystem_Close_pressed():
	if UniversalFunctions.locked == true:
		return
	if $AnimationPlayer.current_animation != "":
		return
	$FileSystem.visible = false
	resetLayers(false, "FileSystem")

func _on_IDE_Close_pressed():
	if UniversalFunctions.locked == true:
		return
	if $AnimationPlayer.current_animation != "":
		return
	$IDE.visible = false
	resetLayers(false, "IDE")


func _on_Synthia_pressed():
	if UniversalFunctions.locked == true:
		return
	if $AnimationPlayer.current_animation != "":
		return
	if $Virtualhell.visible == false:
		$AnimationPlayer.play_backwards("SynthiaMinimize")
	resetLayers(true, "Virtualhell")


func _on_File_pressed():
	if UniversalFunctions.locked == true:
		return
	if $AnimationPlayer.current_animation != "":
		return
	if $File.visible == false:
		$AnimationPlayer.play_backwards("FileMinimize")
	resetLayers(true, "File")

func _on_FileSystem_pressed():
	if UniversalFunctions.locked == true:
		return
	if $AnimationPlayer.current_animation != "":
		return
	if $FileSystem.visible == false:
		$AnimationPlayer.play_backwards("FileSystemMinimize")
	resetLayers(true, "FileSystem")
	
func _on_IDE_pressed():
	if UniversalFunctions.locked == true:
		return
	if $AnimationPlayer.current_animation != "":
		return
	if $IDE.visible == false:
		$AnimationPlayer.play_backwards("IDEMinimize")
	resetLayers(true, "IDE")


func _on_Warning_Close_pressed():
	if $AnimationPlayer.current_animation != "":
		return
	if warningNode != null:
		get_tree().get_root().get_node_or_null("/root/world/Icons/"+warningNode).visible = true
	$popup.visible = false
	UniversalFunctions.locked = false
	if $Virtualhell.z_index == 3:
		$Commandprompt/Options.visible = $Commandprompt.optionsVisible
	

func _on_FileViewer_Close_pressed():
	if $AnimationPlayer.current_animation != "":
		return
	$FileViewer.visible = false
	UniversalFunctions.locked = false
	
	
func _on_Warning_accept_pressed():
	if $AnimationPlayer.current_animation != "":
		return
	$popup.visible = false
	UniversalFunctions.locked = false
	if $Virtualhell.z_index == 3:
		$Commandprompt/Options.visible = $Commandprompt.optionsVisible
	Warning_React()


func Warning_React():
	$Commandprompt/AutoCloseTimer.stop()
	UniversalFunctions.dialoguePlaying = false
	if warning == "synthia":
		UniversalFunctions.play_dialogue_JSON("invalidCode")
	elif warning == "trash":
		if warningNode == "IDE" or warningNode == "Virtualhell" or warningNode == "File":
			get_tree().get_root().get_node_or_null("/root/world/Taskbar/Icons/"+warningNode).visible = false
		if warningNode != "Virtualhell":
			UniversalFunctions.play_dialogue_JSON("fileDeleted"+str(filesDeleted))
			filesDeleted += 1
	elif warning == "generate":
		generate_Object()
	warning = null
	warningNode = null


func generate_Object():
	UniversalFunctions.locked = true
	$cursor.play("loading")
	$AnimationPlayer.play("load")
	UniversalFunctions.dialoguePlaying = true
	yield($AnimationPlayer,"animation_finished")
	$IDE/loading.visible = true
	$NervousTimer.stop()
	$Commandprompt/AutoCloseTimer.stop()
	$IDE/loading/loading.play("default")
	yield($IDE/loading/loading,"animation_finished")
	$IDE.reset()
	UniversalFunctions.dialoguePlaying = false
	$cursor.play("default")
	if tempData["object"] == "Room":
		var synthiapaletteLoad = load("res://Resources/Sprites/"+tempData["color"]+"SynthiaColors.png")
		var roompaletteLoad = load("res://Resources/Room/"+tempData["color"]+"RoomColors.png")
		$Virtualhell/Room.play(tempData["style"]+tempData["object"])
		$Virtualhell/Room.get_material().set_shader_param("palette_out", roompaletteLoad)
		$Virtualhell/Synthia.get_material().set_shader_param("palette_out", synthiapaletteLoad)
	if distractions == []:
		split = "FirstGeneration"
		distractions.append(tempData)
		tempData = null
		UniversalFunctions.locked = false
		UniversalFunctions.play_dialogue_JSON("successfullyGeneratedIntro")
		yield($Commandprompt,"done")
		return
	var removed
	var counter = 0 
	var removedSame = false
	for i in distractions:
		if tempData["object"] == i["object"]:
			removed = i
			print(i)
			print(distractions[counter])
			distractions.remove(counter)
		counter+=1
	if removed != null:
		if removed["object"] == tempData["object"] and removed["style"] == tempData["style"] and removed["color"] ==tempData["color"]:
			removedSame = true
		else:
			if removed["value"] < tempData["value"]:
				UniversalFunctions.play_dialogue_JSON("successfullyGeneratedBetter")
				yield($Commandprompt,"done")
			elif removed["value"] > tempData["value"]:
				UniversalFunctions.play_dialogue_JSON("successfullyGeneratedWorse")
				yield($Commandprompt,"done")
			elif removed["value"] == tempData["value"]:
				UniversalFunctions.play_dialogue_JSON("successfullyGeneratedNeutral")
				yield($Commandprompt,"done")
				
	if removedSame == false:
		if UniversalFunctions.dialogueJson.has(tempData["color"]+tempData["style"]+tempData["object"]):
			UniversalFunctions.play_dialogue_JSON(tempData["color"]+tempData["style"]+tempData["object"])
		else:
			if tempData["value"] > 18:
				UniversalFunctions.play_dialogue_JSON("newObjectGood")
				yield($Commandprompt,"done")
			elif tempData["value"] > 10 and tempData["value"] <= 18:
				UniversalFunctions.play_dialogue_JSON("newObjectNeutral")
				yield($Commandprompt,"done")
			elif tempData["value"] <= 10:
				UniversalFunctions.play_dialogue_JSON("newObjectBad")
				yield($Commandprompt,"done")
	distractions.append(tempData)
	tempData = null
	UniversalFunctions.locked = false
	

func _on_Icons_trashed(node):
	if get_tree().get_root().get_node_or_null("/root/world/"+node) != null:
		if node != "FileSystem":
			if get_tree().get_root().get_node_or_null("/root/world/"+node).visible == false and get_tree().get_root().get_node_or_null("/root/world/"+node).scale.x ==1:
					get_tree().get_root().get_node_or_null("/root/world/Icons/"+node).visible = false
					UniversalFunctions.locked = true
					$popup.visible = true
					$Commandprompt/Options.visible = false
					$popup/RichTextLabel.text = UniversalFunctions.dialogueJson["recycle"]
					$popup/ColorRect.visible = false
					$popup/cancel.visible = true
					warningNode = node
					warning = "trash"
			else:
					UniversalFunctions.locked = true
					$popup.visible = true
					$Commandprompt/Options.visible = false
					$popup/RichTextLabel.text = UniversalFunctions.dialogueJson["cantRecycle"]
					$popup/ColorRect.visible = true
					$popup/cancel.visible = false
					warning = "cannotTrash"
	else:
		get_tree().get_root().get_node_or_null("/root/world/Icons/"+node).visible = false
		UniversalFunctions.locked = true
		$popup.visible = true
		$Commandprompt/Options.visible = false
		$popup/RichTextLabel.text = UniversalFunctions.dialogueJson["recycle"]
		$popup/ColorRect.visible = false
		$popup/cancel.visible = true
		warningNode = node
		warning = "trash"


func _on_IDE_generated(data):
	print(data)
	tempData = data
	UniversalFunctions.locked = true
	$popup.visible = true
	$Commandprompt/Options.visible = false
	var text = UniversalFunctions.dialogueJson["generate"]
	text = text.replace("{color}",UniversalFunctions.dialogueJson[data["color"]])
	text = text.replace("{style}",UniversalFunctions.dialogueJson[data["style"]])
	text = text.replace("{object}",UniversalFunctions.dialogueJson[data["object"]])
	$popup/RichTextLabel.text = text
	$popup/ColorRect.visible = false
	$popup/cancel.visible = true
	warning = "generate"
	


func _on_Icons_openFile(nodeName):
	UniversalFunctions.locked = true
	$FileViewer.visible = true
	if nodeName.ends_with("txt") or nodeName.ends_with("rtf"):
		$FileViewer/ImageFile.visible = false
		if nodeName.ends_with("rtf"):
			$FileViewer/TextScroll.visible = true
		else:
			$FileViewer/TextScroll.visible = false
		$FileViewer/Text.visible = true
		$FileViewer/Text.text = ""
		$FileViewer/Text.text = UniversalFunctions.dialogueJson[nodeName+"Text"]
	else:
		$FileViewer/Text.visible = false
		$FileViewer/ImageFile.visible = true
		$FileViewer/ImageFile.play(nodeName)
		$FileViewer/TextScroll.visible = false
	$FileViewer/Label.text = UniversalFunctions.dialogueJson[nodeName]
