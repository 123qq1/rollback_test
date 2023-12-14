extends CharacterBody2D

enum states {IDLE,MOVING,BLOCKING,BLOCK_STUN,HIT_STUN,ATTACKING}

signal found_next_state(state,time)

@export var mov_speed = Vector2(30,0)
var cur_state = states.IDLE
var dir = 0
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
	var state
	state = find_next_state(delta)
	state_history.append(state)
	print("time ++ %s"% [is_ai])
	time += 1
	found_next_state.emit(state,time)
	
func find_next_state(delta):
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
				
	if is_ai:
		return ai_state(delta)
	else:
		return player_state(delta)


	
func player_state(delta):
	var state = '{"delta":%s,"dir":%s,"pos_x":%s,"pos_y":%s,"state":%s,"time":%s}' % [delta,dir,position.x,position.y,cur_state,time]
	return state

func ai_state(delta):
	var state
	print("finding state %s ,%s" % [time,is_ai])
	if state_history.size() == 0:
		state = '{"delta":%s,"dir":%s,"pos_x":%s,"pos_y":%s,"state":%s,"time":%s}' % [delta,dir,position.x,position.y,cur_state,time]
	else:
		var old_state_string = state_history[time-1]
		var old_state = JSON.parse_string(old_state_string)
		state = '{"delta":%s,"dir":%s,"pos_x":%s,"pos_y":%s,"state":%s,"time":%s}' % [old_state.delta,old_state.dir,position.x,position.y,old_state.state,time]
	return state

func roll_back(state,string):
	if !is_ai:
		return
	var old_string =  state_history[state.time]
	print("Old %s : New %s" % [old_string,string])
	if string == old_string:
		return
	print("Rollback %s" % [is_ai])
	var new_time = state.time
	var cur_time = time
	
	apply_state(state)
	
	for i in range(new_time,cur_time):
		var old_state = JSON.parse_string(state_history[i])
		var delta = old_state.delta
		var new_state = find_next_state(delta)
		state_history[i] = new_state 

func apply_state(state):
	cur_state = state.state
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
