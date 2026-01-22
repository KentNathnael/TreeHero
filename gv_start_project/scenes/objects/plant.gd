extends StaticBody2D

var coord : Vector2i
@export var res : PlantResource 

func setup(grid_coord: Vector2i, parent: Node2D, new_res: PlantResource):
	position = grid_coord * Data.TILE_SIZE + Vector2i(8,5)
	parent.add_child(self)
	coord = grid_coord
	res = new_res
	$FlashSprite2D.texture = res.texture

func grow(watered: bool):
	if watered:
		res.grow($FlashSprite2D)
	else:
		res.decay(self)

func _on_collision_area_body_entered(_body: Node2D) -> void:
	if res.get_complete():
		for i in range(3):
			$FlashSprite2D.flash(0.2, 0.6)
			await get_tree().create_timer(0.8).timeout
		queue_free()
