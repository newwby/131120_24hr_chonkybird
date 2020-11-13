extends Node2D

export var obstacle: PackedScene

var default_barrier_spawn_timer: float = 4.0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$spawn_barrier.wait_time = default_barrier_spawn_timer
	$spawn_barrier.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_spawn_barrier_timeout():
	var random_chance = randi()%2
	print(random_chance)
	if random_chance == 1:
		spawn_barrier(true)
	else:
		spawn_barrier(false)

func spawn_barrier(spawn_top: bool):
	var new_barrier = obstacle.instance()
	self.add_child(new_barrier)
	if spawn_top:
		new_barrier.position = $position_upper.position
	else:
		new_barrier.rotation_degrees = 180
		new_barrier.position = $position_lower.position
