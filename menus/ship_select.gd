extends Control

var current_selection: int = 0
var ship_sprites: Array[Sprite2D] = []
var selector_indicator: Label
var current_ship_name_label: Label
var current_ship_stats_label: Label

func _ready() -> void:
	_build_ui()
	_update_selection()

func _build_ui() -> void:
	# Title
	var title = Label.new()
	title.text = "SELECT YOUR SHIP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 15)
	title.size = Vector2(160, 20)
	title.label_settings = load("res://fonts/title_label_settings.tres")
	add_child(title)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = "< Tap sides to choose >\nTap here to Start"
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	instructions.position = Vector2(0, 200)
	instructions.size = Vector2(160, 40)
	instructions.label_settings = load("res://fonts/default_label_settings.tres")
	add_child(instructions)
	
	# One name label
	current_ship_name_label = Label.new()
	current_ship_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_ship_name_label.position = Vector2(0, 120)
	current_ship_name_label.size = Vector2(160, 12)
	current_ship_name_label.label_settings = load("res://fonts/default_label_settings.tres")
	# Change color to yellow
	current_ship_name_label.modulate = Color.YELLOW
	add_child(current_ship_name_label)
	
	# One stats label
	current_ship_stats_label = Label.new()
	current_ship_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_ship_stats_label.position = Vector2(0, 140)
	current_ship_stats_label.size = Vector2(160, 40)
	current_ship_stats_label.label_settings = load("res://fonts/default_label_settings.tres")
	add_child(current_ship_stats_label)

	# Ship display - all in a single horizontal line
	var ships = ShipData.ships
	var total_ships = ships.size()
	var spacing = 160.0 / total_ships  # Even spacing across 160px width
	
	for i in total_ships:
		var ship = ships[i]
		var x_pos = spacing * 0.5 + i * spacing  # Center each in its column
		var y_pos = 80  # Single row, vertically centered
		
		# Ship sprite
		var sprite = Sprite2D.new()
		sprite.texture = load(ship["sprite"])
		sprite.position = Vector2(x_pos, y_pos)
		sprite.scale = Vector2(ship["ship_scale"], ship["ship_scale"])  # actual game size
		add_child(sprite)
		ship_sprites.append(sprite)
	
	# Selection indicator (arrow below ship)
	selector_indicator = Label.new()
	selector_indicator.text = "^"
	selector_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selector_indicator.label_settings = load("res://fonts/default_label_settings.tres")
	selector_indicator.size = Vector2(20, 12)
	add_child(selector_indicator)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		_change_selection(-1)
	elif Input.is_action_just_pressed("ui_right"):
		_change_selection(1)
	elif Input.is_action_just_pressed("ui_accept"):
		_start_game()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		var touch_y = event.position.y
		var touch_x = event.position.x
		if touch_y > 170:
			_start_game()
		else:
			if touch_x < 80:
				_change_selection(-1)
			else:
				_change_selection(1)

func _change_selection(dir: int) -> void:
	current_selection += dir
	if current_selection < 0:
		current_selection = ShipData.ships.size() - 1
	elif current_selection >= ShipData.ships.size():
		current_selection = 0
	_update_selection()

func _start_game() -> void:
	ShipData.selected_ship_id = current_selection
	ShipData.reset_for_new_game()
	get_tree().change_scene_to_file("res://world.tscn")

func _update_selection() -> void:
	var ship = ShipData.ships[current_selection]
	current_ship_name_label.text = "- " + ship["name"] + " -"
	current_ship_stats_label.text = "HP: " + str(ship["health"]) + "\nDMG: " + str(ship["damage"]) + "\nSPD: " + str(ship["speed"])

	# Highlight selected ship, dim others
	for i in ship_sprites.size():
		if i == current_selection:
			ship_sprites[i].modulate = Color.WHITE
		else:
			ship_sprites[i].modulate = Color(0.4, 0.4, 0.4, 1.0)
	
	# Move selector indicator below selected ship
	var total_ships = ShipData.ships.size()
	var spacing = 160.0 / total_ships
	var x_pos = spacing * 0.5 + current_selection * spacing
	selector_indicator.position = Vector2(x_pos - 10, 65)
