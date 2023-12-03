extends Node

signal recived_message(json_obj)
signal on_connected()
signal on_disconnected()
signal on_ping(ping)

var web_socket_url = "ws://localhost:41000/api/ws"
var connected = false
var cur_message
var ping = 0
var pinged = false

var _client = WebSocketPeer.new()
var con_name = "test"

var connections = {}
var beat = 0
var heart_rate = 1.0

func connect_to_ws():
	_client.connect_to_url(web_socket_url+"?name="+con_name)
	connected = true
	on_connected.emit()
	
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
	ping += int(d * 1000)
	if beat > heart_rate:
		for con in connections.keys():
			connections[con] += 1
		if !pinged:
			change_message('"type":"ping"')
			send_message()
			ping = 0
			pinged = true
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
			if obj.name != con_name:
				recived_message.emit(obj)
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = _client.get_close_code()
		var reason = _client.get_close_reason()
		recived_message.emit("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		
func change_message(text):
	cur_message = '{"name":"'+con_name+'",'+text+'}'
	
func connection_pulse(pulse_name):
	if pulse_name == con_name:
		if pinged:
			on_ping.emit(str(ping))
			pinged = false
		return
	connections[pulse_name] = 0
	
func close_connection():
	change_message('"type":"disconnect"')
	send_message()
	_client.close()
	recived_message.emit("Disconnected")
	connected = false
	on_disconnected.emit()
		
func send_message():
	_client.send_text("|" + cur_message + "|")

func get_con_name():
	return con_name
