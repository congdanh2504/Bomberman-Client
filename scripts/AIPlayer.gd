extends KinematicBody2D

const width = Constant.width
const height = Constant.height
const BLOCK_SIZE = Constant.BLOCK_SIZE
export var id = 0
var direction = "Down"
var actions = []
var active = false
var is_ai = true
var is_drop = false
var bomb_num = 1
var bomb_range = 2
var speed = 80

var x_moves = [0, 0, -1, 1]
var y_moves = [-1, 1, 0, 0]
signal drop_bomb(x, y, bomb_range, bomb_type, id)
signal die
var died = false

func die():
	emit_signal("die")
	Map.players_x[id] = -1
	Map.players_y[id] = -1
	died = true
	$AnimatedSprite.play("die_%s" % id)
	

func find_and_drop_bomb(x, y):
	var visited = []
	var par = []
	for i in range(width/BLOCK_SIZE):
		visited.append([])
		par.append([])
		for j in range(height/BLOCK_SIZE):
			visited[i].append(0)
			par[i].append(0)
	visited[x][y] = 1
	var queue = []
	par[x][y] = -1
	queue.append([x, y])
	var x_result = -1
	var y_result = -1
	while queue:
		var flag = false
		var front = queue.pop_front()
		
		for i in range(4):
			var new_x = front[0] + x_moves[i]
			var new_y = front[1] + y_moves[i]
			if new_x >= width/BLOCK_SIZE or new_x < 0 or new_y >= height/BLOCK_SIZE or new_y < 0:
				continue
			
			if Map.check_is_stone(new_x*BLOCK_SIZE, new_y*BLOCK_SIZE):
				x_result = front[0]
				y_result = front[1]
				flag = true
				break
				
			for j in range(4):
				if j == id:
					continue
				
				if Map.players_x[j] == -1:
					continue
				
				if Map.players_x[j] == front[0] and Map.players_y[j] == front[1]:
					x_result = front[0]
					y_result = front[1]
					flag = true
					break
					
			if flag:
				break
				
		if flag:
			break
		
		if id == 2:
			var index = 1
			for i in range(4):
				index += 1
				if index == 4:
					index = 0
				var new_x = front[0] + x_moves[index]
				var new_y = front[1] + y_moves[index]
				if new_x >= width/BLOCK_SIZE or new_x < 0 or new_y >= height/BLOCK_SIZE or new_y < 0:
					continue
				if Map.check_is_stone(new_x*BLOCK_SIZE, new_y*BLOCK_SIZE) or Map.get_map()[new_x][new_y] == 2:
					continue
				if Map.bomb_map[new_x][new_y] != 0:
					continue
					
				if visited[new_x][new_y] == 0 and Map.get_map()[new_x][new_y] == 0:
					queue.append([new_x, new_y])
					par[new_x][new_y] = index
					visited[new_x][new_y] = 1
		elif id % 2 == 0:
			for i in range(4):
				var new_x = front[0] + x_moves[i]
				var new_y = front[1] + y_moves[i]
				if new_x >= width/BLOCK_SIZE or new_x < 0 or new_y >= height/BLOCK_SIZE or new_y < 0:
					continue
				if Map.check_is_stone(new_x*BLOCK_SIZE, new_y*BLOCK_SIZE) or Map.get_map()[new_x][new_y] == 2:
					continue
				if Map.bomb_map[new_x][new_y] != 0:
					continue
					
				if visited[new_x][new_y] == 0 and Map.get_map()[new_x][new_y] == 0:
					queue.append([new_x, new_y])
					par[new_x][new_y] = i
					visited[new_x][new_y] = 1
		else:
			for i in range(3, -1, -1):
				var new_x = front[0] + x_moves[i]
				var new_y = front[1] + y_moves[i]
				if new_x >= width/BLOCK_SIZE or new_x < 0 or new_y >= height/BLOCK_SIZE or new_y < 0:
					continue
				if Map.check_is_stone(new_x*BLOCK_SIZE, new_y*BLOCK_SIZE) or Map.get_map()[new_x][new_y] == 2:
					continue
				if Map.bomb_map[new_x][new_y] != 0:
					continue
					
				if visited[new_x][new_y] == 0 and Map.get_map()[new_x][new_y] == 0:
					queue.append([new_x, new_y])
					par[new_x][new_y] = i
					visited[new_x][new_y] = 1
	
	if x_result != -1:
		var moves = []
		while par[x_result][y_result] != -1:
			if par[x_result][y_result] == 0:
				moves.append(new_action("Up"))
			elif par[x_result][y_result] == 1:
				moves.append(new_action("Down"))
			elif par[x_result][y_result] == 2:
				moves.append(new_action("Left"))
			elif par[x_result][y_result] == 3:
				moves.append(new_action("Right"))
			var x_temp = x_result - x_moves[par[x_result][y_result]]
			var y_temp = y_result - y_moves[par[x_result][y_result]]
			x_result = x_temp
			y_result = y_temp
		for move in moves:
			actions.push_front(move)
		actions.push_back(new_action("drop_bomb", 1))


