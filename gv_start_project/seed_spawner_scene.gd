extends Node2D

@export var seed_scene: PackedScene = preload("res://seed_item.tscn")
@export var spawn_positions: Array[Vector2] = []

# ✅ Pakai Enum.Seed supaya sinkron sama PLANT_DATA
@export var seed_types: Array[Enum.Seed] = [
	Enum.Seed.TOMATO, 
	Enum.Seed.CORN, 
	Enum.Seed.PUMPKIN, 
	Enum.Seed.WHEAT
]

func _ready():
	call_deferred("spawn_seeds")

func spawn_seeds():
	if spawn_positions.size() == 0: return
	for pos in spawn_positions:
		spawn_seed(seed_types.pick_random(), pos)

func spawn_seed(type: Enum.Seed, pos: Vector2):
	var new_seed = seed_scene.instantiate()
	
	# ✅ Berikan data DULU sebelum add_child
	new_seed.seed_type = type
	new_seed.position = pos
	
	add_child(new_seed)
	
	if new_seed.has_signal("picked_up"):
		new_seed.picked_up.connect(_on_seed_picked_up)

func _on_seed_picked_up(type: Enum.Seed):
	# ✅ Ambil reward otomatis dari data kamu
	var reward = Data.PLANT_DATA[type]["reward"]
	Data.change_item(reward, 1)
