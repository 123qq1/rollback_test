extends Node

signal start(p_1)
signal step(delta)

enum states {IDLE,SEARCHING,CONNECTING,CONFIRMING,STARTING,PLAYING}

var state = states.IDLE
var first_playing = true
var p_1
var game_time = 0
var other
var con_name
var id

var player_1_history
var player_2_history

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
			
func playing(delta):
	#Game logic
	if first_playing:
		print("%s Sending Setup" % con_name)
		start.emit(p_1)
		first_playing = false
	step.emit(delta)
	game_time += 1
