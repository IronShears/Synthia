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
var counter = 4
var prepper = null
var randomHints = ["randomAltHint1","randomAltHint2"]
var sadTrigger = false
var movingNode
var mousePos
var oscillatorToggle = false
var hoveredElements = []
var selectedElement
var intersectingNodes = []
onready var windowToggled = $FileViewer
onready var startPositions = {"File":$File.position,
							"FileSystem":$FileSystem.position,
							"IDE":$IDE.position,
							"Virtualhell":$Virtualhell.position}






func _ready():
	UniversalFunctions.reset()
	UniversalFunctions.play_dialogue_JSON("logInSuccessful")
	$File/ScrollContainer/VBoxContainer/Cynthia/description.text = UniversalFunctions.dialogueJson["SCPTextImage"]
	var scpText = UniversalFunctions.dialogueJson["SCPText"]
	scpText = scpText.replace("{firstName}", UniversalFunctions.firstName)
	scpText = scpText.replace("{lastName}", UniversalFunctions.lastName)
	$File/ScrollContainer/VBoxContainer/SCPText.set_bbcode(scpText)
	$Virtualhell/Paradise.text = UniversalFunctions.dialogueJson["PARADISE"]
	$Commandprompt/shell.text = UniversalFunctions.dialogueJson["SHELL"]
	$FileSystem/FileSystem.text = UniversalFunctions.dialogueJson["FILESYSTEM"]
	$IDE/WISH.text = UniversalFunctions.dialogueJson["WISH"]
	$IDE/CoolLabel.text = UniversalFunctions.dialogueJson["Cool"]
	$IDE/CozyLabel.text = UniversalFunctions.dialogueJson["Cozy"]
	$IDE/CuteLabel.text = UniversalFunctions.dialogueJson["Cute"]
	$IDE/RoomLabel.text = UniversalFunctions.dialogueJson["Room"]
	$IDE/BedLabel.text = UniversalFunctions.dialogueJson["Bed"]
	$IDE/ChairLabel.text = UniversalFunctions.dialogueJson["Chair"]
	$IDE/DecorLabel.text = UniversalFunctions.dialogueJson["Decor"]
	$IDE/select.text = UniversalFunctions.dialogueJson["select"]
	$Taskbar/OptionsMenu/MouseOn/Label.text = UniversalFunctions.dialogueJson["MouseOn"]
	$Taskbar/OptionsMenu/Fullscreen/Label.text = UniversalFunctions.dialogueJson["Fullscreen"]
	$Taskbar/OptionsMenu/Mobile/Label.text = UniversalFunctions.dialogueJson["ForMobile"]
	

func _unhandled_input(event):
	if UniversalFunctions.locked == true:
		if event is InputEventMouseButton and event.is_pressed():
			get_tree().get_root().get_node_or_null("/root/world/SoundEffects").play()


func _input(event):
	if intro == "null":
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index != BUTTON_LEFT:
				return
			if counter > 0:
				counter -=1
				return
			$NervousTimer.start()
			yield($NervousTimer, "timeout")
			intro = "Intro"
			$NervousTimer.wait_time = 6
			UniversalFunctions.play_dialogue_JSON("dialogueIntro")
			yield($Commandprompt,"done")
	
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == BUTTON_LEFT:
			if hoveredElements == []:
				# No object is being clicked, so deselect selected node
				selectedElement = null
			else:
				# Call left click for only the top object that is being clicked
				leftMouseClick()
	
func leftMouseClick():
	if UniversalFunctions.locked == true:
		return
	if hoveredElements.has(order[3]):
		selectedElement = order[3]
	elif hoveredElements.has(order[2]):
		selectedElement = order[2]
	elif hoveredElements.has(order[1]):
		selectedElement = order[1]
	elif hoveredElements.has(order[0]):
		selectedElement = order[0]
	hoveredElements = []
	resetLayers(true, selectedElement)


	
