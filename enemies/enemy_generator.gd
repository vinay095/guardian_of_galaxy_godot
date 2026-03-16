extends Node2D

@export var GreenEnemyScene: PackedScene
@export var YellowEnemyScene: PackedScene
@export var PinkEnemyScene: PackedScene
@export var game_stats: GameStats

var AsteroidScene = preload("res://enemies/asteroid.tscn")

var PixelStationScene = preload("res://enemies/pixel_station.tscn")

var margin = 8
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")

# Max entities scales with score: starts at 2, reaches MAX_ENTITIES at 1000 pts
const MAX_ENTITIES = 8
const SCORE_FOR_MAX = 1000.0
var spawning_enabled: bool = true

@onready var spawner_component := $SpawnerComponent as SpawnerComponent
@onready var green_enemy_spawn_timer: Timer = $GreenEnemySpawnTimer
@onready var yellow_enemy_spawn_timer: Timer = $YellowEnemySpawnTimer
@onready var pink_enemy_spawn_timer: Timer = $PinkEnemySpawnTimer
@onready var asteroid_spawn_timer: Timer = $AsteroidSpawnTimer

@onready var station_spawn_timer: Timer = $StationSpawnTimer

var active_stations: int = 0

func _ready() -> void:
	green_enemy_spawn_timer.timeout.connect(_spawn_green)
	yellow_enemy_spawn_timer.timeout.connect(_spawn_yellow)
	pink_enemy_spawn_timer.timeout.connect(_spawn_pink)
	asteroid_spawn_timer.timeout.connect(_spawn_asteroid)

	station_spawn_timer.timeout.connect(_spawn_station)

# How many total entities are allowed right now based on score
func get_current_max() -> int:
	var score = game_stats.score
	# Linear scale: 2 at score 0, up to MAX_ENTITIES at SCORE_FOR_MAX
	var t = clampf(score / SCORE_FOR_MAX, 0.0, 1.0)
	return int(lerp(2.0, float(MAX_ENTITIES), t))

func get_entity_count() -> int:
	var count = 0
	for child in get_tree().current_scene.get_children():
		if child is Enemy \
		or child.is_in_group("asteroid") \
		or child.is_in_group("station"):
			count += 1
	return count

func is_crowded() -> bool:
	return get_entity_count() >= get_current_max()

func _spawn_at_random_x(scene: PackedScene, y: float = -16.0) -> Node:
	spawner_component.scene = scene
	return spawner_component.spawn(Vector2(randf_range(margin, screen_width - margin), y))

func _track_kill(enemy: Node) -> void:
	# Track kill for boss trigger
	if enemy.has_node("StatsComponent"):
		var stats = enemy.get_node("StatsComponent")
		stats.no_health.connect(func():
			ShipData.enemies_killed_since_boss += 1
		)

# ------- Green enemy: fast (40 px/s), weak (3HP) -------
func _spawn_green() -> void:
	var next = _calc_interval(2.5, 1.5)
	if not spawning_enabled or is_crowded():
		green_enemy_spawn_timer.start(next)
		return
	var e = _spawn_at_random_x(GreenEnemyScene)
	# Speed already 40 in tscn
	_track_kill(e)
	green_enemy_spawn_timer.start(next)

# ------- Yellow enemy: medium speed (28 px/s), medium (3HP) -------
func _spawn_yellow() -> void:
	if game_stats.score < 30:
		yellow_enemy_spawn_timer.start(3.0)
		return
	var next = _calc_interval(5.0, 3.0)
	if not spawning_enabled or is_crowded():
		yellow_enemy_spawn_timer.start(next)
		return
	var e = _spawn_at_random_x(YellowEnemyScene)
	_set_speed(e, 28.0)
	_track_kill(e)
	yellow_enemy_spawn_timer.start(next)

# ------- Pink enemy: slow (15 px/s), tanky (4HP) -------
func _spawn_pink() -> void:
	if game_stats.score < 80:
		pink_enemy_spawn_timer.start(5.0)
		return
	var next = _calc_interval(8.0, 5.0)
	if not spawning_enabled or is_crowded():
		pink_enemy_spawn_timer.start(next)
		return
	var e = _spawn_at_random_x(PinkEnemyScene)
	_set_speed(e, 15.0)
	_track_kill(e)
	pink_enemy_spawn_timer.start(next)

# ------- Asteroid: diagonal, moderate speed -------
func _spawn_asteroid() -> void:
	var next = _calc_interval(8.0, 4.0)
	if not spawning_enabled or is_crowded():
		asteroid_spawn_timer.start(next)
		return
	var asteroid = AsteroidScene.instantiate()
	get_tree().current_scene.add_child(asteroid)
	asteroid.global_position = Vector2(randf_range(margin, screen_width - margin), -16)
	asteroid.add_to_group("asteroid")
	asteroid_spawn_timer.start(next)



# ------- Pixel station: unlocked after 2 boss clears -------
func _spawn_station() -> void:
	if ShipData.boss_fights_completed < 2:
		station_spawn_timer.start(10.0)
		return
	if not spawning_enabled or active_stations >= 2 or is_crowded():
		station_spawn_timer.start(15.0)
		return
	var station = PixelStationScene.instantiate()
	get_tree().current_scene.add_child(station)
	station.add_to_group("station")
	# Spawn at screen edge
	var side = randi() % 4
	match side:
		0: station.global_position = Vector2(8, randf_range(20, 150))
		1: station.global_position = Vector2(screen_width - 8, randf_range(20, 150))
		2: station.global_position = Vector2(randf_range(20, screen_width - 20), 15)
		3: station.global_position = Vector2([15, screen_width - 15].pick_random(), 20)
	active_stations += 1
	station.tree_exiting.connect(func(): active_stations -= 1)
	station_spawn_timer.start(randf_range(25.0, 40.0))

# Calculate spawn interval: starts long, decreases with score, has random jitter
func _calc_interval(base_high: float, base_low: float) -> float:
	var t = clampf(game_stats.score / SCORE_FOR_MAX, 0.0, 1.0)
	var interval = lerp(base_high, base_low, t)
	return interval + randf_range(-0.3, 0.5)

func _set_speed(entity: Node, speed: float) -> void:
	# Direct MoveComponent (green, yellow)
	if entity.has_node("MoveComponent"):
		var mc = entity.get_node("MoveComponent")
		if mc.velocity.y != 0:
			mc.velocity.y = speed
	# Pink enemy: nested inside States/MoveDownState
	if entity.has_node("States/MoveDownState/MoveComponent"):
		var mc = entity.get_node("States/MoveDownState/MoveComponent")
		if mc.velocity.y != 0:
			mc.velocity.y = speed

func pause_spawning() -> void:
	spawning_enabled = false

func resume_spawning() -> void:
	spawning_enabled = true
