extends Node

var username = ''
var serve_ip = '127.0.0.1:8080'
var room_name = ''
var stones
var players

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

func is_room_host() -> bool:
	return get_roomname().substr(8) == get_username()
	
func get_stones():
	return stones
	
func set_stones(_stones):
	stones = _stones

func get_players():
	return players
	
func set_players(_players):
	players = _players
