extends Node2D

signal move(dir)
signal stop()


func _input(event):
	if event.is_action_pressed("move_left"):
		move.emit(-1)
	if event.is_action_pressed("move_right"):
		move.emit(1)
	if event.is_action_released("move_right"):
		stop.emit()
	if event.is_action_released("move_left"):
		stop.emit()
	
