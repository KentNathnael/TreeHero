extends Area2D

@export var spawn_id : String
@export var seed_type : int # enum Seed

func _ready():
	body_entered.connect(_on_pickup)

func _on_pickup(body):
	if body.name != "Player":
		return

	# Masukin ke inventory
#	PlayerInventory.add_seed(seed_type, 1)

	# Catat marker supaya gak spawn lagi
#	SeedSpawner.mark_used(spawn_id)

	# Hapus dari ground
	queue_free()
