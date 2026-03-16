class_name MiniBoss
extends Enemy

@onready var fire_timer: Timer = $FireTimer
@onready var projectile_spawner: SpawnerComponent = $ProjectileSpawner as SpawnerComponent
@onready var direction_timer: Timer = $DirectionTimer

var horizontal_speed: float = 0.0
var target_y: float = 0.0
var reached_target: bool = false

func _ready() -> void:
	super()
	
	# Set random target Y position (mid screen – attacking stance)
	# Viewport is 240px tall, so 80-120 is roughly the middle half
	target_y = randf_range(80, 120)
	
	# Initial downward movement
	move_component.velocity = Vector2(0, 25)
	
	# Setup firing
	fire_timer.timeout.connect(_fire_projectile)
	
	# Setup random direction changes
	direction_timer.timeout.connect(_change_direction)

func _process(_delta: float) -> void:
	if not reached_target:
		if global_position.y >= target_y:
			reached_target = true
			_change_direction()
	
	# Random slight vertical drift
	if reached_target:
		move_component.velocity.y = sin(Time.get_ticks_msec() * 0.002) * 8
	
	# Face the SPRITE toward the player (don't rotate the whole node, that messes up movement)
	var sprite_node = $AnimatedSprite2D as AnimatedSprite2D
	if sprite_node:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0 and is_instance_valid(players[0]):
			var player_pos = players[0].global_position
			var dir = (player_pos - global_position).normalized()
			# The sprite is flip_v=true so it faces DOWN by default.
			# angle_to from Vector2.DOWN gives 0 when pointing straight down.
			sprite_node.rotation = Vector2.DOWN.angle_to(dir)

func _fire_projectile() -> void:
	if not is_inside_tree():
		return
	projectile_spawner.spawn(global_position + Vector2(0, 10))

func _change_direction() -> void:
	# Random horizontal movement
	horizontal_speed = randf_range(-30, 30)
	move_component.velocity.x = horizontal_speed
	
	# Schedule next direction change
	direction_timer.start(randf_range(1.0, 3.0))

func set_boss_sprite(ship_config: Dictionary) -> void:
	# Use a simple Sprite2D overlay since enemy.tscn AnimatedSprite2D has no frames yet
	var sprite_node = $AnimatedSprite2D as AnimatedSprite2D
	if sprite_node:
		var frames = SpriteFrames.new()
		# SpriteFrames.new() already has a "default" animation, just configure it
		frames.set_animation_loop("default", true)
		frames.set_animation_speed("default", 1.0)
		var tex = load(ship_config["sprite"])
		frames.add_frame("default", tex)
		sprite_node.sprite_frames = frames
		sprite_node.play("default")
		# Scale to match game units (~16px) - spacepixels ships are ~24-32px wide
		var s = ship_config.get("ship_scale", 0.55)
		sprite_node.scale = Vector2(s, s)
		# Flip vertically so the ship faces downward (toward the player)
		sprite_node.flip_v = true

