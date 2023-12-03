extends Node

@export var player_1 : CharacterBody2D
@export var player_2 : CharacterBody2D

var is_player_1
var is_against_ai

func setup_wireless(is_1):
	is_player_1 = is_1
	is_against_ai = false
	if is_1:
		player_1.set_script("res://scripts/player_controller")
	else:
		player_1.set_script("res://scripts/player_controller")
	
func setup_vs_ai():
	is_player_1 = true
	is_against_ai = true
	player_1.set_script("res://scripts/player_controller")
