extends Control

onready var score_label = $MarginContainer/ScoreLabel
var score: int = 0

func _on_Timer_timeout():
	score += 1
	score_label.text = str(score)
	
