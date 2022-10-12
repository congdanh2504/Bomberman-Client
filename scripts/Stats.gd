extends Node


var bomb_range = 2
var bomb_num = 2

func _ready():
	pass # Replace with function body.

func get_bomb_range():
	return bomb_range
	
func set_bomb_range(value):
	bomb_range = value
	
func get_bomb_num():
	return bomb_num
	
func decrease_bomb_num():
	bomb_num -= 1

func increase_bomb_num():
	bomb_num += 1
