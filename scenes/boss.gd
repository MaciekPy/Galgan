extends CharacterBody2D

@export var speed: float = 20
@export var max_health: int = 40
var health: int = max_health
var LT_health: int = health
var RT_health: int = health
var Head_health: int = health*2
var direction = Vector2.RIGHT
var head_time:bool = false
signal shoot(pos:Vector2)
var LT_shot_counter: int
var RT_shot_counter: int
var Head_shot_counter: int
var stop_shooting: bool = false

var LT_turret_destroyed: bool = false
var RT_turret_destroyed: bool = false
var Head_destroyed: bool = false
var shield_down: bool = false

var Iframes: bool = true

signal boss_defeated()

func _ready() -> void:
	position = Vector2(500,-100)
	scale = Vector2(6,6)
	var tween = get_tree().create_tween()
	#tween.tween_property(self, "scale", Vector2(6,6), 3)
	tween.parallel().tween_property(self, "position",Vector2(500,300),3)
	$Entrance.play()
	$RightTurret/RTHit.visible = false
	$Head/HeadHit.visible = false
	$LeftTurret/LTHit.visible = false
	$LeftTurret/LTexplosion.hide()
	$RightTurret/RTexplosion.hide()
	$Head/Headexplosion.hide()
	$Bodyexplosion.hide()
	$Bodyexplosion2.hide()
	$ambience.play()
	
	
func _physics_process(_delta: float) -> void:
	
	velocity = direction * speed
	
	if position.x > 600:
		direction = Vector2.LEFT
	if position.x < 300:
		direction = Vector2.RIGHT
	
	if LT_health <=0 and RT_health<=0:
		head_time = true

	move_and_slide()

#LEFT TURRET
func _on_lt_area_area_entered(_area: Area2D) -> void:
	LT_health -= 1
	
	
	if LT_health >= 1:
		$AnimationPlayer.play("LT_Hit")
	
	if LT_health <= 0:
		LT_explode()
		

func LT_explode()->void:
	if LT_turret_destroyed == false:
		LT_turret_destroyed = true
		$LT_Bleed.show()
		Global.score += 10000
		speed += 50
		$Explosion.play()
		$LeftTurret/LeftTurret2.hide()
		$LeftTurret/LTexplosion.show()
		$AnimationPlayer.play("LT_explode")
		await $AnimationPlayer.animation_finished
		$LeftTurret.queue_free()

func _on_lt_shoot_timeout() -> void:
	if LT_shot_counter > 0:
		#$Shoot.pitch_scale = randf_range(0.5,2)
		$Shoot.play()
		
		shoot.emit($LeftTurret/LeftTurret.global_position)
		LT_shot_counter -= 1
	if LT_shot_counter <=0:
		$LeftTurret/LTShoot.stop()
	
func _on_lt_shoot_cooldown_timeout() -> void:
	LT_shot_counter = 3
	$LeftTurret/LTShoot.start()
		

#RIGHT TURRET
func _on_rt_area_area_entered(_area: Area2D) -> void:
	RT_health -= 1
	if RT_health >= 1:
		$AnimationPlayer.play("RT_Hit")
	
	if RT_health <= 0:
		RT_explode()
		

func RT_explode()->void:
	if RT_turret_destroyed == false:
		Global.score += 10000
		RT_turret_destroyed = true
		speed += 50
		#print("RT explode")
		$RT_Bleed.show()
		$Explosion.play()
		$RightTurret/RightTurret2.hide()
		$RightTurret/RTexplosion.show()
		$AnimationPlayer.play("RT_explode")
		await $AnimationPlayer.animation_finished
		$RightTurret.queue_free()

func _on_rt_shoot_timeout() -> void:
	if RT_shot_counter > 0:
		#$Shoot.pitch_scale = randf_range(0.5,2)
		$Shoot.play()
		
		shoot.emit($RightTurret/RightTurret.global_position)
		RT_shot_counter -= 1
	if RT_shot_counter <=0:
		$RightTurret/RTShoot.stop()

func _on_rt_shooter_cooldown_timeout() -> void:
	RT_shot_counter = 3
	$RightTurret/RTShoot.start()

#HEAD 
func _on_head_area_area_entered(_area: Area2D) -> void:
	Head_health -= 1
	#print("Boss Health: " + str(Head_health))
	if Head_health >= 1:
		$AnimationPlayer.play("Head_Hit")
	
	if Head_health <= 0:
		stop_shooting = true
		Head_explode()
	
	if Head_health == max_health/2:
		$Head/HeadCooldown.wait_time = 1.4
		#print("boss speed up 1")
	if Head_health == max_health/max_health+16:
		$Head/HeadCooldown.wait_time = 1.1
		#print("boss speed up 2")

func Head_explode()->void:
	if Head_destroyed == false:
		Global.score += 100000
		Head_destroyed = true
		
		
		#print("Big explosion")
		$Head/Head2.hide()
		$Head/Headexplosion.show()
		$AnimationPlayer.play("head_explode")
		$"before explode".play()
		await $AnimationPlayer.animation_finished
		big_explosion()
		$Head.queue_free()

func _on_head_shoot_timeout() -> void:
	if Head_shot_counter > 0:
		shoot.emit($Head/Head.global_position)
		#$Shoot.pitch_scale = randf_range(0.5,2)
		$Shoot.play()
		
		Head_shot_counter -= 1
	if Head_shot_counter <= 0:
		$Head/HeadShoot.stop()

func _on_head_cooldown_timeout() -> void:
	if stop_shooting == false:
		if LT_turret_destroyed and RT_turret_destroyed:
			is_shield_down()
			Head_shot_counter = 7
			if health < 15:
				Head_shot_counter = 10
			
			$Head/HeadShoot.start()


func is_shield_down() -> void:
	if shield_down == false:
		$Shield.queue_free()
		shield_down = true
		

func big_explosion() -> void:
	$Bodyexplosion.show()
	$Bodyexplosion2.show()
	#print("big_explode")
	$ambience.stop()
	$AnimationPlayer.play("big_explode")
	$Ending.start()


func _on_ending_timeout() -> void:
	boss_defeated.emit()
	queue_free()


func _on_shield_area_entered(area: Area2D) -> void:
	area.queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	#print("area entered :" + str(area.name))
	if area.name == "Enemy" or area.name == "Enemy_2":
		area.get_parent().explode()
