extends Node2D
onready var stage = UniversalFunctions.dialogueJson["FirstName"]
onready var passwordFull = UniversalFunctions.dialogueJson["Password"]+"************"+"|"
var passwordCounter = "*"
var obscene = false
var scenechanging = false

func _ready():
	$Name.text = UniversalFunctions.dialogueJson["FirstName"]+ "|"
	$SubmitName.text = UniversalFunctions.dialogueJson["Enter"]
	$SLURTIMEOUT/Label.text = UniversalFunctions.dialogueJson["ObsceneDisclaimer"]

func _on_Blinker_timeout():
	if stage == UniversalFunctions.dialogueJson["Password"]:
		if $Name.text == passwordFull:
			$loading.visible = true
			$loading/loading.play("default")
			$SubmitName.visible = false
			yield($loading/loading,"animation_finished")
			check_obscene(UniversalFunctions.firstName+UniversalFunctions.lastName)
			if obscene == false:
				if scenechanging == true:
					return
				scenechanging = true
				UniversalFunctions.change_scenes_reload("res://main.tscn")
			else:
				$Blinker.wait_time = 0.5
				$loading.visible = false
				$Name.text = UniversalFunctions.dialogueJson["Obscene"]
				stage = "Obscene"
				$SLURTIMER.start()
		else:
			$Blinker.wait_time = 0.1
			$Name.text = UniversalFunctions.dialogueJson["Password"]+passwordCounter+"|"
			passwordCounter = passwordCounter+"*"
			$Name.set_visible_characters(-1)
	elif stage =="Obscene":
		pass
	else:
		if $Name.get_visible_characters() == -1:
			$Name.set_visible_characters($Name.text.length()-1)
		else:
			$Name.set_visible_characters(-1)
			


func _on_Backspace_pressed():
	if stage == UniversalFunctions.dialogueJson["Password"]:
		return
	if $Name.text.length() >= stage.length()+2:
		$Name.text = $Name.text.substr(0,$Name.text.length()-2)
		$Name.text = $Name.text+"|"

func _on_Keyboard_key_entered(key):
	if stage == UniversalFunctions.dialogueJson["Password"]:
		return
	if $"Keyboard/1/Label".text == "a":
		$Keyboard._on_case_pressed()
	if $Name.text.length() <= stage.length()+15:
		$Name.text = $Name.text.replace("|",key+"|")

func _on_SubmitName_pressed():
	if stage == UniversalFunctions.dialogueJson["FirstName"]:
		var setName = $Name.text
		setName = setName.replace(UniversalFunctions.dialogueJson["FirstName"], "")
		setName = setName.replace("|", "")
		while setName.length() > 0:
			if setName[0] == " ":
				setName.erase(0,1)
			else:
				break
			
		while setName.length() > 0:
			if setName.ends_with(" "):
				setName.erase(setName.length()-1,1)
			else:
				break
		if setName.length() <= 0:
			return
		check_funny(setName)
		check_obscene(setName)
		if $"Keyboard/1/Label".text == "a":
			$Keyboard._on_case_pressed()
		UniversalFunctions.firstName = setName
		$Name.text = UniversalFunctions.dialogueJson["LastName"]+"|"
		stage = UniversalFunctions.dialogueJson["LastName"]
	elif stage == UniversalFunctions.dialogueJson["LastName"]: 
		var setName = $Name.text
		setName = setName.replace(UniversalFunctions.dialogueJson["LastName"], "")
		setName = setName.replace("|", "")
		while setName.length() > 0:
			if setName[0] == " ":
				setName.erase(0,1)
			else:
				break
			
		while setName.length() > 0:
			if setName.ends_with(" "):
				setName.erase(setName.length()-1,1)
			else:
				break
		if setName.length() <= 0:
			return
		check_obscene(setName)
		$Keyboard._on_case_pressed()
		UniversalFunctions.lastName = setName
		$Name.text = UniversalFunctions.dialogueJson["Password"]
		stage = UniversalFunctions.dialogueJson["Password"]
		

func check_funny(setName):
	for i in ["ass", "balls","fuck", "shit", "penis", "cock", "dick", "cunt","pussy", "vagina","bitch","arse","crap","minger","minging","hell","piss","slut","whore","wank"]:
		var funnyChecker = setName.to_lower()
		if i in funnyChecker:
			UniversalFunctions.nameReaction = "nameFunny"
	if setName == "Ada" or setName == "Synthia" or setName == "Cynthia" or setName == "Jean Paul" or setName == "JeanPaul": 
		UniversalFunctions.nameReaction = "nameSame"

func check_obscene(setName):
	for i in ["rapist", "pedophile","nigger", "nigga", "nigguh", "niggar", "niggur", "faggot", "fagot","fag", "wetback", "wet back", "beaner", "kike", "raghead",  "rag head", "towelhead", "towel head", "dyke","chink", "racist", "sexist","homophobe","transphobe", "white power"]:
		var slurChecker = setName.to_lower()
		if i in slurChecker:
			var doubleCheck = false
			for x in ["cofagrigus", "fage", "snigger", "therapist", "pachinko"]:
				if x in slurChecker:
					doubleCheck = true
			if doubleCheck == false:
				obscene = true


func _on_SLURTIMER_timeout():
	$SLURTIMEOUT.visible = true


func _on_AudioStreamPlayer_finished():
	var newStream = load("res://Resources/Sounds/Humming.wav")
	
	$AudioStreamPlayer.stream = newStream
	$AudioStreamPlayer.playing = true
