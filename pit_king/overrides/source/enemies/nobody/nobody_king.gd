extends NobodyBoss

func _init():
	super._init()

	next_move = "expand_board"

	moves = {

		expand_board = {
			acid = {
				0: 8,
				1: 9,
				2: 10,
			},
			rows = {
				0: [-1, -2, -3],
				2: [-1, -2, -3, -4],
			},
			next = "attack", 
		}, 
		attack = {
			damage = {
				0: 3, 
				2: 4,
			}, 
			count = {
				0: 1,
				3: 3,
			},
			next = "board_shear", 
		}, 
		board_shear = {
			damage = {
				0: 6, 
				1: 7, 
				2: 8, 
				3: 10,
			}, 
			bleed = {
				0: 6,
			}, 
			next = "small_acid", 
		}, 
		small_acid = {
			damage = {
				0: 2,
				1: 3,
				2: 5,
				3: 6,
			},
			acid = {
				0: 3,
				3: 6,
			},
			rows = {
				0: [-1],
				3: [-1, -2],
			},
			next = "expand_board",
		},
	}


func display_intent() -> void :
	if next_move == "expand_board":
		add_intent(Intent.EXPAND_BOARD, {size_x = 4, size_y = 6})
		add_intent(Intent.APPLY_STATUS, {status = TileStatus.ACID, target = "top", near = true, count = moves[next_move].acid})
	elif next_move == "attack":
		add_intent(Intent.ATTACK, {damage = moves.attack.damage, count = moves.attack.count})
	elif next_move == "board_shear":
		add_intent(Intent.ATTACK, {damage = moves.board_shear.damage})
		add_intent(Intent.BOARD_SHEAR, {count = moves.board_shear.bleed, size_x = 3, size_y = 6})
	elif next_move == "small_acid":
		add_intent(Intent.ATTACK, {damage = moves.small_acid.damage})
		add_intent(Intent.APPLY_STATUS, {status = TileStatus.ACID, target = "top", near = true, count = moves[next_move].acid})


func expand_board():
	await animate_attack()
	await tile_board.set_size(4, 6)
	
	var apply_to = get_tiles({
		amount = moves[next_move].acid, 
		rows = moves.expand_board.rows,
		effect_priority = EFFECT_PRIORITY.STATUS_ONLY, 
	})

	for tile in apply_to:
		tile.add_status(TileStatus.ACID)
		tile.add_poofcloud(Globals.COLORS.ACID)
		var pause = randf_range(0.04, 0.08)
		await Game.timeout(pause)
		
	await wait_for_idle()


func attack():
	await animate_attack()
	for i in moves.attack.count:
		hit_player(moves.attack.damage, i == moves.attack.count - 1)
		
	await Game.timeout(0.24)

	await wait_for_idle()


func board_shear():
	await animate_attack()

	hit_player(moves.board_shear.damage)
	await tile_board.set_size(3, 6)

	var rightmost_column: = get_tiles({
		amount = moves.board_shear.bleed, 
		columns = [-1], 
	})

	for tile in rightmost_column:
		tile.randomize_if_faceless(rng.move)
		tile.add_status(TileStatus.BLEED)
		tile.add_poofcloud(tile.get_color())

		var interval = randf_range(0.04, 0.08)
		await Game.timeout(interval)

	dooming_columns.clear()
	await wait_for_idle()

func small_acid():
	await animate_attack()

	hit_player(moves.small_acid.damage)

	await Game.timeout(0.24)
	
	var apply_to = get_tiles({
		amount = moves[next_move].acid, 
		rows = moves.small_acid.rows, 
		effect_priority = EFFECT_PRIORITY.STATUS_ONLY, 
	})

	for tile in apply_to:
		tile.add_status(TileStatus.ACID)
		tile.add_poofcloud(Globals.COLORS.ACID)
		var pause = randf_range(0.04, 0.08)
		await Game.timeout(pause)

	await wait_for_idle()


func unique_end_player_action() -> void :
	if next_move == "board_shear":
		dooming_columns = [2, 3, 4]



