extends Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_water_collide.connect(on_water_collide)
	pass # Replace with function body.


func on_water_collide() -> void:
	audio_stream_player_2d.play()


func _on_water_body_entered(body: Node2D) -> void:
	SignalManager.on_water_collide.emit()
	pass # Replace with function body.
