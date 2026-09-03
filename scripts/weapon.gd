extends NetworkWeapon2D

@export var player_input: PlayerInput
@export var projectile: PackedScene
@export var projectile_spawn_path: Node2D
@export var cooldown_ticks: int = 8

@onready var _parent_player = get_parent()

var _last_fired_tick: int = -1000

func _ready() -> void:
	player_input.weapon_fired.connect(_on_weapon_fired)

func _on_weapon_fired() -> void:
	fire()

func _can_fire() -> bool:
	return NetworkTime.tick - _last_fired_tick >= cooldown_ticks
	
func _can_peer_use(peer_id: int) -> bool:
	return str(_parent_player.name).to_int() == peer_id
	
func _spawn() -> Node2D:
	var projectile_scene = projectile.instantiate() as Node2D
	projectile_scene.global_transform = _parent_player.global_transform.translated(Vector2(0, 18))
	projectile_scene.fired_by_name = _parent_player.name

	if not _parent_player.name == "1":
		projectile_scene.flip_dir = -1
		
	projectile_spawn_path.add_child(projectile_scene, true)
	return projectile_scene
	
func _after_fire(spawned_projectile: Node2D):
	spawned_projectile.name = "P_%s_%d" % [_parent_player.name, get_fired_tick()]
	_last_fired_tick = get_fired_tick()
	
	for t in range(get_fired_tick(), NetworkTime.tick):
		if spawned_projectile.is_queued_for_deletion():
			break
			
		spawned_projectile._tick(NetworkTime.ticktime, t)
			
			
			
			
