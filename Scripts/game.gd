extends Node2D

var laser_scene = preload("res://scenes/Laser.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")
var enemy2_scene = preload("res://scenes/Enemy2.tscn")
var upgrade_scene = preload("res://scenes/upgrade.tscn")
var enemy_laser = preload("res://scenes/Enemy_Laser.tscn")
var heart_scene = preload("res://scenes/heart.tscn")
var boss_scene = preload("res://scenes/Boss.tscn")
var shield_scene = preload("res://scenes/shield.tscn")
@onready var SceneTransitionAnimation = $CanvasLayer/SubViewport/TransistionAnimation/AnimationPlayer
@export var enemy_speed: int = 300
@export var swarm_number: int = 20
var boss_time: bool = false
var speed_upgrades_number: int = 0


func _ready() -> void:
	SceneTransitionAnimation.get_parent().get_node("ColorRect").color.a = 255
	SceneTransitionAnimation.play("fade_out")
	#$TransistionAnimation.visible = false
	$CanvasLayer/SubViewport/Score/Swarm.visible = false
	$"CanvasLayer/SubViewport/Score/Upgrade text".visible = false
	$CanvasLayer/SubViewport/Score/Boss_Incoming.visible = false
	var bus_index = AudioServer.get_bus_index("Music")
	var effect_index = 0  # the position of your filter in the bus's effect chain
	var effect = AudioServer.get_bus_effect(bus_index, effect_index)
	effect.cutoff_hz = 20000  # or however you want to "open" the filter
		
	
func _physics_process(_delta: float) -> void:
	$CanvasLayer/SubViewport/Score/Score.text = "Score : " + str(Global.score)
	$CanvasLayer/SubViewport/Backgrounds.position.y += 1
	
	
func _on_player_shoot(pos: Vector2) -> void:
	var laser = laser_scene.instantiate() as Area2D
	$CanvasLayer/SubViewport/Lasers.add_child(laser)
	laser.setup(pos)

#FUNCTION SPAWNING ENEMIES
func _on_enemy_spawn_timeout() -> void:
	if boss_time == false:
		spawn_enemy()

func _on_enemy_2_spawn_timeout() -> void:
	if boss_time == false:
		spawn_enemy2()

func _on_swarm_timer_timeout() -> void:
	if boss_time == false:
		$AnimationPlayer.play("SwarmTime")
		for i in range(swarm_number):
			spawn_enemy()
		swarm_number+=10
		$"Enemy Spawn".wait_time -= 0.1
	
		#Spawnuje kilka w jendym miejscu przez dodanie PATH2d
		for i in range(swarm_number/20):
			spawn_enemy2()

func spawn_enemy():
	var enemy = enemy_scene.instantiate() as CharacterBody2D
	enemy.heart_dropped.connect(_on_enemy_heart_dropped)
	enemy.shield_dropped.connect(_on_enemy_shield_dropped)
	$CanvasLayer/SubViewport/Entities.add_child(enemy)
	enemy.setup(enemy_speed)

func spawn_enemy2():
	#print("Spawn Enemy 2")
	var enemy2 = enemy2_scene.instantiate() as CharacterBody2D
	enemy2.enemy_shoot.connect(on_enemy_shoot)
	enemy2.upgrade_spawned.connect(_on_enemy2_upgrade_dropped)
	var pathfollow = PathFollow2D.new()
	$CanvasLayer/SubViewport/Entities/Path2D2.add_child(pathfollow)
	pathfollow.add_child(enemy2)
	
#BOSS
func on_boss_shoot(pos):
	#sdprint(pos)
	var laser1 = enemy_laser.instantiate() as Area2D
	var laser2 = enemy_laser.instantiate() as Area2D
	var laser3 = enemy_laser.instantiate() as Area2D
	var laser4 = enemy_laser.instantiate() as Area2D
	var laser5 = enemy_laser.instantiate() as Area2D
	
	
	$CanvasLayer/SubViewport/Lasers.add_child(laser1)
	$CanvasLayer/SubViewport/Lasers.add_child(laser2)
	$CanvasLayer/SubViewport/Lasers.add_child(laser3)
	$CanvasLayer/SubViewport/Lasers.add_child(laser4)
	$CanvasLayer/SubViewport/Lasers.add_child(laser5)
	
	laser1.setup(Vector2(-1,1.98),pos)
	laser2.setup(Vector2(0,2),pos)
	laser3.setup(Vector2(1,1.98),pos)
	laser4.setup(Vector2(1,1.20),pos)
	laser5.setup(Vector2(-1,1.20),pos)

