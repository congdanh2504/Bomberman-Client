extends StaticBody2D


onready var sprite = $Sprite
onready var collision = $CollisionShape2D

func _ready():
	sprite.play("idle")
	sprite.stop()


func _on_Sprite_animation_finished():
	queue_free()


func destroy():
	collision.disabled = true
	sprite.play("destroy")
