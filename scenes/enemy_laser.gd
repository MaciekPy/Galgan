extends Area2D

var direction: Vector2
var speed: int = 200


func setup(dir: Vector2,pos:Vector2):
	direction = dir
	position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var angle = Time.get_ticks_msec()/100
	
	position += direction * speed * delta 
	position.x += sin(angle)

func _on_body_entered(body: Node2D) -> void:
	
	body.player_hit()
	queue_free()
