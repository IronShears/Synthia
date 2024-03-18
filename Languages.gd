extends Node2D


func _on_English_pressed():
	UniversalFunctions.language = ""
	UniversalFunctions.set_text()
	UniversalFunctions.change_scenes_reset("res://login.tscn")


func _on_Chinese_pressed():
	UniversalFunctions.language = "_CN"
	UniversalFunctions.set_text()
	UniversalFunctions.change_scenes_reset("res://login.tscn")
