extends Node

var ws = WebSocketClient.new()

signal kick(message)
signal connnect_success
signal update_rooms(rooms)

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
	
	print(type)
	
	if type == "kick":
		emit_signal("kick", resultJSON.result.message)
		
	if type == "updateRoom":
		emit_signal("update_rooms", resultJSON.result.data)
	
func createRoom():
	ws.get_peer(1).put_var({
		"type": 'OnCreateRoom'
	})	
	
	

