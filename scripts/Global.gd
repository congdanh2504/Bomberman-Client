extends Node

var username = ''
var serve_ip = '127.0.0.1:8080'
var room_name = ''

func get_username() -> String:
	return username

func set_username(name: String) -> void:
	username = name

func get_serve_ip() -> String:
	return serve_ip

func set_serve_ip(ip: String) -> void:
	serve_ip = ip
	
func get_roomname() -> String:
	return room_name

func set_roomname(name: String) -> void:
	room_name = name
