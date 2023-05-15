tool
extends Node2D

const STEPSIZE = 4

export(PackedScene) var cell_scene
export(int) var size_x = 16
export(int) var size_y = 9

func _ready():
	if not Engine.editor_hint:
		for x in range(size_x):
			for y in range(size_y):
				var cell = cell_scene.instance()
				cell.position = Vector2(
					# integer division warning
					int(float(STEPSIZE)/float(2)+x*STEPSIZE), 
					int(float(STEPSIZE)/float(2)+y*STEPSIZE)
				)
				add_child(cell)


func _draw():
	if Engine.editor_hint:
		draw_rect(Rect2(0, 0, size_x*STEPSIZE, size_y*STEPSIZE), Color("#ff0000"), false)
