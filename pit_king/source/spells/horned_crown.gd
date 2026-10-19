extends Spell


func set_status_tooltips():
	status_tooltips = [{status = TileStatus.ENHANCED, wooden = true}]


func _use():
	var target_tiles = get_tiles({
		type = TileType.DEFENSE, 
		effect_priority = EFFECT_PRIORITY.STATUS_ONLY, 
		has_face = true, 
	})

	if target_tiles.is_empty():
		_end_use()
		return

	for tile in target_tiles:
		tile.set_type(TileType.DAMAGE)
		tile.add_status(TileStatus.ENHANCED)
		tile.add_poofcloud(tile.get_color())
		
		await Game.timeout(0.1)

	_post_use()
