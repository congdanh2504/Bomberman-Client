extends Node2D

var Block = preload("res://scenes/Block.tscn")
var Stone = preload("res://scenes/Stone.tscn")
var Player = preload("res://scenes/Player.tscn")
onready var playersNode = $YSort/Players
onready var ysort = $YSort
var rng = RandomNumberGenerator.new()

func new_block(x, y):
	var block = Block.instance()
	block.position.x = x
	block.position.y = y
	return block
	
	
func new_stone(x, y):
	var store = Stone.instance()
	store.position.x = x
	store.position.y = y
	return store
	
	
func _ready():
	rng.randomize()
	Networking.connect("update_pos", self, "_update_pos")
	
	for i in range(24, 300, 32):
		for j in range(24, 300, 32):
			ysort.add_child(new_block(j, i))
			
	var stones = Global.get_stones()
	for i in range(0, len(stones)):
		ysort.add_child(new_stone(stones[i].x, stones[i].y))
		
	var players = Global.get_players()
	for player in players:
		var new_player = Player.instance()
		new_player.update_pos(player.pos.x, player.pos.y)
		new_player.active = player.active
		new_player.id = player.id
#		print(new_player)
		playersNode.add_child(new_player)
	

func _update_pos(id, x, y, animation):
	var players = playersNode.get_children()
	for player in players:
		if player.id == id:
			player.update_pos(x, y)
			player.client_play(animation)
