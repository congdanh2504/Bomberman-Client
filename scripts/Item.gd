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
			Stats.increase_bomb_num()
		elif id == 1:
			Stats.increase_bomb_range()
		else:
			Stats.increase_speed()
	queue_free()
