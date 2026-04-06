extends Node

var hasWorkspace:bool = false

var workspacePath:String
var chartPath:String

var songName:String

var characterList:Array[String]
var songList:Array[String]
var noteskinList:Array[String]
var customNoteList:Array[String]
var eventList:Array[String]
var hudList:Array[String]
var stageList:Array[String]

var songJson:Dictionary

var totalBeats:int
var totalSteps:int

var curStep:float
var curBeat:float
var curPosition:float

var chartReady:bool = false

var hovering_over_note:bool = false
var notes_hovered:Array[Node2D]

var hovering_over_strumline:bool = false
var strumlines_hovered:Array[TextureRect]

signal chartLoaded
signal noteSelected(data)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setUpLists():
	songList = setUpListFolders("/content/songs")
	characterList = setUpListFolders("/content/characters")
	stageList = setUpListFolders("/content/stages")
	noteskinList = setUpListFiles("/content/noteskins", ["json"])
	eventList = setUpListFiles("/content/events", ["json"])
	hudList = setUpListFiles("/content/hud", ["hxs"])
	
func setUpListFolders(path:String) -> Array[String]:
	var list:Array[String]
	var folder := DirAccess.open(workspacePath + path)
	if (folder == null): printerr("COULDN'T FIND: " + workspacePath + path); return []
	folder.list_dir_begin()
	for dir:String in folder.get_directories():
		list.append(dir)
	folder.list_dir_end()
	
	return list

func setUpListFiles(path:String, whiteListTypes:Array[String] = []) -> Array[String]:
	var canAdd = false
	var list:Array[String]
	var folder := DirAccess.open(workspacePath + path)
	if (folder == null): printerr("COULDN'T FIND: " + workspacePath + path); return []
	folder.list_dir_begin()
	for file:String in folder.get_files():
		var fileName = file.get_slice(".", 0)
		var fileType = file.get_slice(".", 1)
		
		canAdd = false
		
		if (whiteListTypes.has(fileType)):
			canAdd = true
				
		if (canAdd):
			list.append(fileName)
		else:
			print("cannot add: "+file)
	
	folder.list_dir_end()
	
	return list

func load_chart(song_name:String, difficulty:String = ""):
	var file = workspacePath + "/content/songs/" + song_name + "/" + song_name + ".json"
	chartPath = workspacePath + "/content/songs/" + song_name
	var json_as_text = FileAccess.get_file_as_string(file)
	songJson = JSON.parse_string(json_as_text)
	songName = song_name
	chartLoaded.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (strumlines_hovered.is_empty()):
		hovering_over_strumline = false
	else:
		hovering_over_strumline = true
		
	notes_hovered = notes_hovered.filter(func(obj): return is_instance_valid(obj)) # purge invalid notes

	if (notes_hovered.is_empty()):
		await Input.is_action_just_released("left click")
		get_tree().create_timer(0.1).timeout.connect(_fah)
	else:
		hovering_over_note = true

func _fah():
	hovering_over_note = false
