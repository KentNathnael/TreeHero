extends Control

var shop_button_scene = preload("res://scenes/ui/shop_button.tscn")
signal close

func reveal(shop_type: Enum.Shop = Enum.Shop.HAT):
	show()
	for child in $GridContainer.get_children():
		child.queue_free()
	
	var unlocked = Data.shop_connection[shop_type]['tracker']
	var all = Data.shop_connection[shop_type]['all']
	
	# LOGIKA BARU:
	var display_items = []
	if shop_type == Enum.Shop.SEEDS:
		# Kalau toko bibit, tampilkan SEMUA yang ada di daftar 'all'
		display_items = all
	else:
		# Kalau toko Hat/Machine, tampilkan yang belum dibeli saja (logika lama kamu)
		display_items = all.filter(func(x): return not (x in unlocked))
	
	if display_items.size() > 0:
		for item_enum in display_items:
			var shop_button = shop_button_scene.instantiate()
			shop_button.setup(shop_type, item_enum, $GridContainer)
			shop_button.connect('press', reveal)
		
		await get_tree().process_frame
		if $GridContainer.get_child_count() > 0:
			$GridContainer.get_child(0).grab_focus()
	else:
		hide()
		close.emit()
		get_tree().get_first_node_in_group("ResourceUI").hide()
