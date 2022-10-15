extends Node

var ws = WebSocketClient.new()

signal kick(message)
signal connnect_success
signal update_rooms(rooms)
signal load_room(players)
signal start_game(stones, items, players)
signal update_pos(username, x, y, animation)
signal drop_bomb(x, y, bomb_range, your_bomb)
signal remove_player(username)

func ready():
	self.connection()


func _process(delta):
	if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
		ws.poll()
	pass
	
	
func connection():
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_client_received")
	var url = "ws://%s" % Global.get_serve_ip()
	ws.connect_to_url(url)


func _connection_established(protocol):
	print("[Game] Connection made successfully! - %s" %protocol)
	emit_signal("connnect_success")
	ws.get_peer(1).put_var({
		"type": 'OnPlayerAuth',
		"data": {
			"username": Global.get_username()
		}
	})	
	

func _connection_error():
	print("[Game] Unable to establish a connection to the server")
	emit_signal("kick", "Can't connect to server")
	
func _client_received():
	var packet = ws.get_peer(1).get_packet()

	var resultJSON = JSON.parse(packet.get_string_from_utf8())
	
	var type = resultJSON.result.type
	
#	print(type)
	var data = resultJSON.result
	
	if type == "kick":
		emit_signal("kick", data.message)
		
	if type == "updateRoom":
		emit_signal("update_rooms", data.data)
		
	if type == "loadRoom":
		emit_signal("load_room", data.players)
		
	if type == "startGame":
		emit_signal("start_game", data.data.blocks.stones, data.data.blocks.items, data.data.players)
		
	if type == "updatePos":
		emit_signal("update_pos", data.data.username, data.data.x, data.data.y, data.data.animation)
		
	if type == "dropBomb":
		emit_signal("drop_bomb", data.data.x, data.data.y, data.data.bombRange, data.data.yourBomb)
		
	if type == "removePlayer":
		emit_signal("remove_player", data.username)
	
func createRoom():
	ws.get_peer(1).put_var({
		"type": 'OnCreateRoom'
	})	
	
	
func join_room(room_name):
	ws.get_peer(1).put_var({
		"type": 'onJoinRoom',
		"roomName": room_name
	})	
	
func get_room_players(room_name):
	ws.get_peer(1).put_var({
		"type": 'onGetRoomPlayers',
		"roomName": room_name
	})	

func left_room():
	ws.get_peer(1).put_var({
		"type": 'onLeftRoom'
	})	
	
func start_game(room_name):
	ws.get_peer(1).put_var({
		"type": 'onStartGame',
		"roomName": room_name
	})

func update_pos(username, x, y, animation, roomName):
	ws.get_peer(1).put_var({
		"type": 'onUpdatePos',
		"data": {
			"username": username,
			"x": x,
			"y": y,
			"animation": animation,
			"roomName": roomName
		}
	})
	
func drop_bomb(x, y, bomb_range, username):
	ws.get_peer(1).put_var({
		"type": 'onDropBomb',
		"data": {
			"x": x,
			"y": y,
			"bombRange": bomb_range,
			"username": username
		}
	})

func log_out():
	ws.disconnect_from_host()
