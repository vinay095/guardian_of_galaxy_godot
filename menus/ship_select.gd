extends Control

var current_selection: int = 0
var ship_sprites: Array[Sprite2D] = []
var ship_labels: Array[Label] = []
var stat_labels: Array[Label] = []
var selector_indicator: Label

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
	instructions.text = "< Arrows >  Space = Go"
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.position = Vector2(0, 220)
	instructions.size = Vector2(160, 16)
	instructions.label_settings = load("res://fonts/default_label_settings.tres")
	add_child(instructions)
	
	# Ship display - all 4 in a single horizontal line
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
		
		# Ship name
		var name_label = Label.new()
		name_label.text = ship["name"]
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.position = Vector2(x_pos - 18, y_pos + 20)
		name_label.size = Vector2(36, 12)
		name_label.label_settings = load("res://fonts/default_label_settings.tres")
		add_child(name_label)
		ship_labels.append(name_label)
		
		# Stats below name
		var stats_label = Label.new()
		stats_label.text = "HP:" + str(ship["health"]) + "\nDMG:" + str(ship["damage"]) + "\nSPD:" + str(ship["speed"])
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stats_label.position = Vector2(x_pos - 18, y_pos + 34)
		stats_label.size = Vector2(36, 36)
		stats_label.label_settings = load("res://fonts/default_label_settings.tres")
		add_child(stats_label)
		stat_labels.append(stats_label)
	
	# Selection indicator (arrow below ship)
	selector_indicator = Label.new()
	selector_indicator.text = "^"
	selector_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selector_indicator.label_settings = load("res://fonts/default_label_settings.tres")
	selector_indicator.size = Vector2(20, 12)
	add_child(selector_indicator)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		current_selection = (current_selection - 1)
		if current_selection < 0:
			current_selection = ShipData.ships.size() - 1
		_update_selection()
	elif Input.is_action_just_pressed("ui_right"):
		current_selection = (current_selection + 1) % ShipData.ships.size()
		_update_selection()
	elif Input.is_action_just_pressed("ui_accept"):
		ShipData.selected_ship_id = current_selection
		ShipData.reset_for_new_game()
		get_tree().change_scene_to_file("res://world.tscn")

func _update_selection() -> void:
	# Highlight selected ship, dim others
	for i in ship_sprites.size():
		if i == current_selection:
			ship_sprites[i].modulate = Color.WHITE
			ship_labels[i].modulate = Color.YELLOW
			stat_labels[i].modulate = Color.WHITE
		else:
			ship_sprites[i].modulate = Color(0.4, 0.4, 0.4, 1.0)
			ship_labels[i].modulate = Color(0.4, 0.4, 0.4, 1.0)
			stat_labels[i].modulate = Color(0.35, 0.35, 0.35, 1.0)
	
	# Move selector indicator below selected ship
	var total_ships = ShipData.ships.size()
	var spacing = 160.0 / total_ships
	var x_pos = spacing * 0.5 + current_selection * spacing
	selector_indicator.position = Vector2(x_pos - 10, 65)
