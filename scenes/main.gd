extends Node

#preload obstacles
var snow_stone1 = preload("res://scenes/snow_stone1.tscn")
var snow_stone2 = preload("res://scenes/snow_stone2.tscn")
var black_cone = preload("res://scenes/black_cone.tscn")

var brick = preload("res://scenes/brick.tscn")
var fence = preload("res://scenes/fence.tscn")

var red_cone = preload("res://scenes/red_cone.tscn")
var pink_cone = preload("res://scenes/pink_cone.tscn")

var snowball = preload("res://scenes/snowball.tscn")
var brown_paper_plane = preload("res://scenes/brown_paper_plane.tscn")
var balloon = preload("res://scenes/balloon.tscn")

var lvl1_obstacle_types := [snow_stone1, snow_stone2, black_cone]
var lvl2_obstacle_types := [brick, fence]
var lvl3_obstacle_types := [red_cone, pink_cone]

var obstacles : Array
var bird_heights := [200, 300]

#game variables
const DINO_START_POS := Vector2i(150, 200)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 20
const SPEED_MODIFIER : int = 5000
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var level_opened : bool
var last_obs

@export var current_level : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$BGM.play()
	screen_size = get_window().size
	level_opened = false
	#ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	$GameOver.get_node("Button2").pressed.connect(back_to_photobook)

	$Photobook.get_node("Sprite2D/TextureButton").pressed.connect(level1)
	$Photobook.get_node("Sprite2D/TextureButton2").pressed.connect(level2)
	$Photobook.get_node("Sprite2D/TextureButton3").pressed.connect(level3)
	$HUD.hide()
	$Dino.hide()
	$GameOver.hide()
	
func back_to_photobook():
	level_opened = false
	$HUD.hide()
	$Dino.hide()
	$GameOver.hide()
	new_game()
	$Photobook.show()

	
func level1():
	$Bg.get_node("ParallaxLayer2/Sprite2D").texture = load("res://assets/img/background/lvl1_bg2.png")
	$Bg.get_node("ParallaxLayer/Sprite2D").texture = load("res://assets/img/background/lvl1_bg1.png")
	$Bg.get_node("Sprite2D").texture = load("res://assets/img/background/lvl1_backdrop.png")
		
	current_level = 1
	$Dino.lvl_number = 1
	level_opened = true
	$Photobook.hide()
	$HUD.show()
	$Dino.show()
	new_game()

func level2():
	$Bg.get_node("ParallaxLayer2/Sprite2D").texture = load("res://assets/img/background/lvl2_bg2.png")
	$Bg.get_node("ParallaxLayer/Sprite2D").texture = load("res://assets/img/background/lvl2_bg1.png")
	$Bg.get_node("Sprite2D").texture = load("res://assets/img/background/lvl2_backdrop.png")
	current_level = 2
	$Dino.lvl_number = 2
	level_opened = true
	$Photobook.hide()
	$HUD.show()
	$Dino.show()
	new_game()

func level3():
	$Bg.get_node("ParallaxLayer2/Sprite2D").texture = load("res://assets/img/background/lvl3_bg2.png")
	$Bg.get_node("ParallaxLayer/Sprite2D").texture = load("res://assets/img/background/lvl3_bg1.png")
	$Bg.get_node("Sprite2D").texture = load("res://assets/img/background/lvl3_backdrop.png")
	current_level = 3
	$Dino.lvl_number = 3
	level_opened = true
	$Photobook.hide()
	$HUD.show()
	$Dino.show()
	new_game()

func new_game():
	#reset variables
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	#delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#reset the nodes
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	#reset hud and game over screen
	$HUD.get_node("StartLabel").show()
	if current_level == 1:
		$HUD.get_node("Goal").text = "SNAP A PHOTO WITH BILLY AND HIS SNOWMAN!" 
	elif current_level == 2:
		$HUD.get_node("Goal").text = "LATE FOR A DATE! SNAP A PHOTO WITH ELIZABETH AT THE DRIVE-IN CINEMA" 
	else:
		$HUD.get_node("Goal").text = "YOU'RE A GRANDPA! SNAP A PHOTO WITH THE BUNDLE OF JOY" 
		
	$HUD.get_node("Goal").show()
	$GameOver.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		#speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		#generate obstacles
		generate_obs()
		
		#move dino and camera
		$Dino.position.x += speed
		$Camera2D.position.x += speed
		
		#update score
		score += speed
		show_score()
		
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		#remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if level_opened:
			if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("left_click"):
				game_running = true
				$HUD.get_node("StartLabel").hide()
				$HUD.get_node("Goal").hide()

func generate_obs():
	#generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type
		
		if current_level == 1:
			obs_type = lvl1_obstacle_types[randi() % lvl1_obstacle_types.size()]
		elif current_level == 2:
			obs_type = lvl2_obstacle_types[randi() % lvl2_obstacle_types.size()]
		else:
			obs_type = lvl3_obstacle_types[randi() % lvl3_obstacle_types.size()]
		
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = 850 - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		#additionally random chance to spawn a bird
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#generate bird obstacles
				if current_level == 1:
					obs = snowball.instantiate()
				elif current_level == 2:
					obs = brown_paper_plane.instantiate()
				else:
					obs = balloon.instantiate()

				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "Dino":
		game_over()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		#$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
