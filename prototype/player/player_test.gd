extends RigidBody2D

class_name Player

var gravity_scale_multiplier: float = 0.4
var fart_impulse_multiplier: int = 25
var drift_to_origin_modifier: float = 0.25

var screen_size: Vector2
var screen_offset: int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	self.gravity_scale *= gravity_scale_multiplier

func _process(delta):
	# self.position.x = clamp(position.x, 0+screen_offset, screen_size.x-screen_offset)
	# self.position.y = clamp(position.y, 0+screen_offset, screen_size.y-screen_offset)
	if self.position.x < (screen_size.x*0.4):
		self.apply_impulse(Vector2(), Vector2(1,0)*drift_to_origin_modifier)
		print(self.position.x)
	elif self.position.x > (screen_size.x*0.8):
		self.apply_impulse(Vector2(), Vector2(-1,0)*drift_to_origin_modifier)
		print(self.position.x)

func _unhandled_input(event):
	if event.is_action_pressed("ingame_action"):
	   process_jump()

func process_jump():
	self.apply_impulse(Vector2(), Vector2(0,-1) * fart_impulse_multiplier)
	#print("hwat")


func _on_FailureArea_body_entered(body):
	if body == self:
		print("you lost")
