extends Node2D

var Block = preload("res://scenes/Block.tscn")
var Stone = preload("res://scenes/Stone.tscn")
var Player = preload("res://scenes/Player.tscn")
var Bomb = preload("res://scenes/Bomb.tscn")
var Explosion = preload("res://scenes/Explosion.tscn")
var Item = preload("res://scenes/Item.tscn")
const BLOCK = 1
const STONE = 2
const BLOCK_SIZE = 16
onready var playersNode = $YSort/Players
onready var ysort = $YSort
onready var bombs = $YSort/Bombs
onready var itemsNode = $Items
onready var dialog = $Dialog
onready var outGame = $OutGame
var rng = RandomNumberGenerator.new()

func new_block(x, y):
	var block = Block.instance()
	block.position.x = x
	block.position.y = y
	return block


func new_stone(x, y):
	var stone = Stone.instance()
	stone.position.x = x
	stone.position.y = y
	Map.set_value_stone(x/BLOCK_SIZE, y/BLOCK_SIZE, stone)
	return stone


func _ready():
	rng.randomize()
	Networking.connect("drop_bomb", self, "_drop_bomb")
	Networking.connect("update_pos", self, "_update_pos")
	Networking.connect("remove_player", self, "_remove_player")

	for i in range(BLOCK_SIZE, 300, 32):
		for j in range(BLOCK_SIZE, 300, 32):
			ysort.add_child(new_block(j, i))
			Map.set_value(j/BLOCK_SIZE, i/BLOCK_SIZE, BLOCK)

	var stones = Global.get_stones()
	for i in range(0, len(stones)):
		Map.set_value(stones[i].x/BLOCK_SIZE, stones[i].y/BLOCK_SIZE, STONE)
		ysort.add_child(new_stone(stones[i].x, stones[i].y))
		
	var items = Global.get_items()
	for item in items:
		var new_item = Item.instance()
		new_item.id = item.type
		new_item.position = Vector2(item.x, item.y)
		itemsNode.add_child(new_item)

	var players = Global.get_players()
	for player in players:
		var new_player = Player.instance()
		new_player.update_pos(player.pos.x, player.pos.y)
		new_player.active = player.active
		new_player.id = player.id
		new_player.username = player.username
		if player.active:
			new_player.connect("lose_game", self, "_lose_game")
		playersNode.add_child(new_player)


func _go_off(x, y, bomb_range, your_bomb):
	var exlosion = Explosion.instance()
	exlosion.play("start")
	exlosion.position.x = x
	exlosion.position.y = y
	add_child(exlosion)
	
	var index_x = x/BLOCK_SIZE
	var index_y = y/BLOCK_SIZE

	for i in range(1, bomb_range+1):
		var new_x = x + i*BLOCK_SIZE
		var new_y = y
		if invalid_position(new_x, new_y): 
			break
		if Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0:
			var exlosionRight = Explosion.instance()
			if i == bomb_range:
				exlosionRight.play("end_ver")
			else:
				exlosionRight.play("mid_ver")
			
			exlosionRight.position.x = new_x
			exlosionRight.position.y = new_y
			add_child(exlosionRight)
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2:
			Map.get_map_stone()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE].destroy()
			Map.set_value(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, 0)
			break
		else:
			break	
	
	for i in range(1, bomb_range+1):
		var new_x = x - i*BLOCK_SIZE
		var new_y = y
		if invalid_position(new_x, new_y): 
			break
		if Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0:
			var exlosionLeft = Explosion.instance()
			if i == bomb_range:
				exlosionLeft.play("end_ver")
				exlosionLeft.flip_h = true
			else:
				exlosionLeft.play("mid_ver")
			
			exlosionLeft.position.x = new_x
			exlosionLeft.position.y = new_y
			add_child(exlosionLeft)
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2:
			Map.get_map_stone()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE].destroy()
			Map.set_value(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, 0)
			break
		else:
			break
		
	for i in range(1, bomb_range+1):
		var new_x = x
		var new_y = y + i*BLOCK_SIZE
		if invalid_position(new_x, new_y): 
			break
		if Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0:
			var exlosionUp = Explosion.instance()
			if i == bomb_range:
				exlosionUp.play("end_hori")
				exlosionUp.flip_v = true
			else:
				exlosionUp.play("mid_hori")
				
			exlosionUp.position.x = new_x
			exlosionUp.position.y = new_y
			add_child(exlosionUp)
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2:
			Map.get_map_stone()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE].destroy()
			Map.set_value(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, 0)
			break
		else:
			break
		
	for i in range(1, bomb_range+1):
		var new_x = x
		var new_y = y - i*BLOCK_SIZE
		if invalid_position(new_x, new_y): 
			break
		if Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0:
			var exlosionDown = Explosion.instance()
			if i == bomb_range:
				exlosionDown.play("end_hori")
			else:
				exlosionDown.play("mid_hori")
			exlosionDown.position.x = new_x
			exlosionDown.position.y = new_y
			add_child(exlosionDown)
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2:
			Map.get_map_stone()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE].destroy()
			Map.set_value(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, 0)
			break
		else:
			break
			
	if your_bomb:
		Stats.increase_bomb_num()


func invalid_position(x, y):
	return x/BLOCK_SIZE >= 19 or y/BLOCK_SIZE >= 19 or x/BLOCK_SIZE < 0 or y/BLOCK_SIZE < 0


func _drop_bomb(x, y, bomb_range, your_bomb):
	var bomb = Bomb.instance()
	x = int(x) 
	y = int(y) 
	if x % BLOCK_SIZE != 0:
		if x % BLOCK_SIZE <= 8:
			x -= x % BLOCK_SIZE
		else:
			x += BLOCK_SIZE- x%BLOCK_SIZE 

	if y % BLOCK_SIZE != 0: 
		if y % BLOCK_SIZE <= 8:
			y -= y % BLOCK_SIZE
		else:
			y += BLOCK_SIZE- y%BLOCK_SIZE 
			
	if x > 298:
		x -= BLOCK_SIZE
	if y > 298:
		y -= BLOCK_SIZE
	bomb.position = Vector2(x, y)
	bomb.bomb_range = bomb_range
	bomb.your_bomb = your_bomb
	bombs.add_child(bomb)
	if your_bomb:
		bomb.collision.disabled = true
	bomb.connect("go_off", self, "_go_off")
	

func _update_pos(username, x, y, animation):
	var players = playersNode.get_children()
	for player in players:
		if player.username == username and player.died == false:
			player.update_pos(x, y)
			player.client_play(animation)

func _remove_player(username):
	var players = playersNode.get_children()
	for player in players:
		if player.username == username:
			playersNode.remove_child(player)

	if len(playersNode.get_children()) == 1:
		win_game()


func _lose_game():
	dialog._set_caption("You lose!")
	dialog._set_info("You lose!")
	dialog._show_dialog()
	outGame.start()
	Networking.left_room()


func win_game():
	dialog._set_caption("You win!")
	dialog._set_info("You win!")
	dialog._show_dialog()
	outGame.start()
	Networking.left_room()

func _on_OutGame_timeout():
	get_tree().change_scene("res://scenes/Rooms.tscn")
