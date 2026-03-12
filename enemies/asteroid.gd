extends Node2D

# Asteroid with diagonal trajectory - deals damage on contact, takes 4 hits to destroy

@onready var move_component: MoveComponent = $MoveComponent as MoveComponent
@onready var visible_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox_component: Area2D = $HurtboxComponent
@onready var hitbox_component: Area2D = $HitboxComponent

var health: int = 4
var rotation_speed: float = 0.0

func _ready() -> void:
	# Random diagonal trajectory
	var x_vel = randf_range(-40, 40)
	var y_vel = randf_range(20, 55)
	move_component.velocity = Vector2(x_vel, y_vel)

	# Random rotation
	rotation_speed = randf_range(-2.0, 2.0)

	# Scale down to game units + random size variation
	var s = randf_range(0.2, 0.35)
	sprite.scale = Vector2(s, s)

	# Clean up when off-screen
	visible_notifier.screen_exited.connect(queue_free)

	# Take hits from player laser (hitbox of THIS asteroid enters player laser hurtbox)
	hurtbox_component.area_entered.connect(_on_hit)

	# Deal damage when contacting player
	hitbox_component.area_entered.connect(_on_player_contact)

func _on_hit(area: Area2D) -> void:
	# Only take damage from player laser HitboxComponents
	if not area is HitboxComponent:
		return
	health -= 1
	# Visual flash
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)
	if health <= 0:
		queue_free()

func _on_player_contact(area: Area2D) -> void:
	# If this touches a player hurtbox, it damages on the hurtbox side (via HitboxComponent)
	pass

func _process(delta: float) -> void:
	sprite.rotation += rotation_speed * delta
