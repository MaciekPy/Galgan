extends Area2D


signal heart_picked_up

func setup(pos)->void:
	position = pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position += Vector2.DOWN * 1.2
	


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#print("Player Picked up heart")
		heart_picked_up.emit()
		$Pick_up.play()
		#body.shield_up()
		queue_free()
