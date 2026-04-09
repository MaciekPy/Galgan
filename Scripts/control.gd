extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Score.text = "Score : " + str(Global.score)
	$Score2.text = $Score.text
	$Control.visible = false
	$AnimationPlayer2.play("idle")
	if Global.score > Global.high_score:
		#print("New Best Score")
		$Control.visible = true
		Global.high_score = Global.score
		$AnimationPlayer.play("Best_Score")
	
	var bus_index = AudioServer.get_bus_index("Music")
	var effect_index = 0  # the position of your filter in the bus's effect chain
	var effect = AudioServer.get_bus_effect(bus_index, effect_index)
	effect.cutoff_hz = 400  # or however you want to "open" the filter
		
	if Global.gameLost: 
		pass
	elif Global.gameLost == false:
		$"Game Won".show()
		$"Game Won2".show()
		$"Game Over2".hide()
		$"Game Over".hide()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Dash"):
		Global.score = 0
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	
