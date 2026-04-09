extends Control

@onready var filedropdown: MenuButton = $TopPanel/HBoxContainer/File
@onready var filedialogue: FileDialog = $FileDialog
@onready var songSelectList: ItemList = $OpenChartPanel/SongList
@onready var openChartPanal: Panel = $OpenChartPanel

@onready var inst: AudioStreamPlayer = $Inst
@onready var vocals: AudioStreamPlayer = $Vocals

@onready var song_pos_label: Label = $SongPosition

var playingSong:bool = false

#this is INCREDIBLY early, just messing with the base stuff trying to figure out how to do it all

const strumline_object = preload("res://Objects/strumline.tscn")
const note_object = preload("res://Objects/note.tscn")

const y_offset = 200

#GOING TO MAKE THIS A 2D ARRAY rn im too lazy tho
var strumlines: Array[Strumline] = []
var notes: Array[Note] = []

var strumcount:int = 0

var xScrollAmount:int = 0

@onready var note_preview:Sprite2D = $NotePreview

func _ready() -> void:
	#just generate a strumline for testing
	filedropdown.get_popup().id_pressed.connect(_on_filedropdown_id_pressed)
	filedialogue.dir_selected.connect(_on_filedialogue_dir_selected)
	Globals.chartLoaded.connect(_chart_loaded)

func _on_filedialogue_dir_selected(path):
	Globals.workspacePath = path
	
	songSelectList.clear()
	
	print(path)
	Globals.setUpLists()
	for song:String in Globals.songList:
		songSelectList.add_item(song)
		
	Globals.hasWorkspace = true
	filedropdown.get_popup().set_item_disabled(filedropdown.get_popup().get_item_index(0), false)
	filedropdown.get_popup().set_item_disabled(filedropdown.get_popup().get_item_index(1), false)
	
func load_song():
	var vocalsFile = AudioStreamOggVorbis.load_from_file(Globals.chartPath + "/" + Globals.songJson["info"]["songFiles"]["vocals"] +".ogg")
	var instFile = AudioStreamOggVorbis.load_from_file(Globals.chartPath + "/" + Globals.songJson["info"]["songFiles"]["inst"] +".ogg")
	
	vocals.stream = vocalsFile
	inst.stream = instFile
	
	# inst.play()
	
# HELPERS	
	

	
# FUCK
	
func _chart_loaded():
	load_song()
	
	Globals.totalBeats = ceil(Utils.getTotalBeatsInSong(inst.stream.get_length()))
	Globals.totalSteps = Utils.beatsToSteps(Globals.totalBeats)
	
	print("BEATS: "+ str(Globals.totalBeats) + " - STEPS: " + str(Globals.totalSteps))
	
	for i in range(Globals.songJson["info"]["strumlines"].size()):
		var curStrumlineData = Globals.songJson["info"]["strumlines"][i]
		generateNotes(curStrumlineData["strumNotes"].size(), i)
		strumcount += curStrumlineData["strumNotes"].size() + 1
		
	$MainEditorPanel.visible = true
	filedropdown.get_popup().set_item_disabled(filedropdown.get_popup().get_item_index(3), false)

func _on_filedropdown_id_pressed(id: int):
	if (id == 1): # Open Chart
		openChartPanal.visible = true
	if (id == 2): # Open Workspace
		filedialogue.popup_file_dialog()
	if (id == 3): # Save
		var json_string = JSON.stringify(Globals.songJson, "\t")
	
		var file = FileAccess.open(Globals.chartPath + "/" + Globals.songName + ".json", FileAccess.WRITE)
		
		if file:
			# 3. Store the string and close the file
			file.store_string(json_string)
			file.close()
			print("Save successful!")
		else:
			print("Failed to open file: ", FileAccess.get_open_error())

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (not Input.is_action_pressed("unsnap")):
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				scroll_strumline_vertical(1)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				scroll_strumline_vertical(-1)
		else:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				xScrollAmount += 50
				scrollX(50)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				xScrollAmount -= 50
				scrollX(-50)

func _process(_delta: float) -> void:
	if !Globals.chart_ready:
		return

	if (Globals.songJson.has("info")):
		Globals.curStep = Globals.curPosition / Utils.getMsPerStep(Globals.songJson["info"]["bpm"])
		Globals.curBeat = Globals.curStep / 4
		song_pos_label.text = "curBeat: " + str(Globals.curBeat) + "\ncurStep: " + str(Globals.curStep) + "\nposition: " + str(Globals.curPosition)
		
	if Globals.strumlines_hovered.size() > 0:
		for i in range(strumlines.size()):
			update_note_preview(i)
			# CREATE NOTE		
			if Input.is_action_just_pressed("left_click") && !Globals.hovering_over_note && Globals.strumlines_hovered[0].id == i:
				create_note(i)
				
	notes = notes.filter(func(obj): return is_instance_valid(obj))

	if (Input.is_action_just_pressed("play")):
		if (not playingSong):
			vocals.play(Utils.mstos(Globals.curPosition))
			inst.play(Utils.mstos(Globals.curPosition))
			
			playingSong = true
		else:
			vocals.stop()
			inst.stop()
			
			playingSong = false
				
	if (playingSong):
		scrollToSong()
		Globals.curPosition = Utils.stoms(inst.get_playback_position())
	else:
		scrollStrumline()
		
