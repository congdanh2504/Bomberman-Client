extends Node2D

onready var kick_timer = $kick
onready var dialog = $Dialog
onready var box = $VBoxContainer
var button = preload("res://scenes/ButtonLine.tscn")

func _ready():
	Networking.ready()
	Networking.connect("kick", self, "on_kick")
	Networking.connect("update_rooms", self, "_update_rooms")
	#Networking.connect("connect_success", self, "")

func on_kick(message):
	dialog._set_caption("asdasd")
	dialog._set_info(message)
	dialog._show_dialog()
	kick_timer.start()


func _on_kick_timeout():
	get_tree().change_scene("res://scenes/Menu.tscn")


func _on_NewRoomButton_pressed():
	Networking.createRoom()
	

func _update_rooms(rooms):
	for n in box.get_children():
		box.remove_child(n)
		n.queue_free()
	for i in range(0, len(rooms)):
		var newButton = button.instance()
		newButton.text = rooms[i].roomName + ": " + str(rooms[i].length) + "/4"
		box.add_child(newButton)