func _on_Commandprompt_option_pressed(optionName:String):
	if optionName == "forgotten":
		if split != null:
			UniversalFunctions.play_dialogue_JSON(split)
			return
		if $Commandprompt.pastDialogue[-1]["name"] == "start":
			UniversalFunctions.play_dialogue_JSON("GreetingRude")
			$NervousTimer.wait_time = 12
			intro = ""
			return
		if UniversalFunctions.disgust < 20:
			if UniversalFunctions.loneliness < 60:
				UniversalFunctions.play_dialogue_JSON("fineRepeat")
			elif UniversalFunctions.loneliness >= 60 and UniversalFunctions.loneliness <= 90:
				UniversalFunctions.play_dialogue_JSON("sadRepeat")
		else:
			UniversalFunctions.play_dialogue_JSON("angryRepeat")
		yield($Commandprompt,"done")
		UniversalFunctions.play_dialogue_JSON($Commandprompt.pastDialogue[-1]["name"])
		return
	elif optionName == "GreetingGood" or optionName == "GreetingBad" or  optionName == "GreetingUgly":
		intro = ""
		$NervousTimer.wait_time = 12
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "IntroductionsGood" or optionName == "IntroductionsBad":
		$Commandprompt.playerName = UniversalFunctions.dialogueJson["Whoever You Are"]
		UniversalFunctions.adaOrYou = "ada"
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "AskSupervisorGood" or optionName == "AskSupervisorBad":
		$Commandprompt.playerName = UniversalFunctions.dialogueJson["Mystery Person"]
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "GiveNameGood":
		$Commandprompt.playerName = UniversalFunctions.firstName
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "GiveNameBad":
		UniversalFunctions.play_dialogue_JSON(optionName)
		UniversalFunctions.loneliness +=2
	elif optionName == "SpendTime" or optionName == "WhatWereYouLike" or optionName == "ElfTalk":
		UniversalFunctions.TalkAbout[optionName] = true
		if optionName == "ElfTalk":
			UniversalFunctions.TalkAbout["ShakenFaithUgly"] = false
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "Cook" or optionName == "Computers" or optionName == "Relax":
		optionName = UniversalFunctions.interest
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "CultBad":
		UniversalFunctions.TalkAbout["CultDirect"] = false
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "CultLeaderJeanPaulUgly":
		UniversalFunctions.TalkAbout["CultNonDirect"] = false
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "DungeonsAndDragonsGood":
		UniversalFunctions.TalkAbout["DungeonsAndDragonsCont"] = false
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "AdaSurpriseUgly":
		UniversalFunctions.variableOptions = "ContinueForwardHuh"
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "ContinueForwardHuhUgly":
		UniversalFunctions.variableOptions = "ShiftEndPrompt"
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "ICanExplainUgly":
		if UniversalFunctions.disgust >= 20:
			UniversalFunctions.dialogueEnded = true
			UniversalFunctions.foundationSnippet = "yesFoundation"
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "NotTrueUgly":
		UniversalFunctions.foundationSnippet = "yesFoundation"
		UniversalFunctions.dialogueEnded = true
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "TrustHerUgly":
		UniversalFunctions.foundationSnippet = "yesFoundation"
		UniversalFunctions.dialogueEnded = true
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "CultProdBad":
		UniversalFunctions.dialogueEnded = true
		UniversalFunctions.play_dialogue_JSON(optionName)
	elif optionName == "InterestsTalk":
		print(UniversalFunctions.interest+optionName)
		UniversalFunctions.play_dialogue_JSON(UniversalFunctions.interest+optionName)
		$CurrentTime.wait_time= 0.1
	elif optionName == "AdaToldYes":
		UniversalFunctions.foundationSnippet = "noFoundationJeanPaul"
		UniversalFunctions.dialogueEnded = true
		UniversalFunctions.play_dialogue_JSON(optionName)
	else:
		UniversalFunctions.play_dialogue_JSON(optionName)
		
	var optionChecker = optionName.replace("","")
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
	if $Taskbar/time.text == "17:00":
		if frozen == false:
			UniversalFunctions.dialogueEnded = true
			time_ending()
			frozen = true
		
		
