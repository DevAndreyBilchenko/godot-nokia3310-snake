extends Timer

var _game_over = false

func skip_step():
	if _game_over:
		return
	
	stop()
	emit_signal("timeout")
	start(0)


func game_over():
	_game_over = true
