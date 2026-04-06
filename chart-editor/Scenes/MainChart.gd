extends Control

@onready var filedropdown: MenuButton = $TopPanel/HBoxContainer/File
@onready var filedialogue: FileDialog = $FileDialog
@onready var songSelectList: ItemList = $OpenChartPanel/SongList
@onready var openChartPanal: Panel = $OpenChartPanel

@onready var inst: AudioStreamPlayer = $Inst
@onready var vocals: AudioStreamPlayer = $Vocals

@onready var posData: Label = $posData

var playingSong:bool = false

#this is INCREDIBLY early, just messing with the base stuff trying to figure out how to do it all

const chart_square = preload("res://Objects/chart_square.tscn")
const strumline_bg = preload("res://Objects/chart_square_new.tscn")
const note = preload("res://Objects/note.tscn")

const y_offset = 200

#GOING TO MAKE THIS A 2D ARRAY rn im too lazy tho
var strumlines: Array[TextureRect] = []
var chart_squares: Array[ColorRect] = []
var notes: Array[TextureRect] = []

var strumcount:int = 0

var xScrollAmount:int = 0

@onready var notePrev = $NotePreview

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
		generateStrumline(curStrumlineData["strumNotes"].size())
		generateNotes(i)
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
		if (not Input.is_key_pressed(KEY_SHIFT)):
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				Globals.curPosition = Utils.getMsPerStep(Globals.songJson["info"]["bpm"]) * round(Globals.curStep)
				Globals.curPosition += Utils.getMsPerStep(Globals.songJson["info"]["bpm"])
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				Globals.curPosition = Utils.getMsPerStep(Globals.songJson["info"]["bpm"]) * round(Globals.curStep)
				Globals.curPosition -= Utils.getMsPerStep(Globals.songJson["info"]["bpm"])
		else:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				xScrollAmount += 50
				scrollX(50)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				xScrollAmount -= 50
				scrollX(-50)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Globals.songJson.has("info")):
		Globals.curStep = Globals.curPosition / Utils.getMsPerStep(Globals.songJson["info"]["bpm"])
		Globals.curBeat = Globals.curStep / 4
		posData.text = "curBeat: " + str(Globals.curBeat) + "\ncurStep: " + str(Globals.curStep) + "\nposition: " + str(Globals.curPosition)
		
		for i in range(strumlines.size()):
			if (strumlines[i].mouse_on):
				notePrev.position.x = floor(get_global_mouse_position().x / 50) * 50
				
				if (Input.is_key_pressed(KEY_SHIFT)):
					notePrev.position.y = get_global_mouse_position().y
				else:
					notePrev.position.y = (floor(get_global_mouse_position().y / 50) * 50) - (int(Utils.msToYPos(Globals.curPosition ,Globals.songJson["info"]["bpm"])) % 50)
				
				notePrev.get_child(0).frame = int((get_global_mouse_position().x - strumlines[i].position.x) / 50) % 4
				
				# CREATE NOTE
				
				if(Input.is_action_just_pressed("left click") and not Globals.hovering_over_note):
					var note:Node2D = note.instantiate()
					var sus:ColorRect = note.get_child(0)
					note.strumline = i
					note.time = Utils.yPosToMs(notePrev.position.y - strumlines[i].position.y, Globals.songJson["info"]["bpm"])
					note.length = 0
					note.type = 0
					note.value = int((notePrev.position.x - strumlines[i].position.x) / 50) % 4
					
					note.position = Vector2((50 * note.value), Utils.msToYPos(note.time, Globals.songJson["info"]["bpm"]))
					
					note.update_note()

					note.get_child(1).frame = int((notePrev.position.x - strumlines[i].position.x) / 50) % 4
					strumlines[i].add_child(note)
					
					var index = 0
					var fuckItJusAppend:bool = false # apparently you cant simply append a note to the chart as it wont load the note in-game
					
					for j in range(Globals.songJson["strumlines"][i]["notes"].size()):
						var curNoteData = Globals.songJson["strumlines"][i]["notes"][j]
						var prevNoteData
						var first = true
						
						if (j != -1):
							prevNoteData = Globals.songJson["strumlines"][i]["notes"][j-1]
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
						Globals.songJson["strumlines"][i]["notes"].insert(index, {
							"time": note.time,
							"type": 0,
							"length": 0,
							"value": note.value
						})
					else:
						Globals.songJson["strumlines"][i]["notes"].append({
							"time": note.time,
							"type": 0,
							"length": 0,
							"value": note.value
						})
				
		
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
			

#runs through and generates a strumline, simply, gonna be done for each strum on chart loaded
func generateStrumline(noteAmt: int) -> void:
	var bg: TextureRect = strumline_bg.instantiate()
	bg.position = Vector2(400+((50*strumcount)) + xScrollAmount, 0)
	bg.size = Vector2(50 * noteAmt, 50 * Globals.totalSteps)
	$Strumlines.add_child(bg)
	strumlines.append(bg)

func generateNotes(strumlineId:int):
	var strumline:TextureRect = $Strumlines.get_child(strumlineId)
	var bg: TextureRect = strumline_bg.instantiate()
	bg.position = Vector2(strumline.position.x + xScrollAmount, y_offset)
	# bg.modulate = Color(0, 0, 0, 0)
	$Notes.add_child(bg)
	notes.append(bg)
	for i in range(Globals.songJson["strumlines"][strumlineId]["notes"].size()):
		var curNoteData = Globals.songJson["strumlines"][strumlineId]["notes"][i]
		var note:Node2D = note.instantiate()
		var sus:ColorRect = note.get_child(0)
		note.position = Vector2((50 * curNoteData["value"]), Utils.msToYPos(curNoteData["time"], Globals.songJson["info"]["bpm"]))
		note.strumline = strumlineId
		note.time = curNoteData["time"]
		note.length = curNoteData["length"]
		note.type = curNoteData["type"]
		note.value = int(curNoteData["value"])
		
		note.update_note()

		note.get_child(1).frame = int(curNoteData["value"]) % 4
		bg.add_child(note)
		

#scrolls, will be refactored when 2D array is added

func scrollX(scrollX): # for seeing all the strumlines and whatnot
	for note in notes:
		note.position.x += scrollX
		
	for strumline in strumlines:
		strumline.position.x += scrollX

func scrollToSong():
	for note in notes:
		note.position = Vector2(note.position.x, (Utils.msToYPos(Utils.stoms(inst.get_playback_position()), Globals.songJson["info"]["bpm"]) * -1) + y_offset)
	
	for strumline in strumlines:
		strumline.position = Vector2(strumline.position.x, (Utils.msToYPos(Utils.stoms(inst.get_playback_position()), Globals.songJson["info"]["bpm"]) * -1) + y_offset)

func scrollStrumline() -> void:
	#for square in chart_squares:
	#	square.position = Vector2(square.position.x, square.position.y + (50 * dir))
	for strumline:TextureRect in strumlines:
		strumline.position = Vector2(strumline.position.x, (Utils.msToYPos(Globals.curPosition, Globals.songJson["info"]["bpm"]) * -1) + y_offset)
		
	for note:TextureRect in notes:
		note.position = Vector2(note.position.x, (Utils.msToYPos(Globals.curPosition, Globals.songJson["info"]["bpm"]) * -1) + y_offset)

#simple is_odd function
func is_odd(number) -> bool:
	if number % 2 != 0:
		return true
	else:
		return false
