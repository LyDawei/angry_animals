extends TextureButton

const HOVER_SCALE:Vector2 = Vector2(1.1,1.1) 
const NORMAL_SCALE:Vector2 = Vector2(1,1)

@export var level_number:int = 1


var _level_scene:PackedScene
@onready var text_label: Label = $MC/VBoxContainer/TextLabel
@onready var score_label: Label = $MC/VBoxContainer/ScoreLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_label.text = 'Level %s' % level_number
	score_label.text = 'Score: %s' % 0
	_level_scene = load('res://scenes/main/level%s.tscn' % level_number)

func _on_pressed() -> void:
	get_tree().change_scene_to_packed(_level_scene)
	


func _on_mouse_entered() -> void:
	scale = HOVER_SCALE
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	scale = NORMAL_SCALE
	pass # Replace with function body.
