extends StaticBody2D

var coord : Vector2i
@export var res : PlantResource 

func setup(grid_coord: Vector2i, parent: Node2D):
	position = grid_coord * Data.TILE_SIZE + Vector2i(8,5)
	parent.add_child(self)
	coord = grid_coord
	$Sprite2D.texture = res.texture

func grow(watered: bool):
	if watered:
		res.grow($Sprite2D)
	else:
		res.decay(self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
