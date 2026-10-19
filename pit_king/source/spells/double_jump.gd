extends Spell


func set_status_tooltips():
	status_tooltips = [{status = TileStatus.ENHANCED, plastic = true}]


func _use():
	var tile = await get_selection()

	if tile == null:
		_end_use()
		return
	
	var tile_coords = tile.get_coord()
	var top_tile = tile_board.get_tile_at(tile_coords + Vector2i(0, 1))
	var bottom_tile = tile_board.get_tile_at(tile_coords + Vector2i(0, -1))
	
	if top_tile != null:
		top_tile.randomize_if_faceless(rng.spell)
		top_tile.set_type(TileType.DEFENSE)
		top_tile.add_status(TileStatus.ENHANCED)
		AudioManager.play_sound(Sounds.SPELLS.GUNSHOT)
		top_tile.add_poofcloud(top_tile.get_color())
	
	await Game.timeout(0.25)
	
	if bottom_tile != null:
		bottom_tile.randomize_if_faceless(rng.spell)
		bottom_tile.set_type(TileType.DEFENSE)
		bottom_tile.add_status(TileStatus.ENHANCED)
		AudioManager.play_sound(Sounds.SPELLS.GUNSHOT)
		bottom_tile.add_poofcloud(bottom_tile.get_color())

	_post_use()


func is_tile_selectable(tile: Tile) -> bool:
	return true
