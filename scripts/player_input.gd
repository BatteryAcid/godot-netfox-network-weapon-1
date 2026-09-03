class_name PlayerInput
extends Node

signal weapon_fired

var input_dir: Vector2

var _fire_queued: bool = false

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	NetworkTime.before_tick_loop.connect(_gather)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		_fire_queued = true

func _gather() -> void:
	if not is_multiplayer_authority():
		return
	
	if get_tree().get_multiplayer().has_multiplayer_peer() and not MatchManager.game_paused:
		input_dir = Input.get_vector("left", "right", "up", "down")
		
		if _fire_queued:
			_fire_queued = false
			weapon_fired.emit()
