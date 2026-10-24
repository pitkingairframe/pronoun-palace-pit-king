extends "res://mods/pit_king/source/spells/JP_8.gd"


func set_status_tooltips():
	status_tooltips = [{status = TileStatus.ENHANCED, wooden = true}, TileStatus.ASH]

func _use(): 
	var tile = await get_selection()

	if tile == null:
		_end_use()
		return
	
	var column = tile.get_coord().x
	
	var selected_column

	if has_curse(CURSE.CURSED):
		selected_column = get_tiles({
			columns = [column],
			sorted = true,
			exclude_tiles = [tile]
		})
		tile.add_status(TileStatus.CURSED)
		tile.add_poofcloud(tile.get_color())
		await Game.timeout(0.1)
	else:
		selected_column = get_tiles({
			columns = [column],
			sorted = true,
		})
	
	AudioManager.play_sound(Sounds.SPELLS.SODA_CAN)
	AudioManager.play_sound(Sounds.SPELLS.MATCH_BOX)
	
	for selection in selected_column:
		
		if selection.has_face() == true:
			
			if selection.has_positive_status() == true:
				pass
				
			elif selection.has_harmful_status() == true or selection.has_neutral_status() == true:
				selection.add_status(TileStatus.ASH)
				selection.add_poofcloud(selection.get_color())
				
			elif selection.is_type(TileType.DEFENSE):
				selection.set_type(TileType.DAMAGE)
				selection.add_status(TileStatus.ENHANCED)
				selection.add_poofcloud(selection.get_color())
			
			else:
				selection.set_type(TileType.DEFENSE)
				selection.add_poofcloud(selection.get_color())
			
			
			await Game.timeout(0.1)
	
	_post_use()