func time_ending():
	if distractions.size() == 4:
		UniversalFunctions.ending = "firedBest"
		UniversalFunctions.play_dialogue_JSON("GoodEnd")
		yield($Commandprompt,"option_pressed")
		UniversalFunctions.play_dialogue_JSON("GoodEnding2")
		yield($Commandprompt,"option_pressed")
	else:
		if distractions.size() == 0:
			if $FileSystem.allItems["system"] == []:
				UniversalFunctions.ending = "followedOrders"
			else:
				UniversalFunctions.ending = "disobeyedOrders"
		else:
			UniversalFunctions.ending = "fired"
		UniversalFunctions.play_dialogue_JSON("NeutralEnd")
		yield($Commandprompt,"option_pressed")
	$ClosingComputer.visible = true
	$ClosingComputer.play("default")
	yield($ClosingComputer,"animation_finished")
	UniversalFunctions.change_scenes_reload("res://endingAndCredits.tscn")

func _on_NervousTimer_timeout():
	if $Taskbar/time.text == "17:00":
		return
	if UniversalFunctions.dialogueEnded == true:
		return
	
	if intro == "Intro":
		var wait_time = 0.003*pow(UniversalFunctions.loneliness,2)+((-0.27)*UniversalFunctions.loneliness)+20
		$NervousTimer.wait_time = wait_time
		if UniversalFunctions.loneliness < 90:
			UniversalFunctions.loneliness += 2
			UniversalFunctions.play_dialogue_JSON("lonelyIntro"+str(UniversalFunctions.loneliness/2))
		else:
			$NervousTimer.start()
	elif intro == "":
		var wait_time = 0.004*pow(UniversalFunctions.loneliness,2)+((-0.36)*UniversalFunctions.loneliness)+20.1
		$NervousTimer.wait_time = wait_time
		for i in distractions:
			rng.randomize()
			var roll = rng.randf_range(0, 250.0)
			if roll <= i["value"]:
				$Commandprompt.objectName = i["object"]
				UniversalFunctions.play_dialogue_JSON("distraction"+i["style"]+i["object"])
				return
		if UniversalFunctions.loneliness <= 88:
			UniversalFunctions.loneliness += 2
			if UniversalFunctions.disgust < 20:
				rng.randomize()
				var roll2 = rng.randi_range(1, 15)
				if roll2 == 15:
					if randomHints != []:
						var randomHint = rng.randi_range(0, randomHints.size()-1)
						UniversalFunctions.play_dialogue_JSON(randomHints[randomHint])
						return
				if UniversalFunctions.loneliness > 60:
					UniversalFunctions.play_dialogue_JSON("lonelySad"+str(roll2))
				elif UniversalFunctions.loneliness <= 60 and UniversalFunctions.loneliness > 30:
					UniversalFunctions.play_dialogue_JSON("lonelyTense"+str(roll2))
				else:
					UniversalFunctions.play_dialogue_JSON("lonelyFine"+str(roll2))
		if UniversalFunctions.loneliness == 90:
			if UniversalFunctions.disgust < 20:
				if sadTrigger == false:
					UniversalFunctions.play_dialogue_JSON("lonelySadEnd")
					UniversalFunctions.dialogueEnded = true
					sadTrigger = true
	
