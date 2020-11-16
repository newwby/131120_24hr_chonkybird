extends Node2D

export var obstacle_satellite: PackedScene
export var obstacle_asteroid: PackedScene
export var pickup: PackedScene

var BASE_BARRIER_SCALE: float = 1.45
var BASE_BARRIER_SPAWN_TIMER: float = 5.0
var barrier_spawn_timer: float = BASE_BARRIER_SPAWN_TIMER
const BASE_LEVEL_SCROLL_SPEED: int = 50
var level_scroll_speed: int = BASE_LEVEL_SCROLL_SPEED

var difficulty_level: int = 0
var spawn_food: bool = false

onready var black_bkg = $Darkness
onready var black_bkg_fade_tween = $FadeTweenBKG
onready var ui_player_fade_tween = $FadeTweenUI_Player
onready var HUD = $CanvasLayer
onready var HUD_LifeBar = $CanvasLayer/UI_LifeBar
onready var HUD_ScoreTimer = $CanvasLayer/UI_ScoreTimer
onready var HUD_GameOver = $CC_GameOver
onready var HUD_Button_PlayAgain = $CC_GameOver/VBox/HBox3/Button_PlayAgain
onready var HUD_Button_QuitGame = $CC_GameOver/VBox/HBox3/Button_QuitGame

onready var player_node = $Player
onready var player_start_pos = $PlayerStart

onready var spawn_holder_node = $Spawns
onready var spawn_timer = $SpawnBarrierTimer
onready var difficulty_timer = $DifficultyTimer
const BASE_DIFFICULTY_TIMER_WAIT: float = 4.0

## --------------------------------------------------------------------------
## STARTING A NEW GAME

# Called when the node enters the scene tree for the first time.
func _ready():
	initialise_new_game()
	_on_spawn_barrier_timeout()
	#_on_Player_game_over()
	player_node.apply_impulse(Vector2(), Vector2(1,0)*10)

func initialise_new_game():
	randomize()
	player_node.position = player_start_pos.position
	player_node.food_level = player_node.BASE_FOOD_LEVEL
	player_node.emit_signal("food_value_change", player_node.food_level)
	HUD_ScoreTimer.score_label.text = "0"
	HUD_ScoreTimer.score = 0
	spawn_timer.wait_time = BASE_BARRIER_SPAWN_TIMER
	spawn_timer.start()
	difficulty_timer.wait_time = BASE_DIFFICULTY_TIMER_WAIT
	player_node.apply_impulse(Vector2(), Vector2(0,1))

func reset_game():
	handle_timers(false)
	game_over_fade(false)
	difficulty_level = 0

## --------------------------------------------------------------------------
## SPAWNING OBSTACLES AND COLLECTABLES

func _on_spawn_barrier_timeout():
	var random_chance = randi()%2
	var timer_variance = float(randi()%15) * 0.1
	
	if difficulty_level != 0:
		spawn_timer.wait_time = BASE_BARRIER_SPAWN_TIMER - timer_variance - float(difficulty_level*0.2)
	else:
		spawn_timer.wait_time = BASE_BARRIER_SPAWN_TIMER - timer_variance
	spawn_timer.wait_time = spawn_timer.wait_time * 0.5
	
	spawn_food = !spawn_food
	if random_chance == 1:
		if spawn_food:
			spawn_pickup(true)
		else:
			spawn_barrier(true)
	else:
		if spawn_food:
			spawn_pickup(false)
		else:
			spawn_barrier(false)

func spawn_barrier(spawn_asteroid: bool):
	var new_barrier
	if not spawn_asteroid:
		new_barrier = obstacle_satellite.instance()
	else:
		new_barrier = obstacle_asteroid.instance()
		
	spawn_holder_node.add_child(new_barrier)
	new_barrier.move_rate = level_scroll_speed
	var random_scale_modifier = float(randi()%30) * 0.1
	
	new_barrier.scale.y = BASE_BARRIER_SCALE + random_scale_modifier + float(difficulty_level * 0.01)
	if new_barrier.scale.y > 0.9:
		new_barrier.scale.y = 0.9
	
	var rand_position_y = ((randi()%35)+1)*10
	new_barrier.position = $position_upper.position
	new_barrier.position.y = rand_position_y

