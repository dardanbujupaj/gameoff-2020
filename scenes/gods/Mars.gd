extends "res://scenes/gods/God.gd"


func start_effect():
	if not enabled:
		return
	print("Starting Mars effect")

	get_tree().call_group("shield", "enable")
	effect_active = true

func stop_effect():
	if effect_active:
		print("Stopping Mars effect")
		get_tree().call_group("shield", "disable")
		effect_active = false


func _on_Portrait_pressed():
	if effects_left > 0:
		start_effect()
