# Give the component a class name so it can be instanced as a custom node
class_name ScaleComponent
extends Node

# Export the sprite that this component will be scaling
@export var sprite: Node2D

# Export the scale amount (as a vector)
@export var scale_amount = Vector2(1.5, 1.5)

# Export the scale duration
@export var scale_duration: = 0.4

# Store the sprite's original scale so we tween back to it (not Vector2.ONE)
var _original_scale: Vector2 = Vector2.ONE
var _original_scale_set: bool = false

# This is the function that will activate this component
func tween_scale() -> void:
	# Capture original scale on first call (after sprite setup has run)
	if not _original_scale_set and sprite:
		_original_scale = sprite.scale
		_original_scale_set = true
	
	# Compute the target "pop" scale relative to the original
	var pop_scale = _original_scale * scale_amount
	
	# We are going to scale the sprite using a tween (so we can make is smooth)
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	# Scale up to pop_scale then back to original
	tween.tween_property(sprite, "scale", pop_scale, scale_duration * 0.1).from_current()
	tween.tween_property(sprite, "scale", _original_scale, scale_duration * 0.9).from(pop_scale)