func spawn_pickup(spawn_top: bool):
	var new_food = pickup.instance()
	spawn_holder_node.add_child(new_food)
	
	var random_axis_distribution = (15+(randi()%42))*2
	var random_chance = randi()%2
	if random_chance == 1:
		random_axis_distribution = -random_axis_distribution
	
	new_food.move_rate = level_scroll_speed
	if spawn_top:
		new_food.position = $position_upper.position
		new_food.position.y += 250 + random_axis_distribution
	else:
		new_food.position = $position_lower.position
		new_food.position.y -= 250 + random_axis_distribution
	new_food.run_tween()

## --------------------------------------------------------------------------
# TIMEOUT FUNCS

func handle_timers(stop:bool = true):
	if stop:
		spawn_timer.stop()
		difficulty_timer.stop()
	else:
		spawn_timer.start()
		difficulty_timer.start()

func difficulty_increase():
	difficulty_level += 1
	level_scroll_speed = BASE_LEVEL_SCROLL_SPEED + (difficulty_level*4)
	difficulty_timer.wait_time = BASE_DIFFICULTY_TIMER_WAIT + float(difficulty_level*0.5)
	spawn_timer.wait_time = BASE_BARRIER_SPAWN_TIMER - float(difficulty_level*0.2)
	spawn_timer.wait_time = spawn_timer.wait_time * 0.5
	
func _on_DifficultyTimer_timeout():
	difficulty_increase()


## --------------------------------------------------------------------------
# BUTTON FUNCS

func _on_Button_PlayAgain_pressed():
	reset_game()
	
func _on_Button_QuitGame_pressed():
	get_tree().quit()
	

## --------------------------------------------------------------------------
# ANIMATE FUNCS

func _on_FadeTweenBKG_tween_all_completed():
	if not player_node.is_active:
		player_node.gravity_scale = 0
		delete_all_spawned()
		var fade_dur: float = 1.0
		HUD_GameOver.modulate.a = 0
		HUD_GameOver.visible = true
		ui_player_fade_tween.interpolate_property(HUD_GameOver, "modulate", Color(1,1,1,0), Color(1,1,1,1), fade_dur*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		ui_player_fade_tween.start()
	else:
		fade_in_UI()
		initialise_new_game()
		_on_spawn_barrier_timeout()
		player_node.gravity_scale = 1.0
		player_node.apply_impulse(Vector2(), Vector2(1,0)*200)

func handle_buttons(turn_off:bool = true):
	HUD_Button_PlayAgain.disabled = turn_off
	HUD_Button_QuitGame.disabled = turn_off

func fade_in_UI():
	var fade_dur = 0.5
	ui_player_fade_tween.interpolate_property(HUD_GameOver, "modulate", Color(1,1,1,1), Color(1,1,1,0), fade_dur*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	ui_player_fade_tween.interpolate_property(HUD_LifeBar, "modulate", Color(0,1,0,0), Color(0,1,0,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	ui_player_fade_tween.interpolate_property(HUD_ScoreTimer, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	ui_player_fade_tween.interpolate_property(player_node.sprite_gfx, "modulate", Color(1,1,1,0), Color(1,1,1,1), fade_dur*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	ui_player_fade_tween.start()

## --------------------------------------------------------------------------
# GAMEOVER FUNCS

func _on_Player_game_over():
	game_over_fade()
	handle_timers()

func game_over_fade(fade_out:bool = true):
	var fade_dur: float = 1.0
	if fade_out:
		player_node.is_active = false
		player_node.sleeping = true
		handle_buttons(false)
		black_bkg.modulate.a = 0
		black_bkg.visible = true
		black_bkg_fade_tween.interpolate_property(black_bkg, "modulate", Color(1,1,1,0), Color(1,1,1,1), fade_dur, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		black_bkg_fade_tween.start()
		ui_player_fade_tween.interpolate_property(HUD_LifeBar, "modulate", Color(0,1,0,1), Color(0,1,0,0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		ui_player_fade_tween.interpolate_property(HUD_ScoreTimer, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		ui_player_fade_tween.interpolate_property(player_node.sprite_gfx, "modulate", Color(1,1,1,1), Color(1,1,1,0), fade_dur*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		ui_player_fade_tween.start()
		#HUD_GameOver
	else:
		player_node.is_active = true
		handle_buttons()
		black_bkg_fade_tween.interpolate_property(black_bkg, "modulate", Color(1,1,1,1), Color(1,1,1,0), fade_dur*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		black_bkg_fade_tween.start()
		$Player.position = $PlayerStart.position

func delete_all_spawned():
	for i in spawn_holder_node.get_children():
		i.call_deferred('free')
