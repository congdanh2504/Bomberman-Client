extends Node

var map = []
var mapStone = []
var width = 624
var height = 304
var BLOCK_SIZE = 16

func _ready():
	reset()

func reset():
	mapStone = []
	for i in range(width/BLOCK_SIZE):
		mapStone.append([])
		for j in range(height/BLOCK_SIZE):
			mapStone[i].append(null)
	map = []
	for i in range(width/BLOCK_SIZE):
		map.append([])
		for j in range(height/BLOCK_SIZE):
			map[i].append(0)

func get_map():
	return map
	
func get_map_stone():
	return mapStone
	

func check_is_stone(x, y):
	return map[x/BLOCK_SIZE][y/BLOCK_SIZE] == 2 and is_instance_valid(mapStone[x/BLOCK_SIZE][y/BLOCK_SIZE])

	
func set_value_stone(x, y, v):
	mapStone[x][y] = v
	
func set_value(x, y, v):
	map[x][y] = v
