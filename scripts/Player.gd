extends KinematicBody2D

export var speed = 80
var screen_size
export var id = 0
var direction = "Down"
export var active = false

func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite.animation = "idle%s_%s" % [direction, id]
	
func _process(delta):
	if active:
		movement()
	pass	
	
func update_pos(x, y):
	position = Vector2(x, y)
	
func client_play(animation):
	$AnimatedSprite.animation = animation
	
func movement():
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		$AnimatedSprite.animation = "runRight_%s" % id
		direction = "Right"
	elif Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		$AnimatedSprite.animation = "runLeft_%s" % id
		direction = "Left"
	elif Input.is_action_pressed("ui_down"):
		velocity.y += 1
		$AnimatedSprite.animation = "runDown_%s" % id
		direction = "Down"
	elif Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		$AnimatedSprite.animation = "runUp_%s" % id
		direction = "Up"

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	else:
		$AnimatedSprite.animation = "idle%s_%s" % [direction, id]
		
	velocity = move_and_slide(velocity)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	Networking.update_pos(id, position.x, position.y, $AnimatedSprite.animation, Global.get_roomname())