extends CharacterBody2D

enum states {IDLE,MOVING,BLOCKING,BLOCK_STUN,HIT_STUN,ATTACKING}

var state

func _input(event):
	
