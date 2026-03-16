extends Node2D

# Ally ship that follows the player and auto-fires during boss fights

@onready var spawner_component: SpawnerComponent = $SpawnerComponent as SpawnerComponent
@onready var fire_timer: Timer = $FireTimer
@onready var sprite: Sprite2D = $Sprite2D

var target_player: Node2D = null
var follow_offset: Vector2 = Vector2(-15, 10)

func _ready() -> void:
	fire_timer.timeout.connect(_fire)
	
	# Set sprite based on selected ship's matching small sprite
	var ship_config = ShipData.get_selected_ship()
	sprite.texture = load(ship_config["small_sprite"])
	sprite.scale = Vector2(0.8, 0.8)  # small sprites are ~10-12px, scale to ~8-10px
	
	# Set laser scene - use the standard laser (same as player ship)
	spawner_component.scene = load("res://projectiles/laser.tscn")
	
	# Find the player
	await get_tree().process_frame
	var ships = get_tree().get_nodes_in_group("player")
	if ships.size() > 0:
		target_player = ships[0]

func _process(delta: float) -> void:
	if target_player and is_instance_valid(target_player):
		# Follow player with smooth lerp
		var target_pos = target_player.global_position + follow_offset
		global_position = global_position.lerp(target_pos, 5.0 * delta)
	else:
		# If player is dead, self-destruct
		queue_free()

func _fire() -> void:
	if not is_instance_valid(target_player):
		return
	spawner_component.spawn(global_position + Vector2(0, -6))
