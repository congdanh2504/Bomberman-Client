extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_AnimatedSprite_animation_finished():
	queue_free()


func _on_Area2D_body_entered(body):
	if body is KinematicBody2D:
		body.die()