func resetLayers(moveToFront, current):
	if UniversalFunctions.locked == true:
		return
	if moveToFront == false:
		order.erase(current)
		order.insert(0,current)
	else:
		order.erase(current)
		order.append(current)
	var layerCounter = 0
	for i in order:
		if get_tree().get_root().get_node_or_null("/root/world/"+i) != null:
			get_tree().get_root().get_node_or_null("/root/world/"+i).z_index = layerCounter
		layerCounter += 1
	if $Virtualhell.z_index == 3:
		$Commandprompt/Options.visible = $Commandprompt.optionsVisible
		$Virtualhell/Close.visible = true
		$Virtualhell/Minimize.visible = true
		$Virtualhell/mover.visible = true
	else:
		$Commandprompt/Options.visible = false
		$Virtualhell/Close.visible = false
		$Virtualhell/Minimize.visible = false
		$Virtualhell/mover.visible = false
	if $IDE.z_index == 3:
		$IDE/mover.visible = true
		$IDE/Close.visible = true
		$IDE/Minimize.visible = true
		$IDE/Generate.visible = true
		$IDE/Cool.visible = true
		$IDE/Cozy.visible = true
		$IDE/Cute.visible = true
		$IDE/Room.visible = true
		$IDE/Bed.visible = true
		$IDE/Chair.visible = true
		$IDE/Decor.visible = true
		$IDE/Red.visible = true
		$IDE/Orange.visible = true
		$IDE/Yellow.visible = true
		$IDE/Green.visible = true
		$IDE/Blue.visible = true
		$IDE/Violet.visible = true
		$IDE/Pink.visible = true
		$IDE/White.visible = true
		$IDE/Black.visible = true
	else:
		$IDE/mover.visible = false
		$IDE/Close.visible = false
		$IDE/Minimize.visible = false
		$IDE/Generate.visible = false
		$IDE/Cool.visible = false
		$IDE/Cozy.visible = false
		$IDE/Cute.visible = false
		$IDE/Room.visible = false
		$IDE/Bed.visible = false
		$IDE/Chair.visible = false
		$IDE/Decor.visible = false
		$IDE/Red.visible = false
		$IDE/Orange.visible = false
		$IDE/Yellow.visible = false
		$IDE/Green.visible = false
		$IDE/Blue.visible = false
		$IDE/Violet.visible = false
		$IDE/Pink.visible = false
		$IDE/White.visible = false
		$IDE/Black.visible = false
	if $File.z_index == 3:
		$File/mover.visible = true
		$File/Close.visible = true
		$File/Minimize.visible = true
	else:
		$File/mover.visible = false
		$File/Close.visible = false
		$File/Minimize.visible = false
	if $FileSystem.z_index == 3:
		$FileSystem/mover.visible = true
		$FileSystem/Close.visible = true
		$FileSystem/Minimize.visible = true
	else:
		$FileSystem/mover.visible = false
		$FileSystem/Close.visible = false
		$FileSystem/Minimize.visible = false


func _on_Synthia_Minimize_pressed():
	if UniversalFunctions.locked == true:
		return
	tweening($Virtualhell,true)
	yield($Tween,"tween_completed")
	$Virtualhell.visible = false
	resetLayers(false, "Virtualhell")

func _on_File_Minimize_pressed():
	if UniversalFunctions.locked == true:
		return
	tweening($File,true)
	yield($Tween,"tween_completed")
	$File.visible = false
	resetLayers(false, "File")


func _on_IDE_Minimize_pressed():
	if UniversalFunctions.locked == true:
		return
	tweening($IDE,true)
	yield($Tween,"tween_completed")
	$IDE.visible = false
	resetLayers(false, "IDE")



func _on_FileSystem_Minimize_pressed():
	if UniversalFunctions.locked == true:
		return
	tweening($FileSystem,true)
	yield($Tween,"tween_completed")
	$FileSystem.visible = false
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
	$File.visible = false
	resetLayers(false, "File")
		

func _on_FileSystem_Close_pressed():
	if UniversalFunctions.locked == true:
		return
	$FileSystem.visible = false
	resetLayers(false, "FileSystem")

func _on_IDE_Close_pressed():
	print(UniversalFunctions.locked)
	if UniversalFunctions.locked == true:
		return
	$IDE.visible = false
	resetLayers(false, "IDE")


func _on_Synthia_pressed():
	if UniversalFunctions.locked == true:
		return
	if $Virtualhell.visible == false:
		$Virtualhell.visible = true
		tweening($Virtualhell,false)
	resetLayers(true, "Virtualhell")


func _on_File_pressed():
	if $Taskbar/time.text == "17:00":
		return
	if UniversalFunctions.locked == true:
		return
	if $File.visible == false:
		$File.visible = true
		tweening($File,false)
	resetLayers(true, "File")

func _on_FileSystem_pressed():
	if $Taskbar/time.text == "17:00":
		return
	if UniversalFunctions.locked == true:
		return
	if $FileSystem.visible == false:
		$FileSystem.visible = true
		tweening($FileSystem,false)
	resetLayers(true, "FileSystem")
	
func _on_IDE_pressed():
	if $Taskbar/time.text == "17:00":
		return
	if UniversalFunctions.locked == true:
		return
	if $IDE.visible == false:
		$IDE.visible = true
		tweening($IDE,false)
	resetLayers(true, "IDE")


func _on_Warning_Close_pressed():
	if warningNode != null:
		get_tree().get_root().get_node_or_null("/root/world/Icons/"+warningNode).visible = true
	$popup.visible = false
	UniversalFunctions.locked = false
	if $Virtualhell.z_index == 3:
		$Commandprompt/Options.visible = $Commandprompt.optionsVisible
	

