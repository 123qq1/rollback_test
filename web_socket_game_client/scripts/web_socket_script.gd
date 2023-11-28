extends Node

signal recived_message(json_obj)

var web_socket_url = "ws://localhost:41000/api/ws"
var connected = false
var cur_message

var _client = WebSocketPeer.new()
var con_name = "test"

var connections = {}
var beat = 0
var heart_rate = 1.0

func connect_to_ws():
	_client.connect_to_url(web_socket_url+"?name="+con_name)
	connected = true
	
func change_name(new_text):
	con_name = new_text
	
func change_url(new_url):
	web_socket_url = new_url
	
func _process(_delta):	
	if !connected: 
		return
	handle_connection()
	heart_beat(_delta)
	
func heart_beat(d):
	beat += d
	if beat > heart_rate:
		for con in connections.keys():
			connections[con] += 1
		change_message('{"name":"'+con_name+'","ping":true}')
		send_message()
	beat = fmod(beat,heart_rate)
	
func handle_connection():
	_client.poll()
	var state = _client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while _client.get_available_packet_count():
			var packet = _client.get_packet().get_string_from_utf8()
			var json_string = packet.get_slice("|",1)
			var obj = JSON.parse_string(json_string)
			connection_pulse(obj.name)
			recived_message.emit(obj)
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = _client.get_close_code()
		var reason = _client.get_close_reason()
		recived_message.emit("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		
func change_message(text):
	cur_message = text
	
func connection_pulse(name):
	if name == con_name:
		return
	connections[name] = 0
	recived_message.emit(connections)
	
func close_connection():
	change_message('{"name":"'+con_name+'","disconect":true}')
	send_message()
	_client.close()
	recived_message.emit("Disconnected")
	connected = false
		
func send_message():
	_client.send_text("|" + cur_message + "|")
