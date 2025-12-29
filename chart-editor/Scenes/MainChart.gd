extends Control

#this is INCREDIBLY early, just messing with the base stuff trying to figure out how to do it all

const chart_square = preload("res://Objects/chart_square.tscn")
const strumline_bg = preload("res://Objects/chart_square.tscn")

#GOING TO MAKE THIS A 2D ARRAY rn im too lazy tho
var chart_squares: Array[ColorRect] = []

func _ready() -> void:
	#just generate a strumline for testing
	generateStrumline(4)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scrollStrumline(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scrollStrumline(1)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#runs through and generates a strumline, simply, gonna be done for each strum on chart loaded
func generateStrumline(noteAmt: int) -> void:
	var bg = strumline_bg.instantiate()
	bg.position = Vector2(300, 0)
	add_child(bg)
	for i in range(18):
		for j in range(noteAmt):
			var square:ColorRect = chart_square.instantiate()
			if is_odd((i * 4) + (j + 1)) and is_odd(i) or not is_odd((i * 4) + (j + 1)) and not is_odd(i):
				square.color = Color.BLACK
			bg.add_child(square)
			square.position = Vector2(bg.position.x + (50 * j), bg.position.y + (50 * i))
			chart_squares.append(square)

#scrolls, will be refactored when 2D array is added
func scrollStrumline(dir: int) -> void:
	for square in chart_squares:
		square.position = Vector2(square.position.x, square.position.y + (50 * dir))

#simple is_odd function
func is_odd(number) -> bool:
	if number % 2 != 0:
		return true
	else:
		return false
