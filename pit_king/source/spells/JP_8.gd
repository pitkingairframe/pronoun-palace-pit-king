extends Spell


var turn_count = 4

func get_save_data():
	var save = super.get_save_data()
	save["turn_count"] = turn_count
	return save

func load_save_data(save):
	super.load_save_data(save)
	turn_count = save.turn_count

func player_turn_started(is_battle_start: bool) -> void:
	if is_battle_start == false and Game.tile_board.restock_locked == false and Game.enemy.id != Enemies.NOBODY and Game.enemy.id != null:
		turn_count -= 1

	Game.main.player_action_started.connect(
		func _ready():
			if turn_count == 0 and Game.tile_board.restock_locked == false:
				Game.tile_board.lock_restock(6)
	)
	print(turn_count)
	Game.word_builder.finished_updating_stats.connect(_on_finished_updating_stats)
	super.player_turn_started(is_battle_start)

func battle_ended():
	if Game.enemy.id in Enemies.BOSSES:
		turn_count = 8
	elif turn_count == 8:
		turn_count = 8
	elif turn_count >= 3:
		turn_count += 1
	else:
		turn_count += 2
	tile_board.unlock_restock()

func turn_end():
	player.rerolled.connect(
		func _ready():
			if turn_count == 0:
				turn_count += 3
				tile_board.unlock_restock()
	)
	super.turn_end()



func _on_finished_updating_stats(_words):
	if turn_count > 0 and Game.tile_board.restock_locked == false and Game.enemy.id != Enemies.NOBODY:
		Game.word_builder.add_intent("king_lock",{count = turn_count})
	elif turn_count == 0 and Game.enemy.id != Enemies.NOBODY:
		Game.word_builder.add_intent("king_reroll")

func set_status_tooltips():
	status_tooltips = [{status = TileStatus.ENHANCED, wooden = true}, TileStatus.SPICY]
	
func _use(): 
	var tile = await get_selection()

	if tile == null:
		_end_use()
		return

	var selected_column = tile_board.get_column(tile.get_coord().x)
	
	AudioManager.play_sound(Sounds.SPELLS.SODA_CAN)
	AudioManager.play_sound(Sounds.SPELLS.MATCH_BOX)
	
	for selection in selected_column:
		
		if selection.has_face() == true:
			
			
			if selection.has_harmful_status() == true or selection.has_neutral_status() == true or selection.has_positive_status() == true:
				selection.add_status(TileStatus.SPICY)
				selection.add_poofcloud(selection.get_color())
				
			elif selection.is_type(TileType.DEFENSE):
				selection.set_type(TileType.DAMAGE)
				selection.add_status(TileStatus.ENHANCED)
				selection.add_poofcloud(selection.get_color())
			
			else:
				selection.set_type(TileType.DEFENSE)
				if has_curse(CURSE.CURSED):
					selection.add_status(TileStatus.CURSED)
				selection.add_poofcloud(selection.get_color())
			
			
			await Game.timeout(0.1)
	
	_post_use()
