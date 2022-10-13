extends Node2D

var PlayerName = preload("res://scenes/PlayerName.tscn")
onready var box = $VBoxContainer
onready var startButton = $StartButton

func _ready():
	Networking.get_room_players(Global.get_roomname())
	Networking.connect("load_room", self, "_load_room")
	Networking.connect("update_rooms", self, "_update_room")
	Networking.connect("start_game", self, "_start_game")
	if !Global.is_room_host():
		$StartButton.queue_free()
	
	
func _load_room(players):
	if Global.is_room_host():
		startButton.disabled = len(players) < 2
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


func _on_StartButton_pressed():
	Networking.start_game(Global.get_roomname())
	
	
func _start_game(stones, items, players):
	Global.set_stones(stones)
	Global.set_items(items)
	Global.set_players(players)
	get_tree().change_scene("res://scenes/Game.tscn")
