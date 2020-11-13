extends Area2D

export var active = true
export var move_rate: int = 1
export var food_nutrition = 10
export var food_weight = 0

onready var sprite_graphic_holder = $gfx
onready var collection_particle = $particles_collected
onready var ambient_particle = $particles_ambient
onready var tween_vibrate = $Tween
onready var audio_se_eaten = $Audio_Eaten

var start_pos_y: float = 0.0
var y_travel_px: float = 5.0
var tween_down = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var random_food_type = randi()%3
	var food_type = ["donut", "hotdog", "pizza"]
	var sprite_path = str(self.get_path()) + "/gfx/sprite_" + str(food_type[random_food_type])
	get_node(sprite_path).visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		position.x -= move_rate * delta

func _on_VisibilityNotifier2D_screen_exited():
	call_deferred('free')

func _on_Area2D_body_entered(body):
	if body is Player:
		sprite_graphic_holder.visible = false
		ambient_particle.visible = false
		collection_particle.emitting = true
		if not body.has_method("collected_food") == null:
			body.collected_food(food_nutrition, food_weight)
		audio_se_eaten.play()
		yield(get_tree().create_timer(.75), "timeout")
		call_deferred('free')

func _on_Tween_tween_completed(_object, _key):
	run_tween()

func run_tween():
	start_pos_y = position.y
	var tween_dur = 0.5
	var end_pos_y = start_pos_y + y_travel_px if tween_down else start_pos_y - y_travel_px
	tween_vibrate.interpolate_property(self, "position:y", start_pos_y, end_pos_y, tween_dur, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_vibrate.start()
	tween_down = !tween_down
