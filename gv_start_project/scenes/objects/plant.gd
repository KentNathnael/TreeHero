extends StaticBody2D

var coord: Vector2i
@export var res: PlantResource
signal death(coord: Vector2i)

func setup(grid_coord: Vector2i, parent: Node2D, new_res: PlantResource, plant_death_func):
	position = grid_coord * Data.TILE_SIZE + Vector2i(8,5)
	parent.add_child(self)
	coord = grid_coord
	res = new_res
	$FlashSprite2D.texture = res.texture
	death.connect(plant_death_func)
	res.connect("changed", update)
	
	add_to_group("Plants")
	
func get_plant_resource() -> PlantResource:
	return res

func update():
	if res.death_count >= res.death_max:
		res.dead = true
		death.emit(coord)
		queue_free()

func grow(watered: bool):	
	if watered:
		res.grow($FlashSprite2D)
	else:
		res.decay()
		if res.death_count >= res.death_max and not is_queued_for_deletion():
			death.emit(coord)
			queue_free()


func _on_collision_area_body_entered(_body: Node2D) -> void:
	if res.get_complete():
		Data.change_item(res.reward, randi_range(2,4))
		$FlashSprite2D.flash(0.2, 0.4, queue_free)
		death.emit(coord)
		res.dead = true


func damage():
	res.damage()
	if res.death_count >= res.death_max and not is_queued_for_deletion():
		death.emit(coord)  
		queue_free() 
