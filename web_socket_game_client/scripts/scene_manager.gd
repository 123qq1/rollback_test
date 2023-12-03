extends Node

func load_arena():
	get_tree().change_scene_to_file("res://scenes/arena.tscn")
	
func load_lobby():
	get_tree().change_scene_to_file("res://scenes/arena.tscn")
	
	
func _ready():
	WebSocketManager.on_connected.connect(load_arena)
	WebSocketManager.on_disconnected.connect(load_lobby)