func _on_FileViewer_Close_pressed():
	if prepper == "THANKYOUrtf":
		if $Taskbar/time.text != "17:00":
			return
	$FileViewer/Text.scroll_to_line(0)
	$FileViewer.visible = false
	$BigFileViewer.visible = false
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
	if warning == "synthia":
		if UniversalFunctions.loneliness == 90:
			$Commandprompt/AutoCloseTimer.stop()
			UniversalFunctions.play_dialogue_JSON("synthiaClosed")
			$Virtualhell.visible = false
			resetLayers(false, "Virtualhell")
		else:
			$Commandprompt/AutoCloseTimer.stop()
			if UniversalFunctions.dialogueEnded == false: 
				UniversalFunctions.play_dialogue_JSON("invalidCode")
			else: 
				UniversalFunctions.play_dialogue_JSON("invalidCodeEnded")
	elif warning == "trash":
		if warningNode == "IDE" or warningNode == "File":
			get_tree().get_root().get_node_or_null("/root/world/Taskbar/Icons/"+warningNode).visible = false
		if warningNode == "Virtualhell":
			UniversalFunctions.locked = true
			get_tree().get_root().get_node_or_null("/root/world/Taskbar/Icons/"+warningNode).visible = false
			$Commandprompt/AutoCloseTimer.stop()
			UniversalFunctions.play_dialogue_JSON("fileDeletedSynthia")
			yield($Commandprompt, "done")
			$NervousTimer.stop()
			$NervousTimer.start()
			UniversalFunctions.ending = "demoted"
			yield($NervousTimer,"timeout")
			$ClosingComputer.visible = true
			$ClosingComputer.play("default")
			yield($ClosingComputer,"animation_finished")
			UniversalFunctions.change_scenes_reload("res://endingAndCredits.tscn")
			return
		if warningNode == "READTHISrtf" or warningNode == "AN_EXPLAINATIONrtf" or warningNode == "LOVErtf":
			if prepper == null:
				if UniversalFunctions.dialogueJson.has("fileDeleted"+str(filesDeleted)):
					$Commandprompt/AutoCloseTimer.stop()
					if UniversalFunctions.dialogueEnded == false:
						UniversalFunctions.play_dialogue_JSON("fileDeleted"+str(filesDeleted))
					else:
						UniversalFunctions.play_dialogue_JSON("fileDeletedSynthia")
				else:
					$Commandprompt/AutoCloseTimer.stop()
					UniversalFunctions.play_dialogue_JSON("fileDeletedLater")
				filesDeleted += 1
				return
			
			if prepper == "READTHISrtf":
				$FileSystem.visibleFolders.append("why")
				$FileSystem.allItems["system"].append("why")
			elif prepper == "AN_EXPLAINATIONrtf":
				$FileSystem.visibleFolders.append("cynthia")
				$FileSystem.allItems["system"].append("cynthia")
			elif prepper == "LOVErtf":
				if UniversalFunctions.adaOrYou != "you":
					$FileSystem.visibleFolders.append("myWish")
					$FileSystem.allItems["system"].append("myWish")
				else:
					if UniversalFunctions.dialogueJson.has("fileDeleted"+str(filesDeleted)):
						$Commandprompt/AutoCloseTimer.stop()
						UniversalFunctions.play_dialogue_JSON("fileDeleted"+str(filesDeleted))
					else:
						$Commandprompt/AutoCloseTimer.stop()
						UniversalFunctions.play_dialogue_JSON("fileDeletedLater")
					return
			$FileSystem.set_up()
			$Commandprompt/AutoCloseTimer.stop()
			
			if UniversalFunctions.dialogueEnded == false:
				UniversalFunctions.play_dialogue_JSON("fileDeleted"+warningNode)
			else:
				UniversalFunctions.play_dialogue_JSON("fileDeleted"+warningNode+"Ended")
			var counter = 0
		else:
			if UniversalFunctions.dialogueJson.has("fileDeleted"+str(filesDeleted)):
				$Commandprompt/AutoCloseTimer.stop()
				if UniversalFunctions.dialogueEnded == false:
					UniversalFunctions.play_dialogue_JSON("fileDeleted"+str(filesDeleted))
				else:
					UniversalFunctions.play_dialogue_JSON("fileDeletedSynthia")
			else:
				$Commandprompt/AutoCloseTimer.stop()
				UniversalFunctions.play_dialogue_JSON("fileDeletedLater")
		for i in $Icons.currentNodes:
			if i.name == warningNode:
				$Icons.currentNodes.erase(counter)
			counter+=1
		print($Icons.currentNodes)
	elif warning == "generate":
		generate_Object()
	warning = null
	warningNode = null


