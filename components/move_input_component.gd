class_name MoveInputComponent
extends Node

@export var move_stats: MoveStats
@export var move_component: MoveComponent

var screen_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")

func _input(event: InputEvent) -> void:
	# Touch drag: move ship horizontally to follow finger
	if event is InputEventScreenDrag:
		move_component.actor.global_position.x += event.relative.x
		# Clamp to screen bounds
		move_component.actor.global_position.x = clampf(
			move_component.actor.global_position.x, 8.0, screen_width - 8.0
		)
	
	# Keyboard fallback
	var input_axis = Input.get_axis("ui_left", "ui_right")
	move_component.velocity = Vector2(input_axis * move_stats.speed, 0)