func _on_boss_timeout() -> void:
	boss_time = true
	$AnimationPlayer.play("BossTime")
	
	$BOSS_suspense.start()
	await $AnimationPlayer.animation_finished
	
#ENEMIES SPAWN FASTER AFTER TIMER TIMEOUT
func _on_enemies_faster_timeout() -> void:
	#print("Faster Enemies")
	if enemy_speed < 1000:
		enemy_speed += 50 # Replace with function body.

func on_enemy_shoot(pos):
	#sdprint(pos)
	var laser1 = enemy_laser.instantiate() as Area2D
	var laser2 = enemy_laser.instantiate() as Area2D
	var laser3 = enemy_laser.instantiate() as Area2D
	
	
	$CanvasLayer/SubViewport/Lasers.add_child(laser1)
	$CanvasLayer/SubViewport/Lasers.add_child(laser2)
	$CanvasLayer/SubViewport/Lasers.add_child(laser3)
	
	laser1.setup(Vector2(-1,0.5),pos)
	laser2.setup(Vector2(0,1),pos)
	laser3.setup(Vector2(1,0.5),pos)

func _on_player_player_is_hit(_health: int) -> void:
	check_health()
	
	$AnimationPlayer.play("hearts")

func check_health()->void:
	var health = $CanvasLayer/SubViewport/Entities/Player.health
	
	if health == 3:
		$CanvasLayer/SubViewport/Score/Health/Heart1.visible = true
		$CanvasLayer/SubViewport/Score/Health/Heart2.visible = true
		$CanvasLayer/SubViewport/Score/Health/Heart3.visible = true
	if health == 2:
		$CanvasLayer/SubViewport/Score/Health/Heart1.visible = false
		$CanvasLayer/SubViewport/Score/Health/Heart2.visible = true
		$CanvasLayer/SubViewport/Score/Health/Heart3.visible = true
	if health == 1:
		$CanvasLayer/SubViewport/Score/Health/Heart1.visible = false
		$CanvasLayer/SubViewport/Score/Health/Heart2.visible = false
		$CanvasLayer/SubViewport/Score/Health/Heart3.visible = true
	if health == 0:
		$CanvasLayer/SubViewport/Score/Health/Heart1.visible = false
		$CanvasLayer/SubViewport/Score/Health/Heart2.visible = false
		$CanvasLayer/SubViewport/Score/Health/Heart3.visible = false
	
func _on_enemy_heart_dropped(pos: Vector2) -> void:
	var heart = heart_scene.instantiate() as Area2D
	$CanvasLayer/SubViewport/Upgrades.add_child(heart)
	heart.setup(pos)
	heart.heart_picked_up.connect(player_health_up)
	
func _on_enemy_shield_dropped(pos:Vector2) -> void:
	var shield = shield_scene.instantiate() as Area2D
	$CanvasLayer/SubViewport/Upgrades.add_child(shield)
	shield.setup(pos)
	shield.shield_picked_up.connect(shield_upgrade)
	
func _on_enemy2_upgrade_dropped(pos:Vector2) -> void:
	speed_upgrades_number+=1
	#print("UPGRADE SPEED")
	if speed_upgrades_number <= 3:
		var upgrade = upgrade_scene.instantiate() as Node2D
		$CanvasLayer/SubViewport/Upgrades.add_child(upgrade)
		upgrade.setup(pos)
		upgrade.speed_upgrade.connect(speed_upgrade)

func player_health_up():
	if $CanvasLayer/SubViewport/Entities/Player.health <3:
		$CanvasLayer/SubViewport/Entities/Player.health += 1
		$"Pick-up_Heart".play()
		check_health()
	else:
		print("player is at max health")
	
func shield_upgrade():
		$Pick_up_Shield.play()
		$CanvasLayer/SubViewport/Entities/Player.shield_up()

func speed_upgrade() -> void:
	Global.laser_speed += 5
	$"CanvasLayer/SubViewport/Score/Upgrade text".text = "Shot Speed Up"
	$AnimationPlayer.play("Upgrade")

func end_game()->void:
	Global.gameLost = false
	get_tree().change_scene_to_file("res://scenes/control.tscn")

func _on_boss_suspense_timeout() -> void:
	var boss = boss_scene.instantiate() as CharacterBody2D
	boss.shoot.connect(on_boss_shoot)
	boss.boss_defeated.connect(end_game)
	$CanvasLayer/SubViewport/Entities.add_child(boss)
