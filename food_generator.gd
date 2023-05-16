extends Node

export(NodePath) var cells_np
export(NodePath) var step_timer_np
export(NodePath) var interface_np
export(PackedScene) var food
export(PackedScene) var bonus

onready var _cells = get_node(cells_np)
onready var _step_timer = get_node(step_timer_np)
onready var _interface = get_node(interface_np)

var _active_food
var _bonus_counter = 0


func _ready():
	_step_timer.connect("timeout", self, "_on_step_timer_timeout", [], CONNECT_ONESHOT)


func _on_step_timer_timeout():
	_add_food()
	

func _add_food():
	if _active_food:
		remove_child(_active_food)
	
	# дожидаемся когда коллайдеры ячеек подхватят позицию змеи
	yield(get_tree(), "physics_frame")
	
	_check_bonus()
	
	var empty_pos = _cells.get_random_empty_cell_position()
	var new_food = food.instance()
	new_food.position = empty_pos
	new_food.connect("eaten", self, "_add_food", [], CONNECT_ONESHOT)
	_active_food = new_food
	add_child(new_food)


func _check_bonus():
	if _bonus_counter >= 2:
		_bonus_counter = 0
		var new_bonus = bonus.instance()
		var empty_pos = _cells.get_random_empty_pair_position()
		new_bonus.position = empty_pos
		print("add")
		add_child(new_bonus)
		print("add end")
		_interface.show_bonus_with_countdown(new_bonus.next_texture, new_bonus.die_timeout, new_bonus)
	else:
		_bonus_counter += 1
