extends Node

var score: int = 0
var gameLost: bool = false
@export var laser_speed: int = 1000
var high_score: int = 0



func speed_boost():
	print("speed_boost : " + str(laser_speed))
	laser_speed += 300
