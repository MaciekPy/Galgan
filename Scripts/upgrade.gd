extends Node2D

@export var speed: int = 2
signal speed_upgrade


func setup(pos:Vector2) -> void:
	position = pos
	
func _physics_process(delta: float) -> void:
	position.y += 40 * speed * delta
	
	if position.y > 700:
		speed = 0
	
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body.name == "Player":
		$Pickup.play()
		var timer = body.get_node("ReloadTimer")
		if timer.wait_time > 0.05:
			timer.wait_time -= 0.05
		speed_upgrade.emit()
	queue_free()
