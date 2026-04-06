class_name Note extends Control

@onready var sustain:ColorRect = $Sustain
@onready var base:Sprite2D = $Base

var strumline:int = 0
var time:float = 0
var type:int = 0
var length:float = 0
var value:int = 0

var selected = false

var mouse_down:bool = false

func _ready():
	update_note()
	
	#mouse_entered.connect(_on_mouse_hovered)
	#mouse_exited.connect(_on_mouse_unhovered)
#
#func _on_mouse_hovered():
	#mouse_down = true
	#print("bro")
	#if (not Globals.notes_hovered.has(self)):
		#Globals.notes_hovered.append(self)
#
#func _on_mouse_unhovered():
	#mouse_down = false
	#if (Globals.notes_hovered.has(self)):
		#Globals.notes_hovered.remove_at(Globals.notes_hovered.find(self))

func _process(_delta: float) -> void:
	if (get_parent().position.y + position.y < 200):
		base.self_modulate.a = 0.5
	else:
		base.self_modulate.a = 1
		
	if (selected):
			
		base.self_modulate.g = 0
		base.self_modulate.b = 0
		
		if (Input.is_action_just_pressed("sustain_lengthen")):
			length += Utils.getMsPerStep(Globals.songJson["info"]["bpm"])
			edit_note()
		if (Input.is_action_just_pressed("sustain_shorten")):
			length -= Utils.getMsPerStep(Globals.songJson["info"]["bpm"])
			edit_note()
	else:
		base.self_modulate.g = 1
		base.self_modulate.b = 1
		
	if ((get_global_mouse_position().x >= position.x + get_parent().position.x and get_global_mouse_position().x <= position.x + 50 + get_parent().position.x) and (get_global_mouse_position().y >= position.y + get_parent().position.y and get_global_mouse_position().y <= position.y + 50 + get_parent().position.y)):
		if (not Globals.notes_hovered.has(self)):
			Globals.notes_hovered.append(self)
	else:
		if (Globals.notes_hovered.has(self)):
			Globals.notes_hovered.remove_at(Globals.notes_hovered.find(self))

		
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if (Input.is_action_just_pressed("left_click")):
			if ((event.position.x >= position.x + get_parent().position.x and event.position.x <= position.x + 50 + get_parent().position.x) and (event.position.y >= position.y + get_parent().position.y and event.position.y <= position.y + 50 + get_parent().position.y)):
				if (Input.is_key_pressed(KEY_CTRL)):
					selected = true
					var curNoteData = get_note()
					if (curNoteData != {}):
						Globals.noteSelected.emit([curNoteData])
				else:
					remove_note()
			else:
				selected = false

func get_note() -> Dictionary:
	for i in range(Globals.songJson["strumlines"][strumline]["notes"].size()):
		var curNoteData = Globals.songJson["strumlines"][strumline]["notes"][i]
		if (curNoteData["time"] == time):
			return curNoteData
			
	return {}

func edit_note():
	update_note()
	var curNoteData = get_note()
	if (curNoteData != {}):
		curNoteData["type"] = type
		if (length > 0): curNoteData["length"] = length
		else: curNoteData["length"] = 0

func remove_note():
	Globals.notes_hovered.clear()
			
	for i in range(Globals.songJson["strumlines"][strumline]["notes"].size()):
		var curNoteData = Globals.songJson["strumlines"][strumline]["notes"][i]
		
		if (curNoteData["time"] == time):
			Globals.songJson["strumlines"][strumline]["notes"].remove_at(i)
			queue_free()
			break

func update_note():
	if (length > 0): sustain.size.y = Utils.msToYPos(length, Globals.songJson["info"]["bpm"]) + 25
	else: sustain.size.y = 0
	
	if value < 0 || value > base.hframes: return
	base.frame = int(value) % 4
