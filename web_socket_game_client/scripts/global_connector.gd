extends Node


@export var function_name : StringName
@export var signal_name : StringName

func _ready():
	connect(signal_name,Callable(WebSocketManager,function_name))

