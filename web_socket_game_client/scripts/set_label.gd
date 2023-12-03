extends Label

func _ready():
	WebSocketManager.on_ping.connect(set_text)
