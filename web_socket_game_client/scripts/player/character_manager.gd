extends CharacterBody2D

enum states {IDLE,MOVING,BLOCKING,BLOCK_STUN,HIT_STUN,ATTACKING}

signal found_next_state(state,time)

@export var mov_speed = Vector2(30,0)
var cur_state
var dir
var animator
var p_1
var is_ai
var state_history = []
var time = 0

func _ready():
	_setup()
	
func set_p_1(_p_1):
	p_1 = _p_1
	
func set_is_ai(_is_ai):
	is_ai = _is_ai
	
func _setup():
	animator = get_node("AnimatedSprite2D")
	

func step(delta):
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
	find_next_state(delta)
	time += 1
	
func find_next_state(delta):
	var state
	if is_ai:
		state = ai_state(delta)
	else:
		state = player_state(delta)
	found_next_state.emit(state,time)
	state_history.append(state)
	
func player_state(delta):
	var state = '{"state": %s,"pos_x": %s,"pos_y": %s,"dir": %s,"delta": %s,"time": %s}' % [cur_state,position.x,position.y,dir,delta,time]
	return state

func ai_state(delta):
	var state
	if state_history.size() == 0:
		state = '{"state": %s,"pos_x": %s,"pos_y": %s,"dir": %s,"delta": %s,"time": %s}' % [cur_state,position.x,position.y,dir,delta,time]
	else:
		var old_state_string = state_history[time-1]
		var old_state = JSON.parse_string(old_state_string)
		state = '{"state": %s,"pos_x": %s,"pos_y": %s,"dir": %s,"delta": %s,"time": %s}' % [old_state.state,position.x,position.y,old_state.dir,old_state.delta,time]
	return state


func apply_state(state):
	cur_state = states[state.state]
	dir = state.dir
	time = state.time
	position.x = state.pos_x
	position.y = state.pos_y

func move(_dir):
	dir = _dir
	cur_state = states.MOVING
	
	
func stop_moving():
	dir = 0
	cur_state = states.IDLE

func attack():
	cur_state = states.ATTACKING
