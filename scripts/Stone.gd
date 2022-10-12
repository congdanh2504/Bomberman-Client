extends StaticBody2D


onready var sprite = $Sprite

func _ready():
	sprite.play("idle")
	sprite.stop()

func _on_Sprite_animation_finished():
	queue_free()

func destroy():
	sprite.play("destroy")
