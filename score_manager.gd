extends Node

# Develop scoring system
# Need a dictionary to hold high scores for specific levels

var _selected_level:int = 1
var _level_scores:Dictionary = {}
const SCORES_PATH = 'user://scores.json'

func _ready() -> void:
	pass

func set_selected_level(level:int) -> void:
	if level > 0 and level < 4:
		_selected_level = level

func get_selected_level() -> int:
	return _selected_level

func set_score(level:String, score:int) -> void:
	check_and_add(level)
	if(score > _level_scores[level]):
		_level_scores[level] = score
		save_score()

	

func check_and_add(level:String) -> void:
	if !_level_scores.has(level):
		_level_scores[level] = 0

func get_score(level:String) -> int:
	return _level_scores.get(level, 0)

func get_best_score(level:String):
	check_and_add(level)
	load_score()
	return _level_scores[level] # This will return 0 if the level doesn't exist

func save_score() -> void:
	var file = FileAccess.open(SCORES_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_level_scores))

func load_score() -> void:
	var file = FileAccess.open(SCORES_PATH, FileAccess.READ)
	if file == null:
		save_score()
	else:
		_level_scores = JSON.parse_string(file.get_as_text())
		