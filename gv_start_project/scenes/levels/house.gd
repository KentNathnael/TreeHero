extends Node2D

# 1. Deklarasikan variabel di paling atas!
var door_cell_coord: Vector2i

# 2. Baru kemudian variabel dengan setter
var in_house: bool:
	set(value):
		in_house = value
		
		# Pastikan door_cell_coord sudah terisi sebelum diakses
		if $WallsLayer:
			$WallsLayer.set_cell(door_cell_coord, 0, Vector2i.ONE if value else Vector2i(0,4))
		
		# Animasi Tween untuk Atap dan SEMUA Label di bawah LabelHouse
		var tween = create_tween().set_parallel(true)
		if $RoofLayer:
			tween.tween_property($RoofLayer, "modulate:a", 0.0 if in_house else 1.0, 0.5)
		if $"../../LabelHouse/HouseMachine/LabelMachine":
			tween.tween_property($"../../LabelHouse/HouseMachine/LabelMachine", "modulate:a", 0.0 if in_house else 1.0, 0.5)
		if $"../../LabelHouse/HouseBuySeeds/LabelBuySeeds":
			tween.tween_property($"../../LabelHouse/HouseBuySeeds/LabelBuySeeds", "modulate:a", 0.0 if in_house else 1.0, 0.5)
		if $"../../LabelHouse/HouseSellSeeds/LabelSellSeeds":
			tween.tween_property($"../../LabelHouse/HouseSellSeeds/LabelSellSeeds", "modulate:a", 0.0 if in_house else 1.0, 0.5)
		if $"../../LabelHouse/HouseACC/LabelBuyAcc":
			tween.tween_property($"../../LabelHouse/HouseACC/LabelBuyAcc", "modulate:a", 0.0 if in_house else 1.0, 0.5)

func _ready() -> void:
	# Loop untuk mencari koordinat pintu saat game dimulai
	for cell in $WallsLayer.get_used_cells():
		$FloorLayer.set_cell(cell, 0, Vector2i.ZERO)
		if $WallsLayer.get_cell_atlas_coords(cell) == Vector2i(0,4):
			door_cell_coord = cell

func _on_house_area_body_entered(_body: Node2D) -> void:
	in_house = true

func _on_house_area_body_exited(_body: Node2D) -> void:
	in_house = false
