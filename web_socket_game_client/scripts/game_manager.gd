extends Node

signal start(p_1)

enum states {IDLE,SEARCHING,CONNECTING,CONFIRMING,STARTING,PLAYING}

var state = states.IDLE
var p_1
var game_time = 0
var other
var con_name

func _ready():
	state = states.SEARCHING
	WebSocketManager.recived_message.connect(handle)
	con_name = WebSocketManager.get_con_name()
	
func handle(message):
	
	match message.type:
		"searching":
			if state != states.SEARCHING:
				return
			state = states.CONNECTING
			other = message.name
		"connecting":
			if message.other != con_name:
				return
			if ![states.CONNECTING,states.SEARCHING].has(state):
				return
			state = states.CONFIRMING
			other = message.name
			p_1 = !message.p_1
		"confirming":
			if message.other != con_name:
				return
			if state != states.CONNECTING:
				return
			state = states.STARTING
	
func _process(delta):
	print(con_name+" : "+str(state))
	match state:
		states.IDLE:
			pass
		states.SEARCHING:
			WebSocketManager.change_message('"type":"searching"')
			WebSocketManager.send_message()
		states.CONNECTING:
			WebSocketManager.change_message('"type":"connecting","other":"'+other+'","p_1":true')
			WebSocketManager.send_message()
		states.CONFIRMING:
			WebSocketManager.change_message('"type":"confirming","other":"'+other+'"')
			WebSocketManager.send_message()
