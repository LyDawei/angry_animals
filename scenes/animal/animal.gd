extends RigidBody2D

enum ANIMAL_STATE {READY, DRAG, RELEASE}
@onready var label: Label 						= $AnimalState
@onready var vector_2_debug: Label 				= $Vector2_Debug
@onready var stretch_sound: AudioStreamPlayer2D 	= $StretchSound
@onready var launch_sound: AudioStreamPlayer2D 	= $LaunchSound
@onready var arrow: Sprite2D 					= $Arrow
@onready var collision_sound: AudioStreamPlayer2D = $CollisionSound


const DRAG_LIM_MAX: Vector2 	= Vector2(0,60)
const DRAG_LIM_MIN: Vector2 	= Vector2(-60,0)
const IMPULSE_MULT: float  	= 20.0
const IMPULSE_MAX: 	float	= 1200.0

var _state: ANIMAL_STATE 			= ANIMAL_STATE.READY
var _start: Vector2 					= Vector2.ZERO
var _drag_start: Vector2 			= Vector2.ZERO
var _dragged_vector: Vector2 		= Vector2.ZERO
var _last_dragged_vector: Vector2 	= Vector2.ZERO
var _arrow_scale_x: float			= 0.0
var _last_collision_count:int		= 0

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
	
func update_flight()->void:
	if (
		_last_collision_count == 0 and
		get_contact_count() > 0 and
		!collision_sound.playing
		):
		collision_sound.play()
	_last_collision_count = get_contact_count()

func update(delta:float) -> void:
	if _state == ANIMAL_STATE.DRAG:
		update_drag()
	if _state == ANIMAL_STATE.RELEASE:
		update_flight()

func set_new_state(new_state: ANIMAL_STATE)->void:
	_state = new_state
	if _state == ANIMAL_STATE.RELEASE:
		freeze = false
		arrow.hide()
		launch_sound.play()
		apply_central_impulse(get_impulse())
		SignalManager.on_attempt_made.emit()

	elif _state == ANIMAL_STATE.DRAG:
		_drag_start = get_global_mouse_position()
		freeze = true
		arrow.show()

func handle_animal_died() -> void:
	queue_free()

func scale_arrow() -> void:
	var imp_len = get_impulse().length()
	var perc = imp_len/IMPULSE_MAX
	
	arrow.scale.x = (_arrow_scale_x * perc) + _arrow_scale_x
	#The arrow points at starting position. It does this by using the math below.
	arrow.rotation = (_start-position).angle()
	
	pass

func play_stretch_sound() -> void:
	if (_last_dragged_vector - _dragged_vector).length() > 0 and !stretch_sound.playing:
		stretch_sound.play()

func get_impulse() -> Vector2:
	return _dragged_vector * -1 * IMPULSE_MULT

func die() -> void:
	SignalManager.on_animal_died.emit()

func on_animal_collide_platform()->void:
	if get_contact_count() == 1:
		collision_sound.play()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_arrow_scale_x = arrow.scale.x
	SignalManager.on_animal_died.connect(handle_animal_died)
	_start = position
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update(delta)
	label.text = '%s' % ANIMAL_STATE.keys()[_state]
	vector_2_debug.text = '%.1f, %.1f' % [_dragged_vector.x, _dragged_vector.y]

func _on_animal_exited() -> void:
	die()
 
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (_state == ANIMAL_STATE.READY and event.is_action_pressed('drag')):
		set_new_state(ANIMAL_STATE.DRAG)


func _on_sleeping_state_changed() -> void:
	if sleeping:
		var colliding_bodies = get_colliding_bodies()
		if colliding_bodies.size() > 0:
			colliding_bodies[0].die()
		call_deferred('die')
	pass # Replace with function body.
