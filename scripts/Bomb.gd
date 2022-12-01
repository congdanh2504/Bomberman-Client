extends StaticBody2D

onready var animation = $Sprite
onready var collision = $CollisionShape2D
onready var goOff = $GoOffTimer
onready var colli = $ColliTimer
var bomb_range = 2
var your_bomb = false
var player_id = -1
signal go_off(x, y, bomb_range, player_id)


func _ready():
	animation.play("idle")
	goOff.start()


func _on_GoOffTimer_timeout():
	emit_signal("go_off", position.x, position.y, bomb_range, your_bomb, player_id)
	call_deferred("free")
