extends Node

@export var player_1 : CharacterBody2D
@export var player_2 : CharacterBody2D

var is_player_1
var is_against_ai

func setup_wireless(is_1):
	is_player_1 = is_1
	is_against_ai = false
	
func setup_vs_ai():
	is_player_1 = true
	is_against_ai = true
