extends Node

signal recived_message(text)

var web_socket_url = "ws://localhost:41000/api/ws"
var connected = false
var cur_message

var _client = WebSocketPeer.new()
var con_name = "test"

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
	
	_client.poll()
	var state = _client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while _client.get_available_packet_count():
			var packet = _client.get_packet().get_string_from_utf8()
			recived_message.emit(packet)
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = _client.get_close_code()
		var reason = _client.get_close_reason()
		recived_message.emit("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.
		
func change_message(text):
	cur_message = text
	print(cur_message)
	
func close_connection():
	_client.close()
	recived_message.emit("Disconnected")
	connected = false
		
func send_message():
	print(cur_message)
	_client.send_text(cur_message)
