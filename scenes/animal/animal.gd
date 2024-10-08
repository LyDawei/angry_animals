extends RigidBody2D

enum ANIMAL_STATE {READY, DRAG, RELEASE}
@onready var label: Label = $AnimalState
@onready var vector_2_debug: Label = $Vector2_Debug
@onready var stretch_sound: AudioStreamPlayer2D = $Stretch_Sound
@onready var arrow: Sprite2D = $Arrow


const DRAG_LIM_MAX = Vector2(0,60)
const DRAG_LIM_MIN = Vector2(-60,0)

var _state:ANIMAL_STATE = ANIMAL_STATE.READY
var _start:Vector2 = Vector2.ZERO
var _drag_start:Vector2 = Vector2.ZERO
var _dragged_vector:Vector2 = Vector2.ZERO
var _last_dragged_vector: Vector2 = Vector2.ZERO

func detect_release()->bool:
	if _state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released('drag'):
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false

# Subtract current mouse position by Vector2.Zero.
# This gives us a reference point of what the "dragged vector" is.
func get_dragged_vector(gmp:Vector2)->Vector2:
	return gmp - _drag_start
	
func drag_in_limits()  -> void:
	_last_dragged_vector = _dragged_vector
	_dragged_vector.x = clampf(
		_dragged_vector.x,
		DRAG_LIM_MIN.x,
		DRAG_LIM_MAX.x
	)
	
	_dragged_vector.y = clampf(
		_dragged_vector.y,
		DRAG_LIM_MIN.y,
		DRAG_LIM_MAX.y
	)
	
	position = _start + _dragged_vector

func update_drag()->void:
	if detect_release():
		return
	
	# Get global mouse position and then get the dragged vector.
	var gmp = get_global_mouse_position() 
	_dragged_vector = get_dragged_vector(gmp)
	play_stretch_sound()
	drag_in_limits()
	scale_arrow()
	pass

func update(delta:float) -> void:
	if _state == ANIMAL_STATE.DRAG:
		update_drag()

func set_new_state(new_state: ANIMAL_STATE)->void:
	_state = new_state
	if _state == ANIMAL_STATE.RELEASE:
		freeze = false
		arrow.hide()
	elif _state == ANIMAL_STATE.DRAG:
		freeze = true
		arrow.show()

func handle_animal_died() -> void:
	queue_free()

func scale_arrow() -> void:
	#The arrow points at starting position. It does this by using the math below.
	arrow.rotation = (_start-position).angle()
	pass

func play_stretch_sound() -> void:
	if (_last_dragged_vector - _dragged_vector).length() > 0 and !stretch_sound.playing:
		stretch_sound.play()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_animal_died.connect(handle_animal_died)
	_start = position
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update(delta)
	label.text = '%s' % ANIMAL_STATE.keys()[_state]
	vector_2_debug.text = '%.1f, %.1f' % [_dragged_vector.x, _dragged_vector.y]

func _on_animal_exited() -> void:
	SignalManager.on_animal_died.emit()
	pass # Replace with function body.

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (_state == ANIMAL_STATE.READY and event.is_action_pressed('drag')):
		set_new_state(ANIMAL_STATE.DRAG)
