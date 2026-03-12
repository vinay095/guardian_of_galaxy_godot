extends Node2D

# Destructible planet - obstacle that blocks path but doesn't deal damage

@onready var sprite: Sprite2D = $Sprite2D
@onready var visible_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var stats_component: StatsComponent = $StatsComponent as StatsComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent as HurtboxComponent
@onready var flash_component: FlashComponent = $FlashComponent as FlashComponent
@onready var scale_component: ScaleComponent = $ScaleComponent as ScaleComponent
@onready var destroyed_component: DestroyedComponent = $DestroyedComponent as DestroyedComponent

var planet_textures = [
	"res://spacepixels/planet1.png",
	"res://spacepixels/planet2.png",
	"res://spacepixels/planet3.png",
	"res://spacepixels/planet4.png",
	"res://spacepixels/planet5.png",
	"res://spacepixels/planet6.png"
]

func _ready() -> void:
	# Pick random planet texture
	var tex_path = planet_textures.pick_random()
	sprite.texture = load(tex_path)
	
	# Set scale and health based on planet size (planet1-3 are bigger)
	var planet_idx = planet_textures.find(tex_path)
	if planet_idx < 3:
		sprite.scale = Vector2(0.22, 0.22)
		stats_component.health = 20
	else:
		sprite.scale = Vector2(0.30, 0.30)
		stats_component.health = 10
	
	visible_notifier.screen_exited.connect(queue_free)
	stats_component.no_health.connect(queue_free)
	
	hurtbox_component.hurt.connect(func(hitbox: HitboxComponent):
		flash_component.flash()
		scale_component.tween_scale()
	)
