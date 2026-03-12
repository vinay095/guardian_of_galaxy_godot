extends Node

# Boss manager - handles boss fight phases with time + kills based triggers

signal boss_fight_started()
signal boss_fight_ended()
signal asteroid_shower_started()
signal asteroid_shower_ended()

@export var game_stats: GameStats

var MiniBossScene = preload("res://enemies/mini_boss.tscn")
var AllyShipScene = preload("res://player_ship/ally_ship.tscn")

var is_boss_fight: bool = false
var is_asteroid_shower: bool = false
var active_bosses: Array[Node] = []
var ally_ship: Node2D = null

var time_since_last_boss: float = 0.0
var boss_trigger_time: float = 0.0 # Randomized each cycle
var kills_needed: int = 0 # Randomized each cycle

var boss_wave_number: int = 0

func _ready() -> void:
	_reset_boss_trigger()

func _reset_boss_trigger() -> void:
	time_since_last_boss = 0.0
	boss_trigger_time = randf_range(120.0, 240.0) # 2-4 minutes
	kills_needed = randi_range(40, 60)
	ShipData.enemies_killed_since_boss = 0

func _process(delta: float) -> void:
	if is_boss_fight:
		_check_boss_fight_complete()
		return
	
	time_since_last_boss += delta
	
	# Check if boss fight should trigger (time AND kills)
	if time_since_last_boss >= boss_trigger_time and ShipData.enemies_killed_since_boss >= kills_needed:
		start_boss_fight()

func start_boss_fight() -> void:
	if is_boss_fight:
		return
	
	is_boss_fight = true
	boss_wave_number += 1
	
	# End any asteroid shower
	if is_asteroid_shower:
		is_asteroid_shower = false
		asteroid_shower_ended.emit()
	
	boss_fight_started.emit()
	
	# Switch music
	MusicPlayer.play_boss()
	
	# Spawn bosses with some delay between them
	var non_selected = ShipData.get_non_selected_ships()
	var num_bosses = min(non_selected.size(), randi_range(2, 3))
	
	# Shuffle and pick random bosses
	non_selected.shuffle()
	
	for i in num_bosses:
		# Stagger boss spawns
		var spawn_delay = randf_range(0.5, 2.0) * i
		_spawn_boss_delayed(non_selected[i], spawn_delay)
	
	# Spawn ally ship
	_spawn_ally()

func _spawn_boss_delayed(ship_config: Dictionary, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if not is_inside_tree():
		return
	
	var boss = MiniBossScene.instantiate()
	var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var spawn_x = randf_range(20, screen_width - 20)
	
	get_tree().current_scene.add_child(boss)
	boss.global_position = Vector2(spawn_x, -20)
	
	# Set the sprite and scale
	boss.set_boss_sprite(ship_config)
	
	# Scale difficulty with wave number
	var health_bonus = boss_wave_number * 3
	boss.stats_component.health += health_bonus
	
	active_bosses.append(boss)
	boss.tree_exiting.connect(func(): active_bosses.erase(boss))

func _spawn_ally() -> void:
	if ally_ship and is_instance_valid(ally_ship):
		return
	
	ally_ship = AllyShipScene.instantiate()
	get_tree().current_scene.add_child(ally_ship)
	
	# Position near player
	var player_ships = get_tree().get_nodes_in_group("player")
	if player_ships.size() > 0:
		ally_ship.global_position = player_ships[0].global_position + Vector2(-15, 10)

func _check_boss_fight_complete() -> void:
	# Remove invalid references
	active_bosses = active_bosses.filter(func(b): return is_instance_valid(b))
	
	if active_bosses.size() == 0 and is_boss_fight:
		_end_boss_fight()

func _end_boss_fight() -> void:
	is_boss_fight = false
	ShipData.boss_fights_completed += 1
	
	# Award bonus points
	game_stats.score += 100
	
	# Switch back to normal music
	MusicPlayer.play_normal()
	
	# Remove ally
	if ally_ship and is_instance_valid(ally_ship):
		ally_ship.queue_free()
		ally_ship = null
	
	boss_fight_ended.emit()
	_reset_boss_trigger()

func start_asteroid_shower() -> void:
	if is_boss_fight or is_asteroid_shower:
		return
	is_asteroid_shower = true
	asteroid_shower_started.emit()
	
	# Shower lasts 15-25 seconds
	var duration = randf_range(15.0, 25.0)
	await get_tree().create_timer(duration).timeout
	if is_asteroid_shower:
		is_asteroid_shower = false
		asteroid_shower_ended.emit()
