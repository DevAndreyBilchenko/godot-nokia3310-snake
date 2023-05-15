extends Timer


func skip_step():
	stop()
	emit_signal("timeout")
	start(0)
