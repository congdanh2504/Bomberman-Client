extends StaticBody2D

onready var animation = $Sprite
onready var collision = $CollisionShape2D
onready var goOff = $GoOffTimer
onready var colli = $ColliTimer
var bomb_range = 2
var your_bomb = false
signal go_off(x, y, bomb_range)


func _ready():
	animation.play("idle")
	goOff.start()


func _on_GoOffTimer_timeout():
	emit_signal("go_off", position.x, position.y, bomb_range, your_bomb)
	queue_free()
