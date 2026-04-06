extends Panel

@onready var tabs = $TabContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tabs.tab_changed.connect(_tab_changed)
	
	# character tab
	$TabContainer/Characters/ItemList.item_selected.connect(_select_char)
	$TabContainer/Characters/AddUpdateChar.pressed.connect(_add_or_update_char)
	$TabContainer/Characters/RemoveChar.pressed.connect(_remove_char)

func _tab_changed(id):
	if (id == 4): # Characters
		charTab()

# CHARACTER TAB
func charTab():
	var charList:ItemList = tabs.get_child(4).get_child(0)
	var charOptionList:OptionButton = tabs.get_child(4).get_child(3)
		
	charList.clear()
	charOptionList.clear()
		
	for i in range(Globals.songJson["info"]["characters"].size()):
		var charData = Globals.songJson["info"]["characters"][i]
		charList.add_item(charData["name"])
		
	for i in range(Globals.characterList.size()):
		charOptionList.add_item(Globals.characterList[i])

func _select_char():
	$TabContainer/Characters/CharacterList.select(get_index_by_name($TabContainer/Characters/CharacterList, Globals.songJson["info"]["characters"][$TabContainer/Characters/ItemList.get_selected_items()[0]]["character"]))
	$TabContainer/Characters/CharacterName.text = Globals.songJson["info"]["characters"][$TabContainer/Characters/ItemList.get_selected_items()[0]]["name"]
	$TabContainer/Characters/PositionMarker.text = Globals.songJson["info"]["characters"][$TabContainer/Characters/ItemList.get_selected_items()[0]]["positionMarker"]

func _add_or_update_char():
	var updateChar = false
	var updateIndex = 0
	for i in range(Globals.songJson["info"]["characters"].size()):
		var charData = Globals.songJson["info"]["characters"][i]
		if ($TabContainer/Characters/CharacterName.text == charData["name"]):
			updateChar = true
			updateIndex = i
			break
			
	if (updateChar):
		Globals.songJson["info"]["characters"][updateIndex]["character"] = Globals.characterList[$TabContainer/Characters/CharacterList.selected]
		Globals.songJson["info"]["characters"][updateIndex]["positionMarker"] = $TabContainer/Characters/PositionMarker.text
	else:
		Globals.songJson["info"]["characters"].append({
			"name": $TabContainer/Characters/CharacterName.text,
			"character": Globals.characterList[$TabContainer/Characters/CharacterList.selected],
			"positionMarker": $TabContainer/Characters/PositionMarker.text
		})
	
	print(str(Globals.songJson["info"]["characters"]))
	charTab()
	
func _remove_char():
	Globals.songJson["info"]["characters"].remove_at($TabContainer/Characters/ItemList.get_selected_items()[0])
	charTab()

func get_index_by_name(option_button: OptionButton, button_name: String) -> int:
	for i in range(option_button.get_item_count()):
		if option_button.get_item_text(i) == button_name:
			return i
	return -1  # Return -1 if the name is not found
