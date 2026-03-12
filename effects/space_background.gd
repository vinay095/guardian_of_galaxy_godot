extends ParallaxBackground

@onready var space_layer: ParallaxLayer = %SpaceLayer
@onready var far_stars_layer: ParallaxLayer = %FarStarsLayer
@onready var close_stars_layer: ParallaxLayer = %CloseStarsLayer

var space_texture_rect: TextureRect

var base_scroll_speed: float = 1.0
var current_scroll_speed: float = 1.0

# Background textures
var bg_black = preload("res://spacepixels/background-black.png")
var bg_purple = preload("res://spacepixels/background-purple.png")
var bg_red = preload("res://spacepixels/background-red.png")
var bg_blue = preload("res://spacepixels/background-blue.png")

func _ready() -> void:
	# Get the TextureRect child of SpaceLayer
	space_texture_rect = space_layer.get_node("Space") as TextureRect
	# Start with black background
	change_background("black")

func _process(delta: float) -> void:
	space_layer.motion_offset.y += 0.4 * delta * current_scroll_speed
	far_stars_layer.motion_offset.y += 1.0 * delta * current_scroll_speed
	close_stars_layer.motion_offset.y += 6.0 * delta * current_scroll_speed

func change_background(bg_name: String) -> void:
	match bg_name:
		"black":
			space_texture_rect.texture = bg_black
			current_scroll_speed = 1.0
		"purple":
			space_texture_rect.texture = bg_purple
			current_scroll_speed = 1.5
		"red":
			space_texture_rect.texture = bg_red
			current_scroll_speed = 2.0
		"blue":
			space_texture_rect.texture = bg_blue
			current_scroll_speed = 1.2
