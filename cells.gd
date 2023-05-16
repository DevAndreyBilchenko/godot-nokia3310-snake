tool
extends Node2D

const STEPSIZE = 4

export(PackedScene) var cell_scene
export(int) var size_x = 16
export(int) var size_y = 9

var _horizontal_pairs = []

func _ready():
	if not Engine.editor_hint:
		var lines = {}
		
		for x in range(size_x):
			for y in range(size_y):
				if not lines.has(y):
					lines[y] = []
				
				var cell = cell_scene.instance()
				cell.position = Vector2(
					# integer division warning
					int(float(STEPSIZE)/float(2)+x*STEPSIZE), 
					int(float(STEPSIZE)/float(2)+y*STEPSIZE)
				)
				
				lines[y].append(cell)
				add_child(cell)
		
		for line in lines.values():
			var index = 0
			
			while index < line.size() - 1:
				_horizontal_pairs.append([line[index], line[index+1]])
				index += 1


func get_random_empty_pair_position():
	var empty = []
	
	for pair in _horizontal_pairs:
		if (
			pair[0].get_overlapping_areas().size() == 0 && 
			pair[1].get_overlapping_areas().size() == 0
		):
			empty.append(pair)

	if empty.size() > 0:
		return empty[randi() % empty.size()][0].position
	else:
		return false


func get_random_empty_cell_position():
	var empty = []
	
	for ch in get_children():
		if ch.get_overlapping_areas().size() == 0:
			empty.append(ch)
			
	if empty.size() > 0:
		return empty[randi() % empty.size()].position
	else:
		return false


func _draw():
	if Engine.editor_hint:
		draw_rect(Rect2(0, 0, size_x*STEPSIZE, size_y*STEPSIZE), Color("#ff0000"), false)
