tool
extends Node2D

const DIRECTION_UP = 0
const DIRECTION_RIGHT = 1
const DIRECTION_DOWN = 2
const DIRECTION_LEFT = 3

const TYPE_BODY = "Body"
const TYPE_BODYBOLA = "BodyBola"
const TYPE_TAIL = "Tail"
const TYPE_CORNER = "Corner"
const TYPE_CORNERBOLA = "CornerBola"

export(int, "Up", "Right", "Down", "Left") var direction = 1 setget _on_direction_set
export(String, "Body", "BodyBola", "Tail", "Corner", "CornerBola") var type = "Body" setget _on_type_set
export(NodePath) var step_timer_np
export(NodePath) var prev_part_np
export(NodePath) var next_part_np

onready var step_timer = (get_node(step_timer_np) if not Engine.editor_hint and step_timer_np else null)
onready var ready_marker = true # без него сеттеры будут сыпатся

var prev_part
var next_part
var sprites = []


func _ready():
	if not Engine.editor_hint && type == TYPE_TAIL:
		_connect_die_timeout()

	for ch in get_children():
		if ch.name != "Collider":
			sprites.append(ch)

	if prev_part_np != "" and not prev_part:
		 prev_part = get_node(prev_part_np)

	if next_part_np != "" and not next_part:
		next_part = get_node(next_part_np)

	update_design()


func set_prev_part(_prev_part):
	prev_part = _prev_part
	prev_part.set_next_part(self)


func set_next_part(_next_part):
	next_part = _next_part


func update_design():
	var sprite_name = ""
	
	if type == TYPE_CORNER || type == TYPE_CORNERBOLA:
		if next_part:
			var np_dir = next_part.direction
			sprite_name = str(type, direction, "_", np_dir)
	else:
		sprite_name = str(type, direction)
	
	for sprite in sprites:
		if sprite_name == sprite.name:
			sprite.show()
			if not sprite.owner:
				add_child(sprite)
		else:
			if Engine.editor_hint:
				sprite.hide()
			elif sprite.owner:
				remove_child(sprite)


func convert_to_tail():
	if type == TYPE_CORNER || type == TYPE_CORNERBOLA:
		_on_direction_set(next_part.direction)
	_on_type_set(TYPE_TAIL)
	
	prev_part = null
	_connect_die_timeout()


func update_type(next_direction, bola = false):
	if next_direction != direction:
		if bola:
			_on_type_set(TYPE_CORNERBOLA)
		else:
			_on_type_set(TYPE_CORNER)
	else:
		if bola:
			_on_type_set(TYPE_BODYBOLA)
		else:
			_on_type_set(TYPE_BODY)


func _die():
	next_part.step_timer = step_timer
	next_part.convert_to_tail()
	queue_free()


func _connect_die_timeout():
	if !prev_part && step_timer:
		step_timer.connect("timeout", self, "_die", [], CONNECT_ONESHOT)


func _on_direction_set(value):
	if direction == value:
		return
	
	direction = value
	
	if ready_marker:
		update_design()


func _on_type_set(value):
	if type == value:
		return
		
	type = value
	
	if ready_marker:
		update_design()
