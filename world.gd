extends Node2D

@export var game_stats: GameStats

@onready var ship: Node2D = $Ship
@onready var score_label: Label = $ScoreLabel
@onready var space_background = $SpaceBackground
@onready var enemy_generator = $EnemyGenerator
@onready var boss_manager = $BossManager
@onready var special_label: Label = $SpecialLabel
@onready var asteroid_shower_timer: Timer = $AsteroidShowerTimer

var current_phase: String = "normal" # normal, asteroid_shower, boss_fight
var has_buffed_player: bool = false

func _ready() -> void:
	randomize()
	
	# Reset score for new game
	game_stats.score = 0
	update_score_label(game_stats.score)
	game_stats.score_changed.connect(update_score_label)
	
	# Add player to group so ally/boss can find it
	ship.add_to_group("player")
	
	# Game over on ship death
	ship.tree_exiting.connect(func():
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://menus/game_over.tscn")
	)
	
	# Boss manager signals
	boss_manager.boss_fight_started.connect(_on_boss_fight_started)
	boss_manager.boss_fight_ended.connect(_on_boss_fight_ended)
	boss_manager.asteroid_shower_started.connect(_on_asteroid_shower_started)
	boss_manager.asteroid_shower_ended.connect(_on_asteroid_shower_ended)
	
	# Random asteroid showers
	asteroid_shower_timer.timeout.connect(_trigger_asteroid_shower)
	asteroid_shower_timer.start(randf_range(45.0, 75.0))
	
	# Special attack UI
	special_label.text = "X: BOOST"
	special_label.modulate = Color.GREEN

	# Add TouchScreenButton for mobile boost
	var touch_btn = TouchScreenButton.new()
	touch_btn.action = "special_attack"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(160, 60)
	touch_btn.shape = shape
	touch_btn.position = Vector2(80, 210)
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	canvas_layer.add_child(touch_btn)
	add_child(canvas_layer)

func update_score_label(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)
	if new_score >= 2000 and not has_buffed_player:
		has_buffed_player = true
		if ship and is_instance_valid(ship):
			ship.has_attack_buff = true
			ship.fire_rate_timer.wait_time /= 1.2
			# Force a restart of the timer if needed, but it will pick up next cycle naturally

func _process(_delta: float) -> void:
	# Update special attack indicator
	if ship and is_instance_valid(ship):
		if ship.is_special_active:
			special_label.text = "BOOSTING!"
			special_label.modulate = Color.CYAN
		elif ship.can_use_special:
			special_label.text = "X: BOOST"
			special_label.modulate = Color.GREEN
		else:
			var pct = int(ship.boost_charge * 100)
			special_label.text = "X: " + str(pct) + "%"
			special_label.modulate = Color(0.5, 0.5, 0.5).lerp(Color.GREEN, ship.boost_charge)

func _on_boss_fight_started() -> void:
	current_phase = "boss_fight"
	space_background.change_background("red")
	enemy_generator.pause_spawning()

func _on_boss_fight_ended() -> void:
	current_phase = "normal"
	space_background.change_background("black")
	enemy_generator.resume_spawning()

func _on_asteroid_shower_started() -> void:
	current_phase = "asteroid_shower"
	space_background.change_background("purple")

func _on_asteroid_shower_ended() -> void:
	current_phase = "normal"
	space_background.change_background("black")

func _trigger_asteroid_shower() -> void:
	if current_phase == "normal":
		boss_manager.start_asteroid_shower()
	# Schedule next shower
	asteroid_shower_timer.start(randf_range(60.0, 90.0))
