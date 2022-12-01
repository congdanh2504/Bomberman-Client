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
const BOMB = Constant.BOMB
var width = Constant.width
var height = Constant.height
onready var ysort = $YSort
onready var outGame = $OutGame
onready var itemsNode = $Items
onready var dialog = $Dialog
var rng = RandomNumberGenerator.new()
var time = 0
onready var bombs = $YSort/Bombs
onready var fire_abi = $Panel/fire
onready var bomb_abi = $Panel/bomb
onready var shoes_abi = $Panel/shoes
onready var timeCounter = $Panel/Label
onready var ai_player = $YSort/Players/AIPlayer
onready var ai_player2 = $YSort/Players/AIPlayer2
onready var ai_player3 = $YSort/Players/AIPlayer3
onready var main_player = $YSort/Players/MainPlayer
onready var timer = $Timer
onready var timer2 = $Timer2
onready var timer3 = $Timer3
onready var timer4 = $Timer4

signal timer_end
signal timer_end2
signal timer_end3
signal timer_end4


func run_timer(time):
	timer.set_wait_time(time)
	timer.set_timer_process_mode(0)
	timer.start()
	
func run_timer2(time):
	timer2.set_wait_time(time)
	timer2.set_timer_process_mode(0)
	timer2.start()
	
func run_timer3(time):
	timer3.set_wait_time(time)
	timer3.set_timer_process_mode(0)
	timer3.start()
	
func run_timer4(time):
	timer4.set_wait_time(time)
	timer4.set_timer_process_mode(0)
	timer4.start()			


func _emit_timer_end_signal():
	emit_signal("timer_end")
	
func _emit_timer_end_signal2():
	emit_signal("timer_end2")
	
func _emit_timer_end_signal3():
	emit_signal("timer_end3")
	
func _emit_timer_end_signal4():
	emit_signal("timer_end4")


func new_block(x, y):
	var block = Block.instance()
	block.position.x = x
	block.position.y = y 
	Map.set_value(x/BLOCK_SIZE, y/BLOCK_SIZE, BLOCK)
	return block


func new_stone(x, y):
	var stone = Stone.instance()
	stone.position.x = x
	stone.position.y = y
	Map.set_value_stone(x/BLOCK_SIZE, y/BLOCK_SIZE, stone)
	Map.set_value(x/BLOCK_SIZE, y/BLOCK_SIZE, STONE)
	return stone


func generate_stones():
	for i in range(16, width-20, 16):
		for j in range(16, height-20, 16):
			if (i - 16) % 32 == 0 and (j - 16) % 32 == 0:
				continue
			var rand = rng.randi_range(0, 10)
			if rand > 5:
				ysort.add_child(new_stone(i, j))
				rand = rng.randi_range(0, 10)
				if rand > 3:
					var new_item = Item.instance()
					new_item.id = rng.randi_range(0, 3)
					new_item.position = Vector2(i, j)
					itemsNode.add_child(new_item)
	for i in range(32, height-36, 16):
		var rand = rng.randi_range(0, 10)
		if rand > 5:
			ysort.add_child(new_stone(0, i))
			rand = rng.randi_range(0, 10)
			if rand > 3:
				var new_item = Item.instance()
				new_item.id = rng.randi_range(0, 3)
				new_item.position = Vector2(0, i)
				itemsNode.add_child(new_item)
		rand = rng.randi_range(0, 10)
		if rand > 5:
			ysort.add_child(new_stone(width-16, i))
			rand = rng.randi_range(0, 10)
			if rand > 3:
				var new_item = Item.instance()
				new_item.id = rng.randi_range(0, 3)
				new_item.position = Vector2(width-16, i)
				itemsNode.add_child(new_item)
	for i in range(32, width-36, 16):
		var rand = rng.randi_range(0, 10)
		if rand > 5:
			ysort.add_child(new_stone(i, 0))
			rand = rng.randi_range(0, 10)
			if rand > 3:
				var new_item = Item.instance()
				new_item.id = rng.randi_range(0, 3)
				new_item.position = Vector2(i, 0)
				itemsNode.add_child(new_item)
		rand = rng.randi_range(0, 10)
		if rand > 5:
			ysort.add_child(new_stone(i, height-16))
			rand = rng.randi_range(0, 10)
			if rand > 3:
				var new_item = Item.instance()
				new_item.id = rng.randi_range(0, 3)
				new_item.position = Vector2(i, height-16)
				itemsNode.add_child(new_item)


