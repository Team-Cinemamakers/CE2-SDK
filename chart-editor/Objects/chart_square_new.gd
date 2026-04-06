extends TextureRect

var mouse_position = Vector2(0, 0)
var mouse_on = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouse_position = get_local_mouse_position()
	
	if ((get_global_mouse_position().x >= position.x && get_global_mouse_position().x <= position.x + size.x) && (get_global_mouse_position().y >= position.y && get_global_mouse_position().y <= position.y + size.y)):
		mouse_on = true
	else: mouse_on = false