func is_drop_bomb():
	var x = int(position.x/BLOCK_SIZE)
	var y = int(position.y/BLOCK_SIZE)
	if Map.bomb_map[x][y] > 0:
		if actions.size() > 0:
			var front = actions[0]	
			if front["direction"] != "drop_bomb":
				actions.clear()
				var x2 = position.x
				var y2 = position.y
				if front["direction"] == "Up":
					y2 -= front["step"]
				elif front["direction"] == "Down":
					y2 += front["step"]
				elif front["direction"] == "Left":
					x2 -= front["step"]
				elif front["direction"] == "Right":
					x2 += front["step"]
				find_safe_position(int(x2/BLOCK_SIZE), int(y2/BLOCK_SIZE))
				actions.push_front(front)
		else:
			find_safe_position(int(position.x/BLOCK_SIZE), int(position.y/BLOCK_SIZE))	


func find_safe_position(x, y):
	var visited = []
	var par = []
	for i in range(width/BLOCK_SIZE):
		visited.append([])
		par.append([])
		for j in range(height/BLOCK_SIZE):
			visited[i].append(0)
			par[i].append(0)
	visited[x][y] = 1
	var queue = []
	par[x][y] = -1
	queue.append([x, y])
	var x_result = -1
	var y_result = -1
	while queue:
		var front = queue.pop_front()
		if Map.get_map()[front[0]][front[1]] == 0 and Map.bomb_map[front[0]][front[1]] == 0:
			x_result = front[0]
			y_result = front[1]
			break
		
		if id == 2:
			var index = 1
			for i in range(4):
				index += 1
				if index == 4:
					index = 0
				var new_x = front[0] + x_moves[index]
				var new_y = front[1] + y_moves[index]
				if new_x >= width/BLOCK_SIZE or new_x < 0 or new_y >= height/BLOCK_SIZE or new_y < 0:
					continue
				if Map.bomb_map[front[0]][front[1]] == 0 and Map.bomb_map[new_x][new_y] != 0:
					continue
				if Map.check_is_stone(new_x*BLOCK_SIZE, new_y*BLOCK_SIZE) or Map.get_map()[new_x][new_y] == 2:
					continue
				if visited[new_x][new_y] == 0 and Map.get_map()[new_x][new_y] == 0:
					queue.append([new_x, new_y])
					par[new_x][new_y] = index
					visited[new_x][new_y] = 1
		elif id % 2 == 0:
			for i in range(4):
				var new_x = front[0] + x_moves[i]
				var new_y = front[1] + y_moves[i]
				if new_x >= width/BLOCK_SIZE or new_x < 0 or new_y >= height/BLOCK_SIZE or new_y < 0:
					continue
				if Map.bomb_map[front[0]][front[1]] == 0 and Map.bomb_map[new_x][new_y] != 0:
					continue
				if Map.check_is_stone(new_x*BLOCK_SIZE, new_y*BLOCK_SIZE) or Map.get_map()[new_x][new_y] == 2:
					continue
				if visited[new_x][new_y] == 0 and Map.get_map()[new_x][new_y] == 0:
					queue.append([new_x, new_y])
					par[new_x][new_y] = i
					visited[new_x][new_y] = 1
		else:
			for i in range(3, -1, -1):
				var new_x = front[0] + x_moves[i]
				var new_y = front[1] + y_moves[i]
				if new_x >= width/BLOCK_SIZE or new_x < 0 or new_y >= height/BLOCK_SIZE or new_y < 0:
					continue
				if Map.bomb_map[front[0]][front[1]] == 0 and Map.bomb_map[new_x][new_y] != 0:
					continue
				if Map.check_is_stone(new_x*BLOCK_SIZE, new_y*BLOCK_SIZE) or Map.get_map()[new_x][new_y] == 2:
					continue
				if visited[new_x][new_y] == 0 and Map.get_map()[new_x][new_y] == 0:
					queue.append([new_x, new_y])
					par[new_x][new_y] = i
					visited[new_x][new_y] = 1
	
	if x_result != -1:
		var moves = []
		while par[x_result][y_result] != -1:
			if par[x_result][y_result] == 0:
				moves.append(new_action("Up"))
			elif par[x_result][y_result] == 1:
				moves.append(new_action("Down"))
			elif par[x_result][y_result] == 2:
				moves.append(new_action("Left"))
			elif par[x_result][y_result] == 3:
				moves.append(new_action("Right"))
			var x_temp = x_result - x_moves[par[x_result][y_result]]
			var y_temp = y_result - y_moves[par[x_result][y_result]]
			x_result = x_temp
			y_result = y_temp
		for move in moves:
			actions.push_front(move)


