extends Node

var map = []
var mapStone = []

func _ready():
	reset()

func reset():
	mapStone = []
	for i in range(19):
		mapStone.append([])
		for j in range(19):
			mapStone[i].append(0)
	map = []
	for i in range(19):
		map.append([])
		for j in range(19):
			map[i].append(0)

func get_map():
	return map
	
func get_map_stone():
	return mapStone
	
func set_value_stone(x, y, v):
	mapStone[x][y] = v
	
func set_value(x, y, v):
	map[x][y] = v
