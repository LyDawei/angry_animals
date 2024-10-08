extends Node2D

const ANIMAL:PackedScene = preload("res://scenes/animal/animal.tscn")
@onready var animal_start: Marker2D = $AnimalStart

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_animal_died.connect(add_animal)
	add_animal()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_animal() -> void:
	var animal = ANIMAL.instantiate()
	animal.position = animal_start.position
	add_child(animal)