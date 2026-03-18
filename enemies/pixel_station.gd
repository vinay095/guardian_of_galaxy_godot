extends Node2D

# Pixel station turret - shoots continuous laser in one fixed direction
# Spawns at screen edges, fires at various angles (not tracking player)

@onready var sprite: Sprite2D = $Sprite2D
@onready var stats_component: StatsComponent = $StatsComponent as StatsComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent as HurtboxComponent
@onready var flash_component: FlashComponent = $FlashComponent as FlashComponent
@onready var score_component: ScoreComponent = $ScoreComponent as ScoreComponent
@onready var destroyed_component: DestroyedComponent = $DestroyedComponent as DestroyedComponent
@onready var laser_line: Line2D = $LaserLine
@onready var laser_hitbox: Area2D = $LaserHitbox
@onready var damage_timer: Timer = $DamageTimer

var station_textures = [
	"res://spacepixels/pixel_station_blue.png",
	"res://spacepixels/pixel_station_green.png",
	"res://spacepixels/pixel_station_red.png",
	"res://spacepixels/pixel_station_yellow.png"
]

var laser_angle: float = 0.0
var laser_length: float = 300.0
var laser_active: bool = true

func _ready() -> void:
	# Random station texture and scale down to game units
	sprite.texture = load(station_textures.pick_random())
	sprite.scale = Vector2(0.3, 0.3)
	
	# Always fire straight down toward the bottom of the screen
	laser_angle = PI / 2.0
	
	stats_component.no_health.connect(func():
		score_component.adjust_score()
		queue_free()
	)
	
	hurtbox_component.hurt.connect(func(hitbox: HitboxComponent):
		flash_component.flash()
	)
	
	# Setup laser line visual
	laser_line.width = 2.0
	laser_line.default_color = Color(1.0, 0.3, 0.3, 0.7)
	_update_laser()
	
	# Rotate the laser hitbox to match the angle (straight down)
	laser_hitbox.rotation = laser_angle
	laser_hitbox.get_node("CollisionShape2D").position = Vector2(150, 0) # Center along the beam
	
	# Damage tick timer for continuous laser
	damage_timer.timeout.connect(_deal_laser_damage)

func _process(_delta: float) -> void:
	# Pulse the laser opacity for visual effect
	var pulse = 0.5 + 0.3 * sin(Time.get_ticks_msec() * 0.005)
	laser_line.default_color = Color(1.0, 0.3, 0.3, pulse)

func _update_laser() -> void:
	var end_point = Vector2(cos(laser_angle), sin(laser_angle)) * laser_length
	laser_line.clear_points()
	laser_line.add_point(Vector2.ZERO)
	laser_line.add_point(end_point)

func _deal_laser_damage() -> void:
	# Check if any player hurtbox overlaps with our laser hitbox area
	var areas = laser_hitbox.get_overlapping_areas()
	for area in areas:
		if area is HurtboxComponent and not area.is_invincible:
			# Deal half damage (0.5 rounded, so at least 1 every other hit)
			# We use a flag to alternate damage
			area.hurt.emit(self)
