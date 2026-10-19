extends Mod

var SPELLS: Dictionary[String, String] = {
	JP_8 = "JP_8",
	boost_repair = "boost_repair",
	double_jump = "double_jump",
	horned_crown = "horned_crown"
	}

var SPELL_POOL: Dictionary[String, float] = {
	SPELLS.JP_8: 0.0,
	SPELLS.boost_repair: 0.0,
	SPELLS.double_jump: 0.75,
	SPELLS.horned_crown: 0.5 
	}

var SPELL_CATEGORIES: Dictionary[String, Array] = {
	Globals.SPELL_CATEGORY.DEFENSIVE: [
		SPELLS.double_jump
		],
	Globals.SPELL_CATEGORY.DIRECT_DEFENSE: [
		SPELLS.double_jump
		],
	Globals.SPELL_CATEGORY.OFFENSIVE: [
		SPELLS.horned_crown
		],
		}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _init() -> void:
	CustomIntent.custom_intent_icons["king_lock"]=load("res://mods/pit_king/arte/intents/LockIntent.png")
	CustomIntent.custom_intent_icons["king_reroll"]=load("res://mods/pit_king/arte/intents/RerollIntent.png")
	CharacterLoader.add_character("king", "pit_king:JP_8",preload("res://mods/pit_king/arte/characters/PronounPalaceIcons.png"))
	CharacterLoader.custom_spell_upgrades["pit_king:JP_8"]="pit_king:boost_repair"
	CharacterLoader.speech_bubbles["king"]=["res://mods/pit_king/arte/bubbles/king_speech_bubble.png","res://mods/pit_king/arte/bubbles/king_speech_bubble_tail.png"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_spell_ids() -> Array[String]:
	return namespace_ids(SPELLS.values())
	
func get_spell_pool(category: String = "") -> Dictionary[String, float]:
	var category_pool: Array = SPELL_CATEGORIES.get(category, [])
	var pool := SpellData.get_filtered_spell_pool(SPELL_POOL, category_pool)
	return namespace_dictionary_ids(pool)
	
