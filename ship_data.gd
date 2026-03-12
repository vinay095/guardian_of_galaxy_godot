extends Node

var selected_ship_id: int = 0
var boss_fights_completed: int = 0
var enemies_killed_since_boss: int = 0

var ships: Array[Dictionary] = [
	{
		"name": "Viper",
		"sprite": "res://spacepixels/ship_green.png",
		"health": 5,
		"fire_rate": 0.45,
		"laser_texture": "res://spacepixels/pixel_laser_green.png",
		"damage": 1,
		"speed": 80,
		"color": "green",
		"small_sprite": "res://spacepixels/pixel_ship_green_small_2.png",
		"ship_scale": 0.28
	},
	{
		"name": "Blaze",
		"sprite": "res://spacepixels/ship_orange.png",
		"health": 2,
		"fire_rate": 0.22,
		"laser_texture": "res://spacepixels/pixel_laser_yellow.png",
		"damage": 2,
		"speed": 120,
		"color": "orange",
		"small_sprite": "res://spacepixels/pixel_ship_red_small_2.png",
		"ship_scale": 0.28
	},
	{
		"name": "Phantom",
		"sprite": "res://spacepixels/ship_purple.png",
		"health": 3,
		"fire_rate": 0.32,
		"laser_texture": "res://spacepixels/pixel_laser_blue.png",
		"damage": 1,
		"speed": 110,
		"color": "purple",
		"small_sprite": "res://spacepixels/pixel_ship_blue_small.png",
		"ship_scale": 0.28
	},
	{
		"name": "Sentinel",
		"sprite": "res://spacepixels/pixel_ship_blue.png",
		"health": 4,
		"fire_rate": 0.38,
		"laser_texture": "res://spacepixels/pixel_laser_blue.png",
		"damage": 1,
		"speed": 95,
		"color": "blue",
		"small_sprite": "res://spacepixels/pixel_ship_blue_small.png",
		"ship_scale": 0.26
	}
]

func get_selected_ship() -> Dictionary:
	return ships[selected_ship_id]

func get_non_selected_ships() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in ships.size():
		if i != selected_ship_id:
			result.append(ships[i])
	return result

func reset_for_new_game() -> void:
	boss_fights_completed = 0
	enemies_killed_since_boss = 0
