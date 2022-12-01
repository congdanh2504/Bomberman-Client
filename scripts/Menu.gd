extends Node2D

onready var input_username = $VBoxContainer/Username
onready var input_ip = $VBoxContainer/IP

func validate():
	Global.set_serve_ip(input_ip.text)
	Global.set_username(input_username.text)
	return get_tree().change_scene("res://scenes/Rooms.tscn")


func _on_Button_pressed():
	validate()


func _on_PlayWithBot_pressed():
	return get_tree().change_scene("res://scenes/AIGame.tscn")
