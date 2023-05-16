extends Area2D

signal deny
signal eaten

export(Array, Texture) var variants = []
export(int) var score_cost = 1
export(int) var die_timeout = 10
export(bool) var autostart = false

var next_texture
var on_ready_cb: FuncRef

func _enter_tree():
	next_texture = variants[randi() % variants.size()]
	print('----')
	print(self)
	print('enter')


func _ready():
	print("ready")
	$Sprite.texture = next_texture

	if autostart:
		var timer = Timer.new()
		timer.wait_time = die_timeout
		timer.one_shot = true
		timer.connect("timeout", self, "_deny", [], CONNECT_ONESHOT)
		add_child(timer)
		timer.start(0)
		
	if on_ready_cb:
		on_ready_cb.call_func()

func eat():
	emit_signal("eaten")
	queue_free()


func _deny():
	emit_signal("deny")
	queue_free()
