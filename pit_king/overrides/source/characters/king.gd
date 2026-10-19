extends Player

func _init():
	id = "king"
	starting_spells = ["pit_king:JP_8"]
	
	#Game.Sounds.CHARACTER = {
		#DIE = {
			#SOUND = preload("res://mods/pit_king/sounds/king_death.wav"), 
		#}, 
		#FLINCH = {
			#SOUNDS = [
				#preload("res://mods/pit_king/sounds/king_hurt_1.wav"), 
				#preload("res://mods/pit_king/sounds/king_hurt_2.wav"), 
				#preload("res://mods/pit_king/sounds/king_hurt_3.wav"), 
			#] 
		#}
	#}

func get_gender():
	if is_trans():
		return Gender.FEMALE
	else:
		return Gender.NONBINARY
		
func get_number_of_eyes() -> int:
	if is_trans():
		return 1
	else:
		return 2

func get_first_spell_select_guaranteed_category() -> String:
	return Globals.SPELL_CATEGORY.OFFENSIVE




#var turn_count = 1
#
#func turn_start(is_battle_start: bool) -> void:
	#if is_battle_start == false and Game.tile_board.restock_locked == false and Game.enemy.id != Enemies.NOBODY and Game.enemy.id != null:
		#turn_count -= 1
#
	#Game.main.player_action_started.connect(
		#func _ready():
			#if turn_count == 0 and Game.tile_board.restock_locked == false:
				#Game.tile_board.lock_restock(6)
	#)
	#print(turn_count)
	#Game.word_builder.finished_updating_stats.connect(_on_finished_updating_stats)
	#super.turn_start(is_battle_start)
#
#func battle_end():
	#if Game.enemy.id in Enemies.BOSSES:
		#turn_count = 8
	#elif turn_count == 8:
		#turn_count = 8
	#elif turn_count >= 3:
		#turn_count += 1
	#else:
		#turn_count += 2
	#Game.tile_board.unlock_restock()
	#super.battle_end()
#
#func end_turn():
	#rerolled.connect(
		#func _ready():
			#if turn_count == 0:
				#turn_count += 3
				#Game.tile_board.unlock_restock()
	#)
	#super.end_turn()
	#
#func _on_finished_updating_stats(_words):
	#if Game.word_builder.intent_instances.all(func (intent)->bool:return not intent.anim_player.is_playing()):
		#if turn_count > 0 and Game.tile_board.restock_locked == false and Game.enemy.id != Enemies.NOBODY:
			#Game.word_builder.add_intent("king_lock",{count = turn_count})
		#elif turn_count == 0 and Game.enemy.id != Enemies.NOBODY:
			#Game.word_builder.add_intent("king_reroll")
