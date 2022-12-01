extends AnimatedSprite


var BLOCK_SIZE = Constant.BLOCK_SIZE


func _on_AnimatedSprite_animation_finished():
	var x = int(position.x/BLOCK_SIZE)
	var y = int(position.y/BLOCK_SIZE)
	if Map.bomb_map[x][y] > 0:
		Map.bomb_map[x][y] -= 1
	queue_free()


func _on_Area2D_body_entered(body):
	if body is KinematicBody2D:
		body.die()
