extends Node2D

export(NodePath) var left_wall_np
export(NodePath) var right_wall_np
export(NodePath) var up_wall_np
export(NodePath) var down_wall_np

onready var left_wall = get_node(left_wall_np)
onready var right_wall = get_node(right_wall_np)
onready var up_wall = get_node(up_wall_np)
onready var down_wall = get_node(down_wall_np)

func _ready():
	left_wall.connect("area_entered", self, "_on_left_wall_entered")
	right_wall.connect("area_entered", self, "_on_right_wall_entered")
	up_wall.connect("area_entered", self, "_on_up_wall_entered")
	down_wall.connect("area_entered", self, "_on_down_wall_entered")


func _on_left_wall_entered(area):
	_portal_to(right_wall, area, Vector2(-4, 0))


func _on_right_wall_entered(area):
	_portal_to(left_wall, area, Vector2(4, 0))


func _on_up_wall_entered(area):
	_portal_to(down_wall, area, Vector2(0, -4))


func _on_down_wall_entered(area):
	_portal_to(up_wall, area, Vector2(0, 4))
	

func _get_snake_head(area):
	return area.get_parent()
	

func _portal_to(wall, snake_area, shift = Vector2.ZERO):
	var head = _get_snake_head(snake_area)
	
	if shift.x != 0:
		head.position.x = wall.position.x + shift.x
	if shift.y != 0:
		head.position.y = wall.position.y + shift.y
