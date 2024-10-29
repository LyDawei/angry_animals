extends Node

var _attempts:int = 0
var _cups_hit:int = 0
var _total_cups:int = 0
var _level:int = 1
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_total_cups = get_tree().get_nodes_in_group("cup").size()
	_level = ScoreManager.get_selected_level()
	SignalManager.on_attempt_made.connect(handle_on_attempt_made)
	SignalManager.on_cup_destroyed.connect(handle_on_cup_destroyed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func handle_on_attempt_made() -> void:
	_attempts += 1
	SignalManager.on_score_updated.emit(_attempts)

func handle_on_cup_destroyed() -> void:
	_cups_hit += 1
	if _cups_hit == _total_cups:
		handle_level_complete()


func handle_level_complete() -> void:
	SignalManager.on_level_completed.emit()
	ScoreManager.set_score(str(_level), _attempts)
