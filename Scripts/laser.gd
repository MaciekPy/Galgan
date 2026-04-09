extends Area2D

var direction: Vector2 = Vector2.UP
var speed: int = Global.laser_speed

func setup(pos: Vector2):
	position = pos 
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	
