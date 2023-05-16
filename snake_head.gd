tool
extends Node2D

signal eated(food)
signal direction_changed

const STEP_SIZE = 4
const DIRECTION_UP = 0
const DIRECTION_RIGHT = 1
const DIRECTION_BOTTOM = 2
const DIRECTION_LEFT = 3
const STATE_NORMAL = 0
const STATE_OPEN = 1
const GROUP_FOOD = "food"
const GROUP_SNAKE = "snake"

export(int, "Up", "Right", "Bottom", "Left") var direction = 1 setget _on_direction_set
export(int, "Normal", "Open") var state = 0 setget _on_state_set
export(PackedScene) var snake_part
export(NodePath) var step_timer_np
export(NodePath) var last_part_np

onready var _sprite_default = $SnakeHeadNormal
onready var _sprite_open = $SnakeHeadOpen
onready var _current_sprite = _sprite_default
onready var _sound_click = $SoundClick
onready var _nose = $Nose

var _step_timer
var _parent
var _last_part
var _prev_direction = Vector2(1, 0)
var _direction = Vector2(1, 0)
var _attempt_direction = Vector2(1, 0)
var _vertical_rotate = deg2rad(90)
var _direction_state = [
	{"rotation": -_vertical_rotate, "scale": Vector2(1, 1), "nrotation": deg2rad(-90)},  # Up
	{"rotation": 0,   				"scale": Vector2(1, 1), "nrotation": deg2rad(0)},  # Right
	{"rotation": _vertical_rotate,  "scale": Vector2(1, -1), "nrotation": deg2rad(90)}, # Bottom
	{"rotation": 0,   				"scale": Vector2(-1, 1), "nrotation": deg2rad(180)}, # Left
]
var _have_food = false

func _ready():
	if not Engine.editor_hint:
		_step_timer = get_node(step_timer_np)
		_step_timer.connect("timeout", self, "_on_step")
		_parent = get_parent()
		_last_part = (get_node(last_part_np) if last_part_np != "" else null)
	
	_update_state_display()
	_update_direction_display()


func _input(event):
	if not Engine.editor_hint:
		var action_detect = false
		
		if event.is_action_pressed("ui_up"):
			action_detect = true
			_attempt_direction = Vector2(0, -1)
		elif event.is_action_pressed("ui_right"):
			action_detect = true
			_attempt_direction = Vector2(1, 0)
		elif event.is_action_pressed("ui_down"):
			action_detect = true
			_attempt_direction = Vector2(0, 1)
		elif event.is_action_pressed("ui_left"):
			action_detect = true
			_attempt_direction = Vector2(-1, 0)

		if action_detect:
			_sound_click.play()
			if _is_valid_direction() && _attempt_direction != _direction:
				_step_timer.skip_step()


func _on_step():
	if _is_valid_direction():
		_prev_direction = _direction
		_direction = _attempt_direction
		emit_signal("direction_changed")
	
	var new_snake_part = snake_part.instance()
	
	new_snake_part.set_prev_part(_last_part)
	new_snake_part.set_next_part(self)
	new_snake_part.position = position
	new_snake_part.direction = _vec2dir(_prev_direction)
	new_snake_part.head = self
	
	position += _direction * STEP_SIZE

	_on_direction_set(_vec2dir(_direction))
	
	new_snake_part.update_type(direction, _have_food)
	
	_parent.add_child(new_snake_part)
	_last_part = new_snake_part
	_have_food = false


func _is_valid_direction():
	return (
		_attempt_direction.x > 0 && _direction.x >= 0 ||
		_attempt_direction.x < 0 && _direction.x <= 0 ||
		_attempt_direction.y > 0 && _direction.y >= 0 ||
		_attempt_direction.y < 0 && _direction.y <= 0
	)


func _update_direction_display():
	if not _current_sprite:
		return
	
	var dstate = _direction_state[direction]
	
	_current_sprite.scale = dstate.scale
	_current_sprite.rotation = dstate.rotation
	
	_nose.rotation = dstate.nrotation


func _update_state_display():
	if not _current_sprite:
		return
	
	if state == STATE_NORMAL:
		if Engine.editor_hint:
			_sprite_open.hide()
		else:
			if _sprite_open.is_inside_tree():
				remove_child(_sprite_open)
			if not _sprite_default.is_inside_tree():
				add_child(_sprite_default)
		_current_sprite = _sprite_default
	elif state == STATE_OPEN:
		if Engine.editor_hint:
			_sprite_default.hide()
		else:
			if _sprite_default.is_inside_tree():
				remove_child(_sprite_default)
			if not _sprite_open.is_inside_tree():
				add_child(_sprite_open)
		_current_sprite = _sprite_open
		
	_current_sprite.show()


func _on_direction_set(value):
	if direction == value:
		return
	
	direction = value
	
	_update_direction_display()


func _on_state_set(value):
	if state == value:
		return
		
	state = value
	
	_update_state_display()
	_update_direction_display()


func _vec2dir(vec):
	var dir

	if vec.y < 0:
		dir = DIRECTION_UP
	elif vec.x > 0:
		dir = DIRECTION_RIGHT
	elif vec.y > 0:
		dir = DIRECTION_BOTTOM
	elif vec.x < 0:
		dir = DIRECTION_LEFT
		
	return dir


func _on_nose_area_entered(_area):
	_on_state_set(STATE_OPEN)


func _on_nose_area_exited(_area):
	_on_state_set(STATE_NORMAL)


func _on_collider_area_entered(area):
	if area.is_in_group(GROUP_FOOD):
		emit_signal("eated", area)
		area.eat()
		_have_food = true
	elif area.is_in_group(GROUP_SNAKE):
		_step_timer.game_over()
