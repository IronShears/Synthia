extends Sprite

signal openFile

var allItems={
	"system":["images","documents"],
	"images":["mycat1jpg","mycat2jpg","mykot3jpg"],
	"documents":["clickMe", "groceriestxt"],
	"clickMe":["IGNOREjpg","YOURjpg","DIRECTIVESjpg","ANDjpg","READTHISrtf"],
	"why":["AN_EXPLAINATIONrtf"],
	"cynthia":["LOVErtf", "NOSTALGIAjpg"],
	"myWish":["BLOW_A_WISHzip","WISHINGrtf"],
	"imSorry":["apologyrtf"],
	"atPeace":["THANKYOUrtf","ONEDAYjpg"]
	
}
onready var visibleFolders = ["system","images","documents"]
var currentFolder = "system"
var process = false
var currentPos = null
var current
var currentSize
onready var nodesPos = [$StorageFile1.position, $StorageFile2.position, $StorageFile3.position, $StorageFile4.position, $StorageFile5.position, $StorageFile6.position]
onready var nodes = [$StorageFile1,$StorageFile2,$StorageFile3,$StorageFile4,$StorageFile5,$StorageFile6,$VBoxContainer/system,$VBoxContainer/images,$VBoxContainer/clickMe,$VBoxContainer/documents,$VBoxContainer/why,$VBoxContainer/cynthia,$VBoxContainer/myWish,$VBoxContainer/imSorry,$VBoxContainer/atPeace]


func _ready():
	set_up()

func set_up():
	var counter = 1
	$FilePath.text = UniversalFunctions.dialogueJson[currentFolder+"Path"]
	#Sets all nodes to invisible
	for i in nodes:
		i.visible = false
	#Makes correct folders visible
	for i in visibleFolders:
		get_tree().get_root().get_node_or_null("/root/world/FileSystem/VBoxContainer/"+i).visible = true
		get_tree().get_root().get_node_or_null("/root/world/FileSystem/VBoxContainer/"+i+"/Label").text = UniversalFunctions.dialogueJson[i]
	#Makes correct items visible
	for i in allItems[currentFolder]:
		get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(counter)).visible = true
		get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(counter)).currentFileName = i
		get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(counter)+"/Label").text = UniversalFunctions.dialogueJson[i]
		get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(counter)).currentFileNum = counter
		#Sets the image
		if i.ends_with("jpg") or i.ends_with("gif"):
			get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(counter)).play("image")
		elif i.ends_with("txt") or i.ends_with("rtf"):
			get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(counter)).play("text")
		else:
			get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(counter)).play("folder")
		counter+=1
			
func _process(_delta):
	if process == true:
		if get_global_mouse_position().distance_to(currentPos) < 15:
			return
		current.global_position = Vector2(get_global_mouse_position().x-currentSize,get_global_mouse_position().y-5)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_StorageFile_button_down(nodeNum,nodeName):
	if get_tree().get_root().get_node_or_null("/root/world/Taskbar/time").text == "17:00":
		return
	if z_index != 3:
		return
	if nodeName.ends_with("jpg") or nodeName.ends_with("gif") or nodeName.ends_with("txt") or nodeName.ends_with("rtf"):
		currentPos = get_global_mouse_position()
		current = get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(nodeNum))
		currentSize = get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(nodeNum)+"/Label").rect_size.x/3
		process = true 


func _on_StorageFile_button_up(nodeNum,nodeName):
	if z_index != 3:
		return
	if nodeName.ends_with("jpg") or nodeName.ends_with("gif") or nodeName.ends_with("txt") or nodeName.ends_with("rtf"):
		process = false
		if get_global_mouse_position().x < self.position.x or get_global_mouse_position().x-20 > self.position.x + 206 or  get_global_mouse_position().y < self.position.y or get_global_mouse_position().y > self.position.y + 142:
			get_tree().get_root().get_node_or_null("/root/world/Icons/").new_file(nodeName)
			get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(nodeNum)).position = nodesPos[nodeNum-1]
			allItems[currentFolder].erase(nodeName)
			if allItems[currentFolder] == []:
				if currentFolder != "system":
					empty_folders()
			set_up()

		else:
			if get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(nodeNum)).position == nodesPos[nodeNum-1]:
				emit_signal("openFile", nodeName)
			else:
				get_tree().get_root().get_node_or_null("/root/world/FileSystem/StorageFile"+str(nodeNum)).position = nodesPos[nodeNum-1]
	elif nodeName.ends_with("zip"):
		allItems[currentFolder].erase(nodeName)
		if allItems[currentFolder] == []:
			if currentFolder != "system":
				empty_folders()
		emit_signal("openFile", nodeName)
	else:
		_on_system_pressed(nodeName)

func empty_folders():
	if get_tree().get_root().get_node_or_null("/root/world/Taskbar/time").text == "17:00":
		return
	if currentFolder == "clickMe":
		visibleFolders.erase(currentFolder)
		allItems["documents"].erase("clickMe")
		if allItems["documents"] == []:
			visibleFolders.erase("documents")
			allItems["system"].erase("documents")
	else:
		visibleFolders.erase(currentFolder)
		allItems["system"].erase(currentFolder)
	currentFolder = "system"
	set_up()


func _on_system_pressed(nodeName):
	if get_tree().get_root().get_node_or_null("/root/world/Taskbar/time").text == "17:00":
		return
	currentFolder = nodeName
	if nodeName == "documents" and allItems["clickMe"]!=[]:
		if visibleFolders.has("clickMe") ==false:
			visibleFolders.append("clickMe")
	set_up()
		
