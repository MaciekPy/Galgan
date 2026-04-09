extends CharacterBody2D


@export var SPEED = 500.0
const MAX_SPEED: float = 400.0
const ACCELERATION: float = 100.5
const FRICTION: float = 50.5
var direction: Vector2 = Vector2.ZERO
signal shoot(pos: Vector2)
signal player_is_hit(health: int)
signal shield_down
var reloading: bool = false
var health: int = 3 
var end_scene: PackedScene = preload("res://scenes/control.tscn")
var iFrames: bool = false
var is_shield_up: bool = false


func _ready():
	$Hit.visible = false
	$Shield_light.visible = false
	
func _physics_process(delta: float) -> void:
	
	var input: Vector2 = Vector2(Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")).normalized()
	
	var velocity_weight_x: float = 1.0 - exp(-(ACCELERATION if input.x else FRICTION)* delta)
	velocity.x = lerp(velocity.x, input.x * MAX_SPEED, velocity_weight_x)
	
	var velocity_weight_y: float = 1.0 - exp(-(ACCELERATION if input.y else FRICTION) * delta)
	velocity.y = lerp(velocity.y, input.y * MAX_SPEED, velocity_weight_y)
	
	
	#direction = Input.get_vector("Left","Right","Up","Down")
	#velocity = direction*SPEED
	move_and_slide()
	
	if Input.is_action_pressed("Shoot"):
		if reloading == false:
			player_shoot()
		else:
			#print("reloading..")
			pass
	
func player_shoot():
	reloading = true
	#print("player shoot")
	$LaserSound.play()
	$ReloadTimer.start()
	shoot.emit(position)
	
func _on_reload_timer_timeout() -> void:
	reloading = false # Replace with function body.
	
func end_game():
	
	$PointLight2D.hide()
	$explosion.show()
	$Sprite2D.hide()
	$Explosion.play()
	$AnimationPlayer.play("explode")
	await $AnimationPlayer.animation_finished
	
	call_deferred("game_lost")
	
func game_lost():
	Global.gameLost = true
	get_tree().change_scene_to_file("res://scenes/control.tscn")
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	#print(area.name)
	if area.name == "Enemy" or area.name == "Enemy_2":
		player_hit()
	

func player_hit():
	if iFrames:
		pass
	else:
		if is_shield_up:
			is_shield_up = false
			$Shield_light.visible = false
			#print("shield down")
			$shield_down.play()
			shield_down.emit()
		
		else:

			#print("player hit")
			$IFrames.start()
			iFrames = true
			health -=1
			$Hit_sound.play()
			
			emit_signal("player_is_hit",health)
			if health >= 1:
				$AnimationPlayer.play("hit")
			if health < 1:
				end_game()

func shield_up()->void:
	if is_shield_up == false:
		is_shield_up = true
		$Shield_light.visible = true
		#print("Shield up: " + str(is_shield_up))

func _on_i_frames_timeout() -> void:
	iFrames = false
