extends Node


var bomb_range = 2
var bomb_num = 1
var speed = 80

func _ready():
	pass # Replace with function body.
	
func reset():
	bomb_range = 2
	bomb_num = 1
	speed = 80

func get_bomb_range():
	return bomb_range
	
func increase_bomb_range():
	bomb_range += 1
	
func get_bomb_num():
	return bomb_num
	
func decrease_bomb_num():
	bomb_num -= 1

func increase_bomb_num():
	bomb_num += 1

func get_speed():
	return speed
	
func increase_speed():
	speed += 4
