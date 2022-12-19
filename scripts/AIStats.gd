extends Node


var bomb_range = [-1, 2, 2, 2]
var bomb_num = [-1 ,1, 1, 1]
var speed = [-1 ,80, 80, 80]


func reset():
	bomb_range = [-1, 2, 2, 2]
	bomb_num = [-1 ,1, 1, 1]
	speed = [-1 ,80, 80, 80]

func get_bomb_range(id):
	return bomb_range[id]

func increase_bomb_range(id):
	bomb_range[id] += 1

func get_bomb_num(id):
	return bomb_num[id]

func decrease_bomb_num(id):
	bomb_num[id] -= 1

func increase_bomb_num(id):
	bomb_num[id] += 1

func get_speed(id):
	return speed[id]
	
func increase_speed(id):
	speed[id] += 5

