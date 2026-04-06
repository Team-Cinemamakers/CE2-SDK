class_name Strumline extends TextureRect

var id:int = -1
var mouse_position = Vector2(0, 0)
var mouse_on = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	mouse_position = get_local_mouse_position()
	
	if ((get_global_mouse_position().x >= position.x && get_global_mouse_position().x <= position.x + size.x) && (get_global_mouse_position().y >= position.y && get_global_mouse_position().y <= position.y + size.y)):
		mouse_on = true
		if (not Globals.strumlines_hovered.has(self)):
			Globals.strumlines_hovered.append(self)
	else:
		mouse_on = false
		if (Globals.strumlines_hovered.has(self)):
			Globals.strumlines_hovered.remove_at(Globals.strumlines_hovered.find(self))