func scroll_strumline_vertical(direction:float):
	if !Globals.chart_ready: return
	
	Globals.curPosition = Utils.getMsPerStep(Globals.songJson["info"]["bpm"]) * round(Globals.curStep)
	Globals.curPosition += Utils.getMsPerStep(Globals.songJson["info"]["bpm"]) * direction
	
	if Globals.curPosition < 0:
		Globals.curPosition = 0

func create_note(strumline:int):
	var note:Note = note_object.instantiate()
	note.strumline = strumline
	note.time = Utils.yPosToMs(note_preview.position.y - strumlines[strumline].position.y, Globals.songJson["info"]["bpm"])
	note.length = 0
	note.type = 0
	note.value = int((note_preview.position.x - strumlines[strumline].position.x) / 50) % 4
					
	note.position = Vector2((50 * note.value), Utils.msToYPos(note.time, Globals.songJson["info"]["bpm"]))

	strumlines[strumline].add_child(note)
					
	var index = 0
	var fuckItJusAppend:bool = false # apparently you cant simply append a note to the chart as it wont load the note in-game

	for j in range(Globals.songJson["strumlines"][strumline]["notes"].size()):
		var curNoteData = Globals.songJson["strumlines"][strumline]["notes"][j]
		var prevNoteData
		var first = true
						
		if (j != -1):
			prevNoteData = Globals.songJson["strumlines"][strumline]["notes"][strumline-1]
			first = false
						
		if (first):
			if (note.time <= curNoteData["time"]):
				index = j
				break
		else:
			if (note.time <= curNoteData["time"] and note.time >= prevNoteData["time"]):
				index = j
				break
							
						# fuckItJusAppend = true
						
	if (not fuckItJusAppend):
		Globals.songJson["strumlines"][strumline]["notes"].insert(index, {
			"time": note.time,
			"type": 0,
			"length": 0,
			"value": note.value
		})
	else:
		Globals.songJson["strumlines"][strumline]["notes"].append({
			"time": note.time,
			"type": 0,
			"length": 0,
			"value": note.value
		})

func update_note_preview(strumline:int):
	if (strumlines[strumline].mouse_on):
		note_preview.position.x = floor(get_global_mouse_position().x / 50) * 50
				
		if (Input.is_action_pressed("unsnap")):
			note_preview.position.y = get_global_mouse_position().y
		else:
			note_preview.position.y = (floor(get_global_mouse_position().y / 50) * 50) - (int(Utils.msToYPos(Globals.curPosition ,Globals.songJson["info"]["bpm"])) % 50)
		note_preview.frame = int((get_global_mouse_position().x - strumlines[strumline].position.x) / 50) % 4

func generateNotes(noteAmt:int, strumlineId:int):
	var strumline: Strumline = strumline_object.instantiate()
	strumline.id = strumlines.size()
	strumline.name = "Strumline ID: " + str(strumline.id)
	strumline.position = Vector2(400+((50*strumcount)) + xScrollAmount, y_offset)
	strumline.size = Vector2(50 * noteAmt, 50 * Globals.totalSteps)
	# bg.modulate = Color(0, 0, 0, 0)
	$Notes.add_child(strumline)
	strumlines.append(strumline)
	
	for i in range(Globals.songJson["strumlines"][strumlineId]["notes"].size()):
		var curNoteData = Globals.songJson["strumlines"][strumlineId]["notes"][i]
		
		var new_note:Note = note_object.instantiate()
		new_note.position = Vector2((50 * curNoteData["value"]), Utils.msToYPos(curNoteData["time"], Globals.songJson["info"]["bpm"]))
		new_note.strumline = strumlineId
		new_note.time = curNoteData["time"]
		new_note.length = curNoteData["length"]
		new_note.type = curNoteData["type"]
		new_note.value = int(curNoteData["value"])
		
		# notes.append(new_note)
		strumline.add_child(new_note)
		
#scrolls, will be refactored when 2D array is added
func scrollX(scroll_amount:float): # for seeing all the strumlines and whatnot
	for note in notes:
		note.position.x += scroll_amount
		
	for strumline in strumlines:
		strumline.position.x += scroll_amount

func scrollToSong():
	for note in notes:
		note.position = Vector2(note.position.x, (Utils.msToYPos(Utils.stoms(inst.get_playback_position()), Globals.songJson["info"]["bpm"]) * -1) + y_offset)
	
	for strumline in strumlines:
		strumline.position = Vector2(strumline.position.x, (Utils.msToYPos(Utils.stoms(inst.get_playback_position()), Globals.songJson["info"]["bpm"]) * -1) + y_offset)

func scrollStrumline() -> void:
	#for square in chart_squares:
	#	square.position = Vector2(square.position.x, square.position.y + (50 * dir))
	for strumline:Strumline in strumlines:
		strumline.position = Vector2(strumline.position.x, (Utils.msToYPos(Globals.curPosition, Globals.songJson["info"]["bpm"]) * -1) + y_offset)
		
	for note:Note in notes:
		if note != null:
			note.position = Vector2(note.position.x, (Utils.msToYPos(Globals.curPosition, Globals.songJson["info"]["bpm"]) * -1) + y_offset)

#simple is_odd function
func is_odd(number) -> bool:
	if number % 2 != 0:
		return true
	else:
		return false
