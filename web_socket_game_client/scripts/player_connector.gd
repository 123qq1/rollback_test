extends Node

@export var player_1 : CharacterBody2D
@export var player_2 : CharacterBody2D
@export var player_controller : Node

var is_player_1
var is_against_ai

func setup_wireless(is_1):
	print("Setup: %s" % is_1)
	is_player_1 = is_1
	is_against_ai = false
	if is_1:
		#player_1.set_script("res://scripts/player/character_manager.gd")
		player_controller.move.connect(player_1.move)
		player_controller.stop.connect(player_1.stop_moving)
		player_1.set_is_ai(false)
		player_2.set_is_ai(true)
	else:
		#player_2.set_script("res://scripts/player/character_manager.gd")
		player_controller.move.connect(player_2.move)
		player_controller.stop.connect(player_2.stop_moving)
		player_1.set_is_ai(true)
		player_2.set_is_ai(false)
	player_1.set_p_1(is_1)
	player_2.set_p_1(!is_1)
	
func setup_vs_ai():
	is_player_1 = true
	is_against_ai = true
	#player_1.set_script("res://scripts/player_controller")
