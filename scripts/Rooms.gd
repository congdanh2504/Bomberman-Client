extends Node2D

onready var kick_timer = $kick
onready var box = $VBoxContainer
onready var dialog = $Dialog
var button = preload("res://scenes/ButtonLine.tscn")

func _ready():
	Networking.ready()
	Networking.connect("kick", self, "on_kick")
	Networking.connect("update_rooms", self, "_update_rooms")


func on_kick(message):
	dialog._set_caption("Warning")
	dialog._set_info(message)
	dialog._show_dialog()
	kick_timer.start()


func _on_kick_timeout():
	get_tree().change_scene("res://scenes/Menu.tscn")


func _on_NewRoomButton_pressed():
	Networking.createRoom()
	Global.set_roomname("Room of " + Global.get_username())

func _update_rooms(rooms):
	for n in box.get_children():
		box.remove_child(n)
		n.queue_free()
	for i in range(0, len(rooms)):
		var newButton = button.instance()
		newButton.text = rooms[i].roomName + ": " + str(rooms[i].length) + "/4"
		for j in range(0, len(rooms[i].players)):
			if rooms[i].players[j].username== Global.get_username():
				get_tree().change_scene("res://scenes/Room.tscn")
		box.add_child(newButton)
		newButton.connect("on_click", self, "on_button_click")


func on_button_click(name):
	Global.set_roomname(name)
	Networking.join_room(name)


func _on_LogOutButton_pressed():
	Networking.log_out()
	get_tree().change_scene("res://scenes/Menu.tscn")
