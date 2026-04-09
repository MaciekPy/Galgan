extends Area2D


signal shield_picked_up

func setup(pos)->void:
	position = pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position += Vector2.DOWN * 1.2
	

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$"Pick-up".play()
		#print("Player Picked up heart")
		shield_picked_up.emit()
		queue_free()