func pick_cutscene() -> String:
	if not StringManager.has_string_group("nobody/%s" % player.id):
		return ""

	var file: = SaveManager.get_save()
	var character_group: = StringManager.get_string_group("nobody/%s" % player.id)
	var possible_cutscenes: Array[String] = []
	var unseen_cutscenes: Array[String] = []
	for group_name in character_group.groups:
		var cutscene: = character_group.groups[group_name]
		var can_play_cutscene: = true
		var cutscene_id: = cutscene.get_path_key()
		var has_viewed_cutscene: = file.has_viewed_nobody_cutscene(cutscene_id)

		if cutscene.has_string_at_path(["flags"]):
			var cutscene_flags: = cutscene.get_string_at_path(["flags"]).split(" ")

			var is_priority: = false
			var is_always_priority: = false
			for flag in cutscene_flags:
				if flag == "pre_trans" and player.is_trans():
					can_play_cutscene = false
				elif flag == "post_trans" and not player.is_trans():
					can_play_cutscene = false
				elif flag == "first_encounter":
					if has_viewed_cutscene or Game.difficulty != 0 or not AchievementManager.can_unlock_progression():
						can_play_cutscene = false
				elif flag == "one_time":
					if has_viewed_cutscene:
						can_play_cutscene = false
				elif flag == "story":
					if not AchievementManager.can_unlock_progression():
						can_play_cutscene = false
				elif flag.begins_with("seen_"):
					var other_cutscene_id: = flag.trim_prefix("seen_")
					if not file.has_viewed_nobody_cutscene(other_cutscene_id):
						can_play_cutscene = false
				elif flag.begins_with("difficulty_"):
					var difficulty_string: = flag.trim_prefix("difficulty_")
					var min_difficulty: int
					var max_difficulty: int
					if difficulty_string.ends_with("+"):
						min_difficulty = difficulty_string.trim_suffix("+").to_int()
						max_difficulty = Globals.DIFFICULTY_COUNT - 1
					elif difficulty_string.ends_with("-"):
						min_difficulty = 0
						max_difficulty = difficulty_string.trim_suffix("-").to_int()
					else:
						min_difficulty = difficulty_string.to_int()
						max_difficulty = min_difficulty

					if Game.difficulty < min_difficulty or Game.difficulty > max_difficulty:
						can_play_cutscene = false
				elif flag.begins_with("spell_"):
					var spell_id: = flag.trim_prefix("spell_")
					if not player.has_spell_id(spell_id):
						can_play_cutscene = false
				elif flag.begins_with("enemy_"):
					var enemy_id: = flag.trim_prefix("enemy_")
					var matched_id = ""
					for encounter in Game.enemy.main.run_stats.get_encounters():
						if encounter.enemy_name == enemy_id:
							matched_id = encounter.enemy_name
					if matched_id == "":
						can_play_cutscene = false
				elif flag == "priority":
					is_priority = true
				elif flag == "always_priority":
					is_always_priority = true

			if can_play_cutscene:
				if is_always_priority and ( not SaveManager.get_skip_repeat_dialogue() or not has_viewed_cutscene):
					unseen_cutscenes = [cutscene_id]
					break
				elif is_priority and not has_viewed_cutscene:
					unseen_cutscenes = [cutscene_id]
					break

		if can_play_cutscene:
			possible_cutscenes.append(cutscene_id)
			if not has_viewed_cutscene:
				unseen_cutscenes.append(cutscene_id)

	if not unseen_cutscenes.is_empty():
		possible_cutscenes = unseen_cutscenes
	elif SaveManager.get_skip_repeat_dialogue():
		return ""

	if possible_cutscenes.is_empty():
		return ""

	var random_cutscene: String = rng.move.pick_random(possible_cutscenes)
	return random_cutscene
	


func advance_cutscene(instant: = false) -> void :
	active_cutscene_index += 1
	var str_index: = str(active_cutscene_index)
	if not active_cutscene.has_string_at_path([str_index]):
		await finish_cutscene()
		return

	var previous_bubble_nobody: = not next_bubble_nobody

	var line_flags: = PackedStringArray()
	if active_cutscene.has_string_group(str_index):
		if active_cutscene.has_string_at_path([str_index, "flags"]):
			line_flags = active_cutscene.get_string_at_path([str_index, "flags"]).split(" ")

	if "character" in line_flags:
		next_bubble_nobody = false
	elif "nobody" in line_flags:
		next_bubble_nobody = true

	var should_play_line: = true
	for flag in line_flags:
		if flag.begins_with("spell_"):
			var spell_id: = flag.trim_prefix("spell_")
			should_play_line = player.has_spell_id(spell_id)

		if flag == "pro_piracy" and not Game.is_steam_inactive():
			should_play_line = false

	if not should_play_line:
		await advance_cutscene(instant)
		return

	var new_bubble: = true
	if active_speech_bubble != null and is_instance_valid(active_speech_bubble):
		if next_bubble_nobody == previous_bubble_nobody:
			new_bubble = false
		else:
			await disappear_speech_bubble(instant)

	if new_bubble:
		if next_bubble_nobody:
			active_speech_bubble = sprite.spawn_speech_bubble()
		else:
			active_speech_bubble = player.sprite.spawn_speech_bubble()

		if next_bubble_nobody:
			reset_speech_bubble()
			await active_speech_bubble.appear(&"appear_nobody")
		else:
			#var frame: = Globals.CHARACTER_ORDER.find(player.id) + 2
			set_speech_bubble_sprite()
			await active_speech_bubble.appear(&"appear_character")

	next_bubble_nobody = not next_bubble_nobody

	var delay: float = 0.02
	if "fast" in line_flags:
		delay = 0.01

	var cutscene_string: = active_cutscene.get_string_at_path([str_index], {trans = player.is_trans()})
	var cutscene_control_string: = active_cutscene.get_string_at_path([str_index], {control = true, trans = player.is_trans()})
	active_speech_bubble.type_text(cutscene_string, cutscene_control_string, "cutoff" not in line_flags, delay)

	if "cutoff" in line_flags:
		active_speech_bubble.text_playback.finished.connect(advance_cutscene.bind(true), ConnectFlags.CONNECT_ONE_SHOT)

func reset_speech_bubble():
	for path in [^"%Bubble",^"%Tail"]:
		var bubble_sprite:Sprite2D=active_speech_bubble.get_node(path)
		bubble_sprite.hframes=4
		bubble_sprite.vframes=2


func set_speech_bubble_sprite():
	var bubble:Sprite2D=active_speech_bubble.get_node("%Bubble")
	bubble.hframes=1
	bubble.vframes=1
	bubble.texture=load(CharacterLoader.speech_bubbles[player.id][0])
	
	var tail:Sprite2D=active_speech_bubble.get_node("%Tail")
	tail.hframes=1
	tail.vframes=1
	tail.texture=load(CharacterLoader.speech_bubbles[player.id][1])
