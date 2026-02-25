extends PanelContainer

var res: PlantResource

func setup(new_res: PlantResource) -> void:
	# disconnect resource lama biar gak nyangkut setelah load
	if res and res.is_connected("changed", Callable(self, "update")):
		res.disconnect("changed", Callable(self, "update"))

	res = new_res

	$HBoxContainer/VBoxContainer/NameLabel.text = res.name
	$HBoxContainer/IconTexture.texture = res.icon_texture

	$HBoxContainer/VBoxContainer/GrowthBar.max_value = res.h_frames
	$HBoxContainer/VBoxContainer/DeathBar.max_value = res.death_max

	update()
	res.changed.connect(Callable(self, "update"))
	visible = true

func update() -> void:
	if res == null:
		visible = false
		return

	print("[UI] update -> dead:", res.dead,
		  " death:", res.death_count, "/", res.death_max,
		  " age:", res.age)

	$HBoxContainer/VBoxContainer/GrowthBar.value = res.age
	$HBoxContainer/VBoxContainer/DeathBar.value = res.death_count

	# jangan hapus UI-nya, cukup hide
	#if res.dead or res.death_count >= res.death_max:
		#visible = not (res.dead or res.death_count >= res.death_max)
		
	if res.dead or res.death_count >= res.death_max:
		print("[UI] plant dianggap mati -> hide UI")
		visible = false
	else:
		visible = true

func reset() -> void:
	# dipanggil dari level.gd setelah load
	if res and res.is_connected("changed", Callable(self, "update")):
		res.disconnect("changed", Callable(self, "update"))
	res = null
	#visible = false
	
	
func _process(delta):
	if not visible:
		print("[UI] sekarang invisible!")
