extends Control

onready var life_bar_node
onready var no_energy_label = $MarginContainer/VBoxContainer/MarginContainer/Label_NoEnergy

# Called when the node enters the scene tree for the first time.
func _ready():
	set_life_bar_node()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_life_bar_node():
	life_bar_node = $MarginContainer/VBoxContainer/ProgressBar

func _on_Player_food_value_change(new_food_value):
	set_life_bar_node()
	life_bar_node.value = new_food_value
	if new_food_value <= 1 and no_energy_label != null:
		no_energy_label.text = "NO ENERGY!"
	elif no_energy_label != null:
		no_energy_label.text = ""
