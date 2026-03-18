extends Control

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://menus/ship_select.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		get_tree().change_scene_to_file("res://menus/ship_select.tscn")
