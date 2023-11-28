extends RichTextLabel

func recive_text(json_obj):
	var r_text = JSON.stringify(json_obj)
	add_text(r_text + "\n")
	
func _ready():
	WebSocketManager.recived_message.connect(recive_text)
