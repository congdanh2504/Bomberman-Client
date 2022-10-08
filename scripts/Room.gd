extends Node2D

var PlayerName = preload("res://scenes/PlayerName.tscn")
onready var box = $VBoxContainer

func _ready():
	Networking.get_room_players(Global.get_roomname())
	Networking.connect("load_room", self, "_load_room")
	Networking.connect("update_rooms", self, "_update_room")
	
	
func _load_room(players):
	for i in range(0, len(players)):
		var playerName = PlayerName.instance()
		playerName.text = players[i].username
		box.add_child(playerName)
		

func _update_room(rooms):
	for n in box.get_children():
		box.remove_child(n)
		n.queue_free()
	for i in range(0, len(rooms)):
		if rooms[i].roomName == Global.get_roomname():
			_load_room(rooms[i].players)
			return
	exitRoom()		


func _on_ExitButton_pressed():
	Networking.left_room(Global.get_roomname())
	exitRoom()
	
func exitRoom():
	Global.set_roomname("")
	get_tree().change_scene("res://scenes/Rooms.tscn")
