extends KinematicBody2D

const width = Constant.width
const height = Constant.height
const BLOCK_SIZE = Constant.BLOCK_SIZE
export var id = 0
var username
var direction = "Down"
var died = false
var active = true
var is_ai = false
var active2 = false
signal drop_bomb(x, y, bomb_range, bomb_type, id)
signal lose_game

func _ready():
	$AnimatedSprite.animation = "idle%s_%s" % [direction, id]


func _process(delta):
	if active:
		movement()	


func die():
	Map.players_x[id] = -1
	Map.players_y[id] = -1
	died = true
	$AnimatedSprite.play("die_%s" % id)
	active = false


func client_play(animation):
	$AnimatedSprite.animation = animation
	
func movement():
	var velocity = Vector2.ZERO
	var map = Map.get_map()
	if Input.is_action_just_pressed("drop_bomb"):
		if Stats.get_bomb_num() > 0:
			emit_signal("drop_bomb", position.x, position.y, Stats.get_bomb_range(), true, id)
			
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
		"res://scripts/MainPlayer.gd"
	velocity = move_and_slide(velocity)
	position.x = clamp(position.x, 0, width - 14)
	position.y = clamp(position.y, 0, height - 14)
	Map.players_x[id] = int(position.x/BLOCK_SIZE)
	Map.players_y[id] = int(position.y/BLOCK_SIZE)


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "die_%s" % id and active2:
		queue_free()
		emit_signal("lose_game")
	pass
