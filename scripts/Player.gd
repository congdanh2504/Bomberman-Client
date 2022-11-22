extends KinematicBody2D

export var speed = 80
const width = Constant.width
const height = Constant.height
export var id = 0
var username
var direction = "Down"
var died = false
export var active = false setget set_active
var active2 = false
signal drop_bomb(x, y)
signal lose_game

func _ready():
	$AnimatedSprite.animation = "idle%s_%s" % [direction, id]
	
func set_active(value):
	active = value
	active2 = value
	
func _process(delta):
	if active and not Global.get_is_chatting():
		movement()
	pass	
	
func die():
	died = true
	$AnimatedSprite.play("die_%s" % id)
	active = false
	
func update_pos(x, y):
	position = Vector2(x, y)
	
func client_play(animation):
	$AnimatedSprite.animation = animation
	
func movement():
	var velocity = Vector2.ZERO
	var map = Map.get_map()
	if Input.is_action_just_pressed("drop_bomb"):
		if Stats.get_bomb_num() > 0:
			Stats.decrease_bomb_num()
			Networking.drop_bomb(position.x, position.y, Stats.get_bomb_range(), username)
			
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
		velocity = velocity.normalized() * Stats.get_speed()
	else:
		$AnimatedSprite.animation = "idle%s_%s" % [direction, id]
		
	velocity = move_and_slide(velocity)
	position.x = clamp(position.x, 0, width - 14)
	position.y = clamp(position.y, 0, height - 14)

	Networking.update_pos(username, position.x, position.y, $AnimatedSprite.animation, Global.get_roomname())


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "die_%s" % id and active2:
		queue_free()
		emit_signal("lose_game")
	pass
