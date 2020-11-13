extends StaticBody2D

export var active = true
export var move_rate: int = 1
var rotate_speed: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var random_rotation_intensity = randi()%4+1 #1-4
	var random_rotation_direction = randi()%2
	if random_rotation_direction == 0:
		random_rotation_intensity = -random_rotation_intensity
	rotate_speed = random_rotation_intensity if self.name != "Asteroid" else random_rotation_intensity * 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		position.x -= move_rate * delta
	self.rotation_degrees += rotate_speed * delta


func _on_VisibilityNotifier2D_screen_exited():
	call_deferred('free')
