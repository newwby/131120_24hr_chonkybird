extends StaticBody2D

export var active = true
export var move_rate = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		position.x -= move_rate * delta


func _on_VisibilityNotifier2D_screen_exited():
	print("delete_me!")
