extends AudioStreamPlayer

var normal_music = preload("res://sounds/space.mp3")
var boss_music = preload("res://sounds/boss.mp3")

func _ready() -> void:
	stream = normal_music
	autoplay = true
	bus = &"Music"
	play()

func play_normal() -> void:
	if stream == normal_music and playing:
		return
	stream = normal_music
	play()

func play_boss() -> void:
	if stream == boss_music and playing:
		return
	stream = boss_music
	play()
