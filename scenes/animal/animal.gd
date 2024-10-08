extends RigidBody2D

enum ANIMAL_STATE {READY, DRAG, RELEASE}
@onready var label: Label = $Label

var _state = ANIMAL_STATE.READY

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_animal_died.connect(handle_animal_died)
	pass # Replace with function body.
	
func detect_release()->bool:
	if _state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released('drag'):
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false
	
	

func update_drag()->void:
	if detect_release():
		return
	
	var gmp = get_global_mouse_position()
	position = gmp
	pass

func update(delta:float) -> void:
	if _state == ANIMAL_STATE.DRAG:
		update_drag()

func set_new_state(new_state: ANIMAL_STATE)->void:
	_state = new_state
	if _state == ANIMAL_STATE.RELEASE:
		freeze = false
	elif _state == ANIMAL_STATE.DRAG:
		freeze = true
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update(delta)
	label.text = '%s' % ANIMAL_STATE.keys()[_state]
	


func _on_animal_exited() -> void:
	SignalManager.on_animal_died.emit()
	pass # Replace with function body.

func handle_animal_died() -> void:
	queue_free()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (_state == ANIMAL_STATE.READY and event.is_action_pressed('drag')):
		print('test?')
		set_new_state(ANIMAL_STATE.DRAG)
		pass # Replace with function body.