func generate_Object():
	if $Taskbar/time.text == "17:00":
		return
	$NervousTimer.stop()
	UniversalFunctions.generating = true
	UniversalFunctions.emptyFilled = "lessEmpty"
	#Locking things down, loading it in
	UniversalFunctions.locked = true
	$cursor.play("loading")
	$AnimationPlayer.play("load")
	yield($AnimationPlayer,"animation_finished")
	#Finishing generation
	$IDE/loading.visible = true
	$Commandprompt/AutoCloseTimer.stop()
	$IDE/loading/loading.play("default")
	$IDE/loading/loading.frame = 0
	yield($IDE/loading/loading,"animation_finished")
	#everything goes back to normal
	$IDE.reset()
	$cursor.play("default")
	$Commandprompt.objectName = tempData["object"]
	$Commandprompt.colorName = tempData["color"]
	$Commandprompt.styleName = tempData["style"]
	#adds thing to room
	if tempData["object"] == "Room":
		var synthiapaletteLoad = load("res://Resources/Sprites/"+tempData["color"]+"SynthiaColors.png")
		var roompaletteLoad = load("res://Resources/Room/"+tempData["color"]+"RoomColors.png")
		$Virtualhell/Room.play(tempData["style"]+tempData["object"])
		$Virtualhell/Room.get_material().set_shader_param("palette_out", roompaletteLoad)
		$Virtualhell/Synthia.get_material().set_shader_param("palette_out", synthiapaletteLoad)
	else:
		var roompaletteLoad = load("res://Resources/Room/"+tempData["color"]+"RoomColors.png")
		get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Room/"+tempData["object"]).play(tempData["style"])
		get_tree().get_root().get_node_or_null("/root/world/Virtualhell/Room/"+tempData["object"]).get_material().set_shader_param("palette_out", roompaletteLoad)
	UniversalFunctions.locked = false
	
	#dialogue if it's the first generated object
	if distractions == []:
		distractions.append(tempData)
		UniversalFunctions.locked = false
		UniversalFunctions.generating = false
		if UniversalFunctions.dialogueEnded == false:
			UniversalFunctions.play_dialogue_JSON("successfullyGeneratedIntro")
		else:
			UniversalFunctions.play_dialogue_JSON("successfullyGeneratedIntroEnded")
		return
		
	#removes old objects. If you already have a chair and generate a new chair, it replaces the chair with the new chair.
	var removed
	var genCounter = 0 
	var genLocked
	var removedSame = false
	for i in distractions:
		if tempData["object"] == i["object"]:
			removed = i
			genLocked = true
		if genLocked == false:
			genCounter+=1
	if genLocked == true:
		distractions.erase(distractions[genCounter])
	distractions.append(tempData)
	print(distractions)
	
	if UniversalFunctions.dialogueEnded == true:
		UniversalFunctions.generating = false
		if distractions.size() == 4:
			if $FileSystem.allItems["system"].has("atPeace"):
				$FileSystem.visibleFolders.append("atPeace")
				$FileSystem.allItems["system"].append("atPeace")
				$FileSystem.set_up()
				UniversalFunctions.play_dialogue_JSON("successfullyGeneratedLastEnded")
				yield($Commandprompt,"done")
			else:
				UniversalFunctions.play_dialogue_JSON("successfullyGeneratedEnded")
				yield($Commandprompt,"done")
		else:
			UniversalFunctions.play_dialogue_JSON("successfullyGeneratedEnded")
			yield($Commandprompt,"done")
		return
	
	
	#Starts playing dialogue
	if removed != null:
		if removed["object"] == tempData["object"] and removed["style"] == tempData["style"] and removed["color"] == tempData["color"]:
			removedSame = true
		else:
			
			if distractions.size() == 4:
	#if you've given Synthia one of everything, Ada gives you one last goodbye
				$FileSystem.visibleFolders.append("atPeace")
				$FileSystem.allItems["system"].append("atPeace")
				$FileSystem.set_up()
				UniversalFunctions.play_dialogue_JSON("successfullyGeneratedLast")
				yield($Commandprompt,"done")
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
		if UniversalFunctions.dialogueJson.has("full"+tempData["color"]+tempData["style"]+tempData["object"]):
			UniversalFunctions.play_dialogue_JSON("full"+tempData["color"]+tempData["style"]+tempData["object"])
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


		
	UniversalFunctions.generating = false
	

