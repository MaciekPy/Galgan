extends CharacterBody2D

var speed:int
var start_direction: int = randi_range(0,1)
var direction = Vector2(1,0.5)
var angle: float = randf_range(0.1,0.8)
signal heart_dropped(pos: Vector2)
signal shield_dropped(pos: Vector2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.x = randi_range(50,900)
	#print(angle)
	if start_direction == 0:
		direction = Vector2(-1,angle)
	else:
		direction = Vector2(1,angle)
		
	name = "Enemy"
	$SpawnSound.play()
	

func setup(enemy_speed: int):
	speed = enemy_speed
	$explosion.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	velocity = direction * speed
	
	if position.x > 900:
		direction = Vector2(-1,angle)
	if position.x < 50:
		direction = Vector2(1,angle)
	
	move_and_slide()
	
	if position.y > 1300:
		Global.score -= 200
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	#print(area.name)
	if area.name == "Enemy_2" or area.name == "Enemy":
		
		pass
	else:
		call_deferred("explode")

func explode():
	#print("enemy explode")
	#print("enemy dies")
	Global.score += 100
	$PointLight2D.hide()
	$explosion.show()
	$Sprite2D.hide()
	$Explosion.play()
	$AnimationPlayer.play("explode")
	$Enemy.queue_free()
	await $AnimationPlayer.animation_finished
	if randf() < 0.01:  # 1% chance
		spawn_heart(position)
		#print("Enemy should drop heart")
		
	if randf() < 0.01:
		spawn_shield(position)
		#print("enemy should drop shield")
	queue_free()

func spawn_heart(pos: Vector2):
	heart_dropped.emit(pos)
	
func spawn_shield(pos:Vector2)->void:
	shield_dropped.emit(pos)
