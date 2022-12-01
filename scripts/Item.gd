extends AnimatedSprite


var id = 0

func _ready():
	if id == 0:
		play("bomb")
	elif id == 1:
		play("fire")
	else:
		play("speed")


func _on_Area2D_body_entered(body):
	if body.active:
		if id == 0:
			Stats.bomb_abi += 1
			Stats.increase_bomb_num()
		elif id == 1:
			Stats.fire_abi += 1
			Stats.increase_bomb_range()
		else:
			Stats.shoes_abi += 1
			Stats.increase_speed()
	elif body.is_ai:
		if id == 0:
			pass
#			AiStats.increase_bomb_num(body.id)
		elif id == 1:
			AiStats.increase_bomb_range(body.id)
		else:
			AiStats.increase_speed(body.id)
	queue_free()
