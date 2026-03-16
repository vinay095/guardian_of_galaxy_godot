extends Node2D

@onready var left_muzzle: Marker2D = $LeftMuzzle
@onready var right_muzzle: Marker2D = $RightMuzzle
@onready var spawner_component: SpawnerComponent = $SpawnerComponent as SpawnerComponent
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var scale_component: ScaleComponent = $ScaleComponent as ScaleComponent
@onready var move_component: MoveComponent = $MoveComponent as MoveComponent
@onready var variable_pitch_audio_stream_player := $VariablePitchAudioStreamPlayer as VariablePitchAudioStreamPlayer
@onready var stats_component := $StatsComponent as StatsComponent
@onready var hurtbox_component := $HurtboxComponent as HurtboxComponent
@onready var ship_sprite: Sprite2D = $Anchor/ShipSprite
@onready var thruster_sprite: AnimatedSprite2D = $Anchor/ThrusterSprite
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var move_input_component: MoveInputComponent = $MoveInputComponent as MoveInputComponent

var is_special_active: bool = false
var can_use_special: bool = false  # Starts false, must charge first
var ship_config: Dictionary
var laser_color: Color = Color.WHITE

# Boost charge system: accumulates 0.0 → 1.0 over charge_time seconds
var boost_charge: float = 0.0
const BOOST_CHARGE_TIME: float = 8.0  # seconds to fully charge
const BOOST_DURATION: float = 3.0     # seconds of boost

# Color tints for each ship color
var color_tints = {
	"green": Color(0.3, 1.0, 0.3),
	"purple": Color(0.7, 0.3, 1.0),
	"blue": Color(0.3, 0.5, 1.0)
}

func _ready() -> void:
	fire_rate_timer.timeout.connect(fire_lasers)
	ship_config = ShipData.get_selected_ship()
	_apply_ship_config()
	invincibility_timer.timeout.connect(_end_special_attack)

func _apply_ship_config() -> void:
	stats_component.health = ship_config["health"]
	fire_rate_timer.wait_time = ship_config["fire_rate"]
	# Always use the original laser.tscn - it has correct collision setup
	spawner_component.scene = load("res://projectiles/laser.tscn")
	move_input_component.move_stats.speed = ship_config["speed"]

	ship_sprite.texture = load(ship_config["sprite"])
	var s = ship_config["ship_scale"]
	ship_sprite.scale = Vector2(s, s)
	thruster_sprite.visible = false

	# Set laser color tint based on ship color
	laser_color = color_tints.get(ship_config["color"], Color.WHITE)

func fire_lasers() -> void:
	variable_pitch_audio_stream_player.play_with_variance()
	var left_laser = spawner_component.spawn(left_muzzle.global_position)
	var right_laser = spawner_component.spawn(right_muzzle.global_position)

	# Tint laser color (keep original laser_small.png texture!) and set damage
	for laser in [left_laser, right_laser]:
		var spr = laser.get_node("Sprite2D") as Sprite2D
		if spr:
			spr.modulate = laser_color
		var hb = laser.get_node("HitboxComponent") as HitboxComponent
		if hb:
			hb.damage = ship_config["damage"]

	scale_component.tween_scale()

func _process(delta: float) -> void:
	# Accumulate boost charge when not boosting
	if not is_special_active:
		if boost_charge < 1.0:
			boost_charge = minf(boost_charge + delta / BOOST_CHARGE_TIME, 1.0)
			can_use_special = false
		else:
			can_use_special = true
	
	if Input.is_action_just_pressed("special_attack") and can_use_special and not is_special_active:
		_activate_special_attack()

func _activate_special_attack() -> void:
	is_special_active = true
	can_use_special = false
	boost_charge = 0.0
	hurtbox_component.is_invincible = true
	thruster_sprite.visible = true
	thruster_sprite.play("boost")
	modulate = Color(1.5, 1.5, 2.0, 1.0)
	invincibility_timer.start(BOOST_DURATION)

func _end_special_attack() -> void:
	is_special_active = false
	hurtbox_component.is_invincible = false
	thruster_sprite.visible = false
	thruster_sprite.stop()
	modulate = Color.WHITE
	# Charge starts accumulating again immediately