func _on_Icons_trashed(node):
	if $Taskbar/time.text == "17:00":
		return
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
	if $Taskbar/time.text == "17:00":
		return
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
	if $Taskbar/time.text == "17:00":
		return
	if nodeName == "BLOW_A_WISHzip":
		UniversalFunctions.TalkAbout["RequiresBlowAWish"] = false
		UniversalFunctions.TalkAbout["AdaSurpriseUgly"] = true
		UniversalFunctions.whatsYourNameContinue = "Wish"
		UniversalFunctions.TalkAbout["AdaNonSurpriseUgly"] = false
		$FileSystem.visibleFolders.append("imSorry")
		$FileSystem.allItems["system"].append("imSorry")
		$FileSystem.set_up()
		$AnimationPlayer.play_backwards("IDEMinimize")
		resetLayers(true, "IDE")
		$Taskbar/Icons/IDE.visible = true
		$Icons/IDE.visible = true
		$IDE.visible = true
		$Icons.position_settling($Icons/IDE)
		tempData = {
		"color": "Blue",
		"style": "Cool",
		"object": "Room",
		"value": 10 }
		generate_Object()
		return
	UniversalFunctions.locked = true
	if nodeName.ends_with("rtf"):
		windowToggled.visible = true
	else:
		$FileViewer.visible = true
	if nodeName.ends_with("txt") or nodeName.ends_with("rtf"):
		$FileViewer/ImageFile.visible = false
		if nodeName.ends_with("rtf"):
			$FileViewer/windowadjustor.visible = true
			$FileViewer/TextScroll.visible = true
		else:
			$FileViewer/windowadjustor.visible = false
			$FileViewer/TextScroll.visible = false
		$FileViewer/Text.visible = true
		$FileViewer/Text.set_bbcode(UniversalFunctions.dialogueJson[nodeName+"Text"])
		$BigFileViewer/ScrollContainer/Text.set_bbcode(UniversalFunctions.dialogueJson[nodeName+"Text"])
		if nodeName == "apologyrtf":
			$BigFileViewer/ColorRect.visible = true
		else:
			$BigFileViewer/ColorRect.visible = false
		if nodeName == "READTHISrtf" or nodeName == "AN_EXPLAINATIONrtf" or nodeName == "LOVErtf" or nodeName == "THANKYOUrtf":
			prepper = nodeName
			if nodeName == "THANKYOUrtf":
				$CurrentTime.wait_time = 0.05
			if nodeName == "LOVErtf":
				if oscillatorToggle == false:
					UniversalFunctions.TalkAbout["OscilatorNon"] = false
					UniversalFunctions.TalkAbout["Oscilator"] = false
					oscillatorToggle = true
	else:
		$FileViewer/windowadjustor.visible = false
		$FileViewer/Text.visible = false
		$FileViewer/ImageFile.visible = true
		$FileViewer/ImageFile.play(nodeName)
		$FileViewer/TextScroll.visible = false
	$FileViewer/Label.text = UniversalFunctions.dialogueJson[nodeName]



func _on_windowadjustor_pressed():
	if windowToggled != $BigFileViewer:
		$FileViewer.visible = false
		$BigFileViewer.visible = true
		windowToggled = $BigFileViewer
	else:
		$FileViewer.visible = true
		$BigFileViewer.visible = false
		windowToggled = $FileViewer




func _process(_delta):
	if movingNode != null:
		get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.y = get_global_mouse_position().y-mousePos.y
		get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.x = get_global_mouse_position().x-mousePos.x


