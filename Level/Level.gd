class_name Level extends Control

@export var min_number: int = 0
@export var max_number: int = 10

@onready var lane_packed = preload("res://Level/Lane/Lane.tscn")

@onready var player_number_label = get_node("VBoxContainer/Panel/VBoxContainer/HBoxContainer/Problem/Problem/player_number")
@onready var target_number_label = get_node("VBoxContainer/Panel/VBoxContainer/HBoxContainer/Problem/Problem/target_number")

@onready var operand_label = get_node("VBoxContainer/Panel/VBoxContainer/HBoxContainer/Problem/Problem/operand")
@onready var variable_label = get_node("VBoxContainer/Panel/VBoxContainer/HBoxContainer/Problem/Problem/variable")

const max_width = 800
const color_even = Color.LIME_GREEN
const color_odd = Color.WEB_GREEN

var panel_height = 200

var player_position: int = 0
var target_position: int = 1
var variable
var operand: String
var num_right = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().size_changed.connect(resize)
	create_lanes()
	init_numbers()
	generate_problems()
	position_player(player_position)
	next_problem()
	panel_height = $VBoxContainer/Panel.custom_minimum_size.y

var problems = {}
var problem_indeces = []
func generate_problems():
	for i in (max_number + 1):
		problems[i] = []
		problem_indeces.append(0)
		for j in (max_number + 1):
			if i + j <= max_number or i - j >= min_number:
				problems[i].append(j)
		problems[i].shuffle()

func init_numbers():
	for i in range(min_number, max_number+1):
		var new_number = Button.new()
		new_number.text = str(i)
		new_number.connect("pressed", select_variable.bind(i))
		$VBoxContainer/Panel/VBoxContainer/HBoxContainer/Buttons/Numbers.add_child(new_number)

func select_operand(_operand: String):
	operand = _operand
	operand_label.text = _operand

func select_variable(_variable: int):
	variable = _variable
	variable_label.text = str(_variable)

func execute_problem():
	if variable == null:
		return
	if operand == "+":
		player_position += variable
	elif operand == "-":
		player_position -= variable
	else:
		return
	var new_position = get_new_player_position(player_position)
	var tween = get_tree().create_tween()
	tween.tween_property($Player, "position", new_position, variable * .2)
	tween.tween_callback(throw_food)

func throw_food():
	# put cereal to player's location
	$DogFood.global_position = $Player.global_position
	$DogFood.visible = true
	# tween it up
	var tween = get_tree().create_tween()
	tween.tween_property($DogFood, "position", Vector2($DogFood.position.x, 120), .4)
	tween.tween_callback(catch_food)

func catch_food():
	$DogFood.visible = false
	if (player_position == target_position):
		$Rocket.dance(next_problem)
		num_right += 1
		add_score()
	else:
		$Rocket.nope(next_problem)

# assumes min number is 0
func next_problem():
	fix_player_position()
	var target_value_index = problem_indeces[player_position]
	var target = problems[player_position][target_value_index]
	problem_indeces[player_position] += 1
	if problem_indeces[player_position] > problems[player_position].size():
		problem_indeces[player_position] = 0
	target_position = target
	move_target(target_position)

func fix_player_position():
	if player_position < min_number:
		player_position = 0
		position_player(player_position)
	elif player_position> max_number:
		player_position = max_number
		position_player(player_position)

func resize():
	position_player(player_position)
	position_target(target_position)

func create_lanes():
	for i in range(min_number, max_number+1):
		var lane = lane_packed.instantiate()
		lane.number = i
		if i % 2 == 0:
			lane.color = color_even
		else:
			lane.color = color_odd
		$VBoxContainer/Lanes.add_child(lane)

func position_player(number: int):
	var new_pos = get_new_player_position(number)
	$Player.position = new_pos
	player_number_label.text = str(number)

func get_new_player_position(number: int):
	var lane_width = (DisplayServer.window_get_size().x)/((max_number - min_number)+1.0)
	var x = (number * lane_width) + (lane_width/2.0)
	var y = DisplayServer.window_get_size().y - panel_height - 140
	return Vector2(float(x), float(y))

func move_target(number: int):
	var diff = abs(target_position - number)
	var new_position = get_new_target_position(target_position)
	var tween = get_tree().create_tween()
	tween.tween_property($Rocket, "position", new_position, diff*1)
	target_number_label.text = str(target_position)
	tween.tween_callback(show_new_question)

func get_new_target_position(number: int):
	var lane_width = (DisplayServer.window_get_size().x)/((max_number - min_number)+1.0)
	var x = (number * lane_width) + (lane_width/2.0)
	var y = 120
	return Vector2(float(x), float(y))

func show_new_question():
	player_number_label.text = str(player_position)
	operand_label.text = ""
	operand = ""
	variable_label.text = ""
	variable = null

func position_target(number: int):
	var lane_width = (DisplayServer.window_get_size().x)/((max_number-min_number)+1.0)
	$Rocket.global_position.x = (number * lane_width) + (lane_width/2.0)
	$Rocket.global_position.y = 120
	target_number_label.text = str(number)

func add_score():
	var sprite = Sprite2D.new()
	sprite.texture = load("res://Images/Rocket.png")
	sprite.scale = Vector2(.15, .15)
	sprite.centered = false
	var con = Control.new()
	con.add_child(sprite)
	con.custom_minimum_size.x = 60
	$VBoxContainer/Panel/VBoxContainer/Score.add_child(con)
