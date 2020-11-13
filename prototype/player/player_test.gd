extends RigidBody2D

class_name Player

signal food_value_change
signal game_over

onready var sprite_gfx = $Sprite
onready var particle_gfx = $Boost_Particles

var is_active: bool = true
const BASE_FOOD_LEVEL: int = 50
var food_level: int = BASE_FOOD_LEVEL

var gravity_scale_multiplier: float = 0.4
var fart_impulse_multiplier: int = 25
var drift_to_origin_modifier: float = 0.1

var screen_size: Vector2
var screen_offset: int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	self.gravity_scale *= gravity_scale_multiplier
	emit_signal("food_value_change", food_level)

func _process(delta):
	
	if is_active:
		if self.position.x < (screen_size.x*0.4):
			self.apply_impulse(Vector2(), Vector2(1,0)*drift_to_origin_modifier)
		elif self.position.x > (screen_size.x*0.8):
			self.apply_impulse(Vector2(), Vector2(-1,0)*drift_to_origin_modifier)
		if self.rotation_degrees != 0 and self.rotation_degrees > 180:
			self.rotation_degrees += 10 * delta
		elif self.rotation_degrees != 0 and self.rotation_degrees > 0:
			self.rotation_degrees -= 10 * delta

func _input(event):
	if event.is_action_pressed("ingame_action") and food_level > 1 and is_active:
	   process_jump()

func process_jump():
	if food_level > 0:
		food_level -= 1
		emit_signal("food_value_change", food_level)
	self.apply_impulse(Vector2(), Vector2(0,-1) * fart_impulse_multiplier)
	particle_gfx.emitting = true
	#print("hwat")

func _on_FailureArea_body_entered(body):
	if body == self:
		emit_signal("game_over")

func collected_food(food_nutrition:int = 0, food_weight:int = 0):
	if food_level >= 100:
		food_level = 100
	else:
		food_level += food_nutrition
	emit_signal("food_value_change", food_level)