func new_action(direction, step=16):
	return {
		"direction": direction,
		"step": step
	}


func _ready():
	$AnimatedSprite.animation = "idle%s_%s" % [direction, id]


func is_safe():
	var x = int(position.x/BLOCK_SIZE)
	var y = int(position.y/BLOCK_SIZE)
	return Map.bomb_map[x][y] > 0


func _process(delta):
	if !died:
		if len(actions) > 0:
			var velocity = Vector2.ZERO
			var front = actions[0]
			if front["direction"] == "Down":
				velocity.y += 1
				$AnimatedSprite.animation = "runDown_%s" % id
				direction = "Down"
			elif front["direction"] == "Up":
				velocity.y -= 1
				$AnimatedSprite.animation = "runUp_%s" % id
				direction = "Up"
			elif front["direction"] == "Left":
				velocity.x -= 1
				$AnimatedSprite.animation = "runLeft_%s" % id
				direction = "Left"
			elif front["direction"] == "Right":
				velocity.x += 1
				$AnimatedSprite.animation = "runRight_%s" % id
				direction = "Right"
			elif front["direction"] == "drop_bomb":
				actions.pop_front()
				emit_signal("drop_bomb", position.x, position.y, AiStats.get_bomb_range(id), false, id)
				return
			velocity = move_and_collide(velocity)
			actions[0]['step'] -= 1
			if actions[0]['step'] <= 0:
				actions.pop_front()
			position.x = clamp(position.x, 0, width - 14)
			position.y = clamp(position.y, 0, height - 14)
			Map.players_x[id] = int(position.x/BLOCK_SIZE)
			Map.players_y[id] = int(position.y/BLOCK_SIZE)
		elif AiStats.get_bomb_num(id) > 0:
			find_and_drop_bomb(int(position.x/BLOCK_SIZE), int(position.y/BLOCK_SIZE))
		else:
			$AnimatedSprite.animation = "idle%s_%s" % [direction, id]
