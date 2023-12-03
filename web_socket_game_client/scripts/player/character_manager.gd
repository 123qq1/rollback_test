extends CharacterBody2D

enum states {IDLE,MOVING,BLOCKING,BLOCK_STUN,HIT_STUN,ATTACKING}

@export var mov_speed = Vector2(30,0)
var cur_state
var dir
var animator

func _ready():
	animator = get_node("AnimatedSprite2D")

func _process(delta):
	match cur_state:
		states.IDLE:
			if animator.animation != "Idle":
				animator.play("Idle")
		states.MOVING:
			if animator.animation != "MoveRight":
				animator.play("MoveRight")
			if position.x < 500 && dir > 0:
				position += dir * mov_speed * delta
			elif position.x > -500 && dir < 0:
				position += dir * mov_speed * delta
			else:
				cur_state = states.IDLE
	
func move(_dir):
	dir = _dir
	cur_state = states.MOVING
	
	
func stop_moving():
	dir = 0
	cur_state = states.IDLE

func attack():
	cur_state = states.ATTACKING