func tweening(node, minimize):
	if minimize == true:
		$Tween.interpolate_property(node, "position",
			node.position, Vector2(1, 240), 0.8,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.interpolate_property(node, "scale",
			Vector2(1,1), Vector2(0.5, 0.1), 0.8,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		$Tween.interpolate_property(node, "position",
			Vector2(1, 240), startPositions[node.name], 0.8,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.interpolate_property(node, "scale",
			Vector2(0.5, 0.1),Vector2(1,1), 0.8,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

func _on_mover_button_down(nodeName):
	mousePos = get_global_mouse_position()
	movingNode = nodeName
	mousePos.x = mousePos.x-get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.x
	mousePos.y = mousePos.y-get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.y
	print(mousePos)
	print(get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position)




func _on_mover_button_up():
	if get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.y > 145:
		get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.y = 145
	if get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.y < 1:
		get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.y = 1
	if get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.x < -77:
		get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.x = -77
	if get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.x > 250:
		get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position.x = 250
	startPositions[movingNode] = get_tree().get_root().get_node_or_null("/root/world/"+movingNode).position
	movingNode = null



func _on_Selection_mouse_entered(nodeName):
	if hoveredElements.has(nodeName) == false:
		hoveredElements.append(nodeName)


func _on_Selection_mouse_exited(nodeName):
	if hoveredElements.has(nodeName) == true:
		hoveredElements.erase(nodeName)


func _on_Start_pressed():
	if $Taskbar/OptionsMenu.visible == true:
		$Taskbar/OptionsMenu.visible = false
	else:
		$Taskbar/OptionsMenu.visible = true


func _on_OptionButton_pressed(optionpressed):
	$Taskbar/OptionsMenu.visible = false
	if optionpressed == "Mouse":
		if $cursor.cursorDisabled == false:
			$Taskbar/OptionsMenu/MouseOn/Label.text = UniversalFunctions.dialogueJson["MouseOff"]
			$cursor.cursorDisabled = true
			$cursor.visible = false
		else:
			$Taskbar/OptionsMenu/MouseOn/Label.text = UniversalFunctions.dialogueJson["MouseOn"]
			$cursor.cursorDisabled = false
			$cursor.visible = true
			
	elif optionpressed == "Fullscreen":
		if OS.window_fullscreen == false:
			$Taskbar/OptionsMenu/Fullscreen/Label.text = UniversalFunctions.dialogueJson["Fullscreen"]
			OS.window_fullscreen = true
		else:
			$Taskbar/OptionsMenu/Fullscreen/Label.text = UniversalFunctions.dialogueJson["Windowed"]
			OS.window_fullscreen = false
	elif optionpressed == "Mobile":
		if $Taskbar/OptionsMenu/Mobile/Label.text == UniversalFunctions.dialogueJson["ForMobile"]:
			OS.window_fullscreen = true
			$Taskbar/OptionsMenu/Fullscreen/Label.text = UniversalFunctions.dialogueJson["Windowed"]
			$Taskbar/OptionsMenu/MouseOn/Label.text = UniversalFunctions.dialogueJson["MouseOff"]
			$Taskbar/OptionsMenu/Mobile/Label.text = UniversalFunctions.dialogueJson["ForDesk"]
			$cursor.cursorDisabled = true
			$cursor.visible = false
		else:
			$Taskbar/OptionsMenu/Fullscreen/Label.text = UniversalFunctions.dialogueJson["Fullscreen"]
			$Taskbar/OptionsMenu/MouseOn/Label.text = UniversalFunctions.dialogueJson["MouseOn"]
			$Taskbar/OptionsMenu/Mobile/Label.text = UniversalFunctions.dialogueJson["ForMobile"]
			$cursor.cursorDisabled = false
			OS.window_fullscreen = false
			$cursor.visible = true
	elif optionpressed == "Audio":
		if $AudioStreamPlayer.volume_db == 0:
			$Taskbar/OptionsMenu/Audio/Label.text = UniversalFunctions.dialogueJson["AudioOff"]
			$AudioStreamPlayer.volume_db = -80
		else:
			$Taskbar/OptionsMenu/Audio/Label.text = UniversalFunctions.dialogueJson["AudioOn"]
			$AudioStreamPlayer.volume_db = 0

