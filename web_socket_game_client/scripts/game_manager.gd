extends Node

signal start(p_1)

enum states {IDLE,SEARCHING,CONNECTING,CONFIRMING,STARTING,PLAYING}

var state = states.IDLE
var p_1
var game_time = 0
var other
var con_name
var id

func _ready():
	state = states.SEARCHING
	WebSocketManager.recived_message.connect(handle)
	con_name = WebSocketManager.get_con_name()
	id = WebSocketManager.get_id()
	print(id)
	
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
			p_1 = message.id > id
			WebSocketManager.change_message('"type":"confirming","other":"'+other+'","id":"'+id+'"')
			WebSocketManager.send_message()
		"confirming":
			if message.other != con_name:
				return		
			if state != states.CONNECTING:
				return
			p_1 = message.id > id
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
			state = states.PLAYING
			
func _process(_delta):
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
			
