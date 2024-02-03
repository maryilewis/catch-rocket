class_name Rocket extends Node2D

func dance(callback):
	$CPUParticles2D.emitting = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x, position.y + 20), .2)
	tween.tween_property(self, "position", Vector2(position.x, position.y - 20), .2)
	tween.set_loops(5)
	tween.connect("finished", go_back.bind(callback))

func nope(callback):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x + 10, position.y), .2)
	tween.tween_property(self, "position", Vector2(position.x - 10, position.y), .2)
	tween.set_loops(5)
	tween.connect("finished", go_back.bind(callback))

func go_back(callback: Callable):
	position = Vector2(0, 0)
	callback.call()
