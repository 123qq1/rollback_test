extends RichTextLabel

func recive_text(r_text):
	add_text(r_text + "\n")
	
func _ready():
	WebSocketManager.recived_message.connect(recive_text)
