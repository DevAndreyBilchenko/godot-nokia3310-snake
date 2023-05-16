extends Node2D

export(NodePath) var snake_head_np
export(NodePath) var score_numbers_np
export(NodePath) var bonus_np
export(NodePath) var bonus_timer_np
export(NodePath) var bonus_texture_np
export(NodePath) var bonus_numbers_np

export(Texture) var t1
export(Texture) var t2
export(Texture) var t3
export(Texture) var t4
export(Texture) var t5
export(Texture) var t6
export(Texture) var t7
export(Texture) var t8
export(Texture) var t9
export(Texture) var t0

onready var snake_head = get_node(snake_head_np)
onready var score_numbers = get_node(score_numbers_np)
onready var bonus = get_node(bonus_np)
onready var bonus_timer = get_node(bonus_timer_np)
onready var bonus_texture = get_node(bonus_texture_np)
onready var bonus_numbers = get_node(bonus_numbers_np)

var _score = 0
var _bonus_time = 0
var _bonus_node

func _ready():
	snake_head.connect("eated", self, "_on_snake_head_eated")
	bonus_timer.connect("timeout", self, "_on_bonus_timeout")


func show_bonus_with_countdown(texture, time, bonus_node):
	bonus_texture = texture
	_bonus_time = time
	_bonus_node = bonus_node
	_print_number(bonus_numbers, _bonus_time)
	bonus.show()
	bonus_timer.start(0)


func _on_snake_head_eated(food):
	if food == _bonus_node:
		bonus.hide()
		bonus_timer.stop()
	
	_score += food.score_cost
	_print_number(score_numbers, _score)


func _print_number(number_pack: Node2D, number):
	var nums = []
	
	for ch in str(number):
		nums.append(ch)
		
	var node_numbers_count = number_pack.get_child_count()
	
	for n in range(node_numbers_count, 0, -1):
		var last = nums.pop_back()
		var number_node = number_pack.get_child(n-1)
		
		if last != null:
			number_node.texture = get(str("t", last))
		else:
			number_node.texture = t0


func _on_bonus_timeout():
	if _bonus_time <= 0:
		bonus_timer.stop()
		bonus.hide()
		
	_bonus_time -= 1
	
	_print_number(bonus_numbers, _bonus_time)
