extends Panel

@onready var tabs = $TabContainer

@onready var songTab = $TabContainer/Song
@onready var noteTab = $TabContainer/Note
@onready var eventsTab = $TabContainer/Events
@onready var strumlinesTab = $TabContainer/Strumlines
@onready var charactersTab = $TabContainer/Characters
@onready var dataTab = $TabContainer/Data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tabs.tab_changed.connect(_tab_changed)
	
	print(get_tree_string())
	# character tab
	charactersTab.get_node("ItemList").item_selected.connect(_select_char)
	charactersTab.get_node("AddUpdateChar").pressed.connect(_add_or_update_char)
	charactersTab.get_node("RemoveChar").pressed.connect(_remove_char)

func _tab_changed(id):
	if (id == 4): # Characters
		charTab()

# CHARACTER TAB
func charTab():
	var charList:ItemList = charactersTab.get_node("ItemList")
	var charOptionList:OptionButton = charactersTab.get_node("CharacterList")
		
	charList.clear()
	charOptionList.clear()
		
	for i in range(Globals.songJson["info"]["characters"].size()):
		var charData = Globals.songJson["info"]["characters"][i]
		charList.add_item(charData["name"])
		
	for i in range(Globals.characterList.size()):
		charOptionList.add_item(Globals.characterList[i])

func _select_char(index):
	charactersTab.get_node("CharacterList").select(get_index_by_name(charactersTab.get_node("CharacterList"), Globals.songJson["info"]["characters"][charactersTab.get_node("ItemList").get_selected_items()[0]]["character"]))
	charactersTab.get_node("CharacterName").text = Globals.songJson["info"]["characters"][charactersTab.get_node("ItemList").get_selected_items()[0]]["name"]
	charactersTab.get_node("PositionMarker").text = Globals.songJson["info"]["characters"][charactersTab.get_node("ItemList").get_selected_items()[0]]["positionMarker"]

func _add_or_update_char():
	var updateChar = false
	var updateIndex = 0
	for i in range(Globals.songJson["info"]["characters"].size()):
		var charData = Globals.songJson["info"]["characters"][i]
		if (charactersTab.get_node("CharacterList").text == charData["name"]):
			updateChar = true
			updateIndex = i
			break
			
	if (updateChar):
		Globals.songJson["info"]["characters"][updateIndex]["character"] = Globals.characterList[charactersTab.get_node("CharacterList").selected]
		Globals.songJson["info"]["characters"][updateIndex]["positionMarker"] = charactersTab.get_node("PositionMarker").text
	else:
		Globals.songJson["info"]["characters"].append({
			"name": charactersTab.get_node("CharacterName").text,
			"character": Globals.characterList[charactersTab.get_node("CharacterList").selected],
			"positionMarker": charactersTab.get_node("PositionMarker").text
		})
	
	print(str(Globals.songJson["info"]["characters"]))
	charTab()
	
func _remove_char():
	Globals.songJson["info"]["characters"].remove_at(charactersTab.get_node("ItemList").get_selected_items()[0])
	charTab()

# HELPER FUNCTIONS
func get_index_by_name(option_button: OptionButton, button_name: String) -> int:
	for i in range(option_button.get_item_count()):
		if option_button.get_item_text(i) == button_name:
			return i
	return -1  # Return -1 if the name is not found
