extends StaticBody2D

onready var animation = $Sprite
onready var collision = $CollisionShape2D
onready var goOff = $GoOffTimer
onready var colli = $ColliTimer
signal go_off(x, y)


func _ready():
	collision.disabled = true
	animation.play("idle")
	goOff.start()
	colli.start()


func _on_GoOffTimer_timeout():
	emit_signal("go_off", position.x, position.y)
	Stats.increase_bomb_num()
	queue_free()


func _on_ColliTimer_timeout():
	collision.disabled = false