func _ready():
	Map.bomb_map.clear()
	timer.connect("timeout",self,"_emit_timer_end_signal")
	timer2.connect("timeout",self,"_emit_timer_end_signal2")
	timer3.connect("timeout",self,"_emit_timer_end_signal3")
	timer4.connect("timeout",self,"_emit_timer_end_signal4")
	rng.randomize()
	Map.reset()
	generate_stones()
	ai_player.id = 1
	ai_player2.id = 2
	ai_player3.id = 3
	main_player.connect("drop_bomb", self, "_drop_bomb")
	ai_player.connect("drop_bomb", self, "_drop_bomb")
	ai_player2.connect("drop_bomb", self, "_drop_bomb")
	ai_player3.connect("drop_bomb", self, "_drop_bomb")
	main_player.connect("die", self, "_on_die")
	ai_player.connect("die", self, "_on_die")
	ai_player2.connect("die", self, "_on_die")
	ai_player3.connect("die", self, "_on_die")
	for i in range(BLOCK_SIZE, height - 4, 32):
		for j in range(BLOCK_SIZE, width - 4, 32):
			ysort.add_child(new_block(j, i))

			
func _process(delta):
	time += delta
	var secs = fmod(time, 60)
	var mins = fmod(time, 60*60) / 60
	var time_passed = "%02d:%02d" % [mins, secs]
	fire_abi.text = "x%d" % Stats.fire_abi
	bomb_abi.text = "x%d" % Stats.bomb_abi
	shoes_abi.text = "x%d" % Stats.shoes_abi
	timeCounter.text = time_passed
	
	
func _on_die():
	if main_player.died:
		_lose_game()
		return
	if ai_player.died and ai_player2.died and ai_player3.died:
		win_game()
		return

	
func _drop_bomb(x, y, bomb_range, your_bomb, id):
	set_bomb_value(x, y, bomb_range)
	ai_player.is_drop_bomb()
	ai_player2.is_drop_bomb()
	ai_player3.is_drop_bomb()
	if your_bomb:
		Stats.decrease_bomb_num()
	else:
		AiStats.decrease_bomb_num(id)
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
	bomb.player_id = id
	bombs.add_child(bomb)
	bomb.collision.disabled = true
	bomb.connect("go_off", self, "_go_off")


func set_bomb_value(x, y, bomb_range):
	Map.bomb_map[int(x/BLOCK_SIZE)][int(y/BLOCK_SIZE)] += 1
	for i in range(1, bomb_range+1):
		var new_x = x + i*BLOCK_SIZE
		var new_y = y
		if invalid_position(new_x, new_y): 
			break
		if Map.check_is_stone(new_x, new_y):
			break
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0:
			Map.bomb_map[int(new_x/BLOCK_SIZE)][int(new_y/BLOCK_SIZE)] += 1
		else:
			break
	
	for i in range(1, bomb_range+1):
		var new_x = x - i*BLOCK_SIZE
		var new_y = y
		if invalid_position(new_x, new_y): 
			break
		if Map.check_is_stone(new_x, new_y):
			break
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2:
			Map.bomb_map[int(new_x/BLOCK_SIZE)][int(new_y/BLOCK_SIZE)] += 1
		else:
			break
		
	for i in range(1, bomb_range+1):
		var new_x = x
		var new_y = y + i*BLOCK_SIZE
		if invalid_position(new_x, new_y): 
			break
		if Map.check_is_stone(new_x, new_y):
			break
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2:
			Map.bomb_map[int(new_x/BLOCK_SIZE)][int(new_y/BLOCK_SIZE)] += 1
		else:
			break
		
	for i in range(1, bomb_range+1):
		var new_x = x
		var new_y = y - i*BLOCK_SIZE
		if invalid_position(new_x, new_y): 
			break
		if Map.check_is_stone(new_x, new_y):
			break
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2:
			Map.bomb_map[int(new_x/BLOCK_SIZE)][int(new_y/BLOCK_SIZE)] += 1
		else:
			break


func _go_off(x, y, bomb_range, your_bomb, id):
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
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 3:
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
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 3:
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
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 3:
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
		elif Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 0 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 2 or Map.get_map()[new_x/BLOCK_SIZE][new_y/BLOCK_SIZE] == 3:
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
		run_timer(0.8)
		yield(self, "timer_end")
	else:
		if id == 1:
			run_timer2(0.8)
			yield(self, "timer_end2")
		elif id == 2:
			run_timer2(0.8)
			yield(self, "timer_end2")
		elif id == 3:
			run_timer3(0.8)
			yield(self, "timer_end3")
	if your_bomb:
		Stats.increase_bomb_num()
	else:
		AiStats.increase_bomb_num(id)


func invalid_position(x, y):
	return x >= width or y >= height or x < 0 or y < 0


func _lose_game():
	dialog._set_caption("You lose!")
	dialog._set_info("You lose!")
	dialog._show_dialog()
	outGame.start()


func win_game():
	dialog._set_caption("You win!")
	dialog._set_info("You win!")
	dialog._show_dialog()
	outGame.start()


func _on_OutGame_timeout():
	get_tree().change_scene("res://scenes/Menu.tscn")
