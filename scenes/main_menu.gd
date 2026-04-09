extends Control

@onready var SceneTransitionAnimation = $TransistionAnimation/AnimationPlayer

func _ready() -> void:
	
	$TransistionAnimation.visible = false
	var bus_index = AudioServer.get_bus_index("Music")
	var effect_index = 0  # the position of your filter in the bus's effect chain
	var effect = AudioServer.get_bus_effect(bus_index, effect_index)
	effect.cutoff_hz = 400  # or however you want to "open" the filter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed()->void:
	$StartSound.play()
	Global.score = 0
	$TransistionAnimation.visible = true
	SceneTransitionAnimation.play("fade_in")
	await SceneTransitionAnimation.animation_finished
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_music_pressed() -> void:
	var on_icon = load("res://Sprites/Icons/musicOn.png")
	var off_icon = load("res://Sprites/Icons/musicOff.png")
	
	if $Music.icon == on_icon:
		#Music Off
		$Music.icon = off_icon
		MusicManager.stop()
	else:
		#Music on
		$Music.icon = on_icon
		MusicManager.play()

func _on_sound_pressed() -> void:
	var on_icon = load("res://Sprites/Icons/audioOn.png")
	var off_icon = load("res://Sprites/Icons/audioOff.png")
	var bus_index = AudioServer.get_bus_index("Effects")
	
	if $Sound.icon == on_icon:
		$Sound.icon = off_icon
		AudioServer.set_bus_mute(bus_index,true)
	else:
		$Sound.icon = on_icon
		AudioServer.set_bus_mute(bus_index, false)

	$SoundTest.play()
