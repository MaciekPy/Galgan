extends CharacterBody2D


var direction: Vector2 = Vector2.RIGHT
@export var speed: float = 0.1
@export var health: int = 5
var random_spawn = [0.01, 0.2 ,0.4, 0.6, 0.8, 0.95]
signal enemy_shoot(pos: Vector2)
signal upgrade_spawned(pos: Vector2)
var Iframes: bool = true
var path_follow: PathFollow2D
var is_enemy_dead: bool = false

func _ready() -> void:
	#position = Vector2(rand_pos_x,200)
	$Hit.visible = false
	$explosion.hide()
	#$AnimationPlayer.play("spawn")
	path_follow = get_parent()
	path_follow.progress_ratio = random_spawn.pick_random()
	$SpawnSound.play()
	
func _physics_process(delta: float) -> void:
	
	path_follow.progress_ratio += speed * delta
	if path_follow.progress_ratio <= 0.0 or path_follow.progress_ratio >= 0.99:
		speed = -speed
		#print(speed)
	
	#velocity = direction * speed * delta
	
	#if position.x > 900:
	#	direction = Vector2.LEFT
	#if position.x < 50:
	#	direction = Vector2.RIGHT
	
	move_and_slide()

func shoot():
	#print("enemy shoot")
	#$Shoot.pitch_scale = randf_range(0.5,2)
	$Shoot.play()
	
	enemy_shoot.emit(global_position)

func _on_enemy_reload_timeout() -> void:
	shoot()

func _on_enemy_2_area_entered(area: Area2D) -> void:
	if area.name == "Enemy" or area.name == "Enemy2":
		pass
	else:
		enemy_hit()
	
	if area.name == "Hitbox":
		var player = area.get_parent()
		player.end_game()

func enemy_hit():
	if Iframes:
		pass
	else:
		health -= 1
		if health >= 1:
			$AnimationPlayer.play("hit")
		if  health < 0:
			explode()
		
func explode():
	if is_enemy_dead == false:
		is_enemy_dead = true
		Global.score += 500
		$PointLight2D.hide()
		$Sprite2D.hide()
		$explosion.show()
		$Explosion.play()
		if randf() < 0.15:  # 15% chance
			spawn_upgrade(global_position)
			#print("position in enemy2 : " + str(global_position))
		$AnimationPlayer.play("explode")
		await $AnimationPlayer.animation_finished
		
			#print("Enemy should drop heart")
		
		call_deferred("queue_free")
	
func spawn_upgrade(pos: Vector2)->void:
	upgrade_spawned.emit.call_deferred(pos)
	
func _on_spawn_timeout() -> void:
	Iframes = false # Replace with function body.
