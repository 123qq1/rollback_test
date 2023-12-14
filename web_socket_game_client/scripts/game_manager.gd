extends Node

signal start(p_1)
signal step(delta)
signal rollback(state,string)

enum states {IDLE,SEARCHING,CONNECTING,CONFIRMING,STARTING,PLAYING}

var state = states.IDLE
var first_playing = true
var p_1
var game_time = 0
var other
var con_name
var id

var p_1_time = 0
var p_2_time = 0

func setup_players(_p_1):
	p_1 = _p_1


func _ready():
	state = states.SEARCHING
	WebSocketManager.recived_message.connect(handle)
	con_name = WebSocketManager.get_con_name()
	id = WebSocketManager.get_id()
	
func handle(message):
	
	match message.type:
		"searching":
			if state != states.SEARCHING:
				return
			state = states.CONNECTING
			other = message.name
			WebSocketManager.change_message('"type":"connecting","other":"'+other+'","id":"'+id+'"')
			WebSocketManager.send_message()
	
		"connecting":
			if message.other != con_name:
				return
			if ![states.CONNECTING,states.SEARCHING].has(state):
				return
			state = states.CONFIRMING
			other = message.name
			setup_players(message.id > id)
			WebSocketManager.change_message('"type":"confirming","other":"'+other+'","id":"'+id+'"')
			WebSocketManager.send_message()
		"confirming":
			if message.other != con_name:
				return		
			if ![states.CONNECTING,states.CONFIRMING].has(state):
				return
			setup_players(message.id > id)
			state = states.STARTING
			if !p_1:
				WebSocketManager.change_message('"type":"confirmed","other":"'+other+'","id":"'+id+'"')
				WebSocketManager.send_message()
		"starting":
			if p_1:
				return
			if message.other != con_name:
				return
			state = states.PLAYING
		"confirmed":
			if !p_1:
				return
			if message.other != con_name:
				return
			state = states.STARTING
		"state":
			if message.other != con_name:
				return
			if state != states.PLAYING:
				return
			rollback.emit(message.state,JSON.stringify(message.state))
func _physics_process(delta):
	if state != states.PLAYING:
		print("%s : %s : %s : %s" % [con_name,states.keys()[state],p_1,other])
	match state:
		states.IDLE:
			pass
		states.SEARCHING:
			WebSocketManager.change_message('"type":"searching"')
			WebSocketManager.send_message()
		states.CONNECTING:
			pass
		states.CONFIRMING:
			pass
		states.STARTING:
			if !p_1:
				return
			WebSocketManager.change_message('"type":"starting","other":"'+other+'"')
			WebSocketManager.send_message()
			state = states.PLAYING
		states.PLAYING:
			playing(delta)

func set_p_1_state(game_state,time):
	p_1_time = time
	print("update time p_1: %s" % time)
	if !p_1:
		WebSocketManager.change_message('"type":"state","other":"'+other+'","state":%s'%[game_state])
		WebSocketManager.send_message()
	
func set_p_2_state(game_state,time):
	p_2_time = time
	print("update time p_2: %s" % time)
	if p_1:
		WebSocketManager.change_message('"type":"state","other":"'+other+'","state":%s'%[game_state])
		WebSocketManager.send_message()

func playing(delta):
	#Game logic
	if first_playing:
		print("%s Sending Setup" % con_name)
		start.emit(p_1)
		first_playing = false
		
	if game_time == p_1_time && game_time == p_2_time:
		print("Step : %s , %s" % [p_1_time,p_2_time])
		step.emit(delta)
		game_time += 1
