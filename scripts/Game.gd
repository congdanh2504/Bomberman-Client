extends Node2D

var Block = preload("res://scenes/Block.tscn")
var Stone = preload("res://scenes/Stone.tscn")
var Player = preload("res://scenes/Player.tscn")
var Bomb = preload("res://scenes/Bomb.tscn")
var Explosion = preload("res://scenes/Explosion.tscn")
var Item = preload("res://scenes/Item.tscn")
const BLOCK = Constant.BLOCK
const STONE = Constant.STONE
const BLOCK_SIZE = Constant.BLOCK_SIZE
var width = Constant.width
var height = Constant.height
onready var playersNode = $YSort/Players
onready var ysort = $YSort
onready var bombs = $YSort/Bombs
onready var itemsNode = $Items
onready var dialog = $Dialog
onready var outGame = $OutGame
onready var timeCounter = $Panel/Label
onready var chat = $Panel/RichTextLabel
onready var message = $Panel/LineEdit
onready var fire_abi = $Panel/fire
onready var bomb_abi = $Panel/bomb
onready var shoes_abi = $Panel/shoes
var rng = RandomNumberGenerator.new()
var focus = false
var time = 0


func append_text(text:String, color:String = "#eeeeee"):
	chat.push_color(Color(color))
	chat.add_text('\n'+text)
	chat.pop()


func _process(delta):
	time += delta
	var secs = fmod(time, 60)
	var mins = fmod(time, 60*60) / 60
	var time_passed = "%02d:%02d" % [mins, secs]
	fire_abi.text = "x%d" % Stats.fire_abi
	bomb_abi.text = "x%d" % Stats.bomb_abi
	shoes_abi.text = "x%d" % Stats.shoes_abi
	timeCounter.text = time_passed


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


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			if Global.get_is_chatting():
				if message.text != "":
					Networking.send_message(message.text)
				message.text = ""
				message.release_focus()
				Global.set_is_chatting(false)
			else:
				message.grab_focus()
				Global.set_is_chatting(true)

func _ready():
	rng.randomize()
	Map.reset()
	Networking.connect("drop_bomb", self, "_drop_bomb")
	Networking.connect("update_pos", self, "_update_pos")
	Networking.connect("remove_player", self, "_remove_player")
	Networking.connect("chat", self, "append_text")
	message.connect("focus_entered", self, "_focus_entered")
	chat.set_scroll_follow(true)
	var tempChat = Global.get_temp_chat()
	for row in tempChat:
		append_text(row['message'], row['color'])

	for i in range(BLOCK_SIZE, height - 4, 32):
		for j in range(BLOCK_SIZE, width - 4, 32):
			ysort.add_child(new_block(j, i))
			Map.set_value(j/BLOCK_SIZE, i/BLOCK_SIZE, BLOCK)

	var stones = Global.get_stones()
	for stone in stones:
		ysort.add_child(new_stone(stone.x, stone.y))
		Map.set_value(stone.x/BLOCK_SIZE, stone.y/BLOCK_SIZE, STONE)
		
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


func _focus_entered():
	Global.set_is_chatting(true)


func _go_off(x, y, bomb_range, your_bomb, player_id):
	var exlosion = Explosion.instance()
	exlosion.play("start")
	exlosion.position.x = x
	exlosion.position.y = y
	add_child(exlosion)

	for i in range(1, bomb_range+1):
		var new_x = x + i*BLOCK_SIZE
		var new_y = y
		if invalid_position(new_x, new_y): 
			break
		if Map.check_is_stone(new_x, new_y):
			Map.set_value(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, 0)
			Map.get_map_stone()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE].destroy()
			Map.set_value_stone(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, null)
			break
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0:
			var exlosionRight = Explosion.instance()
			if i == bomb_range:
				exlosionRight.play("end_ver")
			else:
				exlosionRight.play("mid_ver")
			
			exlosionRight.position.x = new_x
			exlosionRight.position.y = new_y
			add_child(exlosionRight)
		else:
			break
	
	for i in range(1, bomb_range+1):
		var new_x = x - i*BLOCK_SIZE
		var new_y = y
		if invalid_position(new_x, new_y): 
			break
		if Map.check_is_stone(new_x, new_y):
			Map.set_value(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, 0)
			Map.get_map_stone()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE].destroy()
			Map.set_value_stone(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, null)
			break
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2:
			var exlosionLeft = Explosion.instance()
			if i == bomb_range:
				exlosionLeft.play("end_ver")
				exlosionLeft.flip_h = true
			else:
				exlosionLeft.play("mid_ver")
			
			exlosionLeft.position.x = new_x
			exlosionLeft.position.y = new_y
			add_child(exlosionLeft)
		else:
			break
		
	for i in range(1, bomb_range+1):
		var new_x = x
		var new_y = y + i*BLOCK_SIZE
		if invalid_position(new_x, new_y): 
			break
		if Map.check_is_stone(new_x, new_y):
			Map.set_value(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, 0)
			Map.get_map_stone()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE].destroy()
			Map.set_value_stone(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, null)
			break
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2:
			var exlosionUp = Explosion.instance()
			if i == bomb_range:
				exlosionUp.play("end_hori")
				exlosionUp.flip_v = true
			else:
				exlosionUp.play("mid_hori")
				
			exlosionUp.position.x = new_x
			exlosionUp.position.y = new_y
			add_child(exlosionUp)
		else:
			break
		
	for i in range(1, bomb_range+1):
		var new_x = x
		var new_y = y - i*BLOCK_SIZE
		if invalid_position(new_x, new_y): 
			break
		if Map.check_is_stone(new_x, new_y):
			Map.set_value(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, 0)
			Map.get_map_stone()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE].destroy()
			Map.set_value_stone(new_x/BLOCK_SIZE, new_y/BLOCK_SIZE, null)
			break
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2:
			var exlosionDown = Explosion.instance()
			if i == bomb_range:
				exlosionDown.play("end_hori")
			else:
				exlosionDown.play("mid_hori")
			exlosionDown.position.x = new_x
			exlosionDown.position.y = new_y
			add_child(exlosionDown)
		else:
			break
			
	if your_bomb:
		Stats.increase_bomb_num()


func invalid_position(x, y):
	return x >= width or y >= height or x < 0 or y < 0


func _drop_bomb(x, y, bomb_range, your_bomb):
	if your_bomb:
		Stats.decrease_bomb_num()
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
			
	if x > width - 6:
		x -= BLOCK_SIZE
	if y > height - 6:
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
	Global.clear_temp_chat()
	dialog._set_caption("You lose!")
	dialog._set_info("You lose!")
	dialog._show_dialog()
	outGame.start()
	Networking.left_room()


func win_game():
	Global.clear_temp_chat()
	dialog._set_caption("You win!")
	dialog._set_info("You win!")
	dialog._show_dialog()
	outGame.start()
	Networking.left_room()


func _on_OutGame_timeout():
	get_tree().change_scene("res://scenes/Rooms.tscn")
