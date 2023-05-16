extends Node

# поражение 9:27

func _ready():
	randomize()


func _input(event):
	if event.is_action_pressed("ui_home"):
		print_stray_nodes()
