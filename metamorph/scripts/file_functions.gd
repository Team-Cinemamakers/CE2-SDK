extends PopupMenu

var pretty_output:bool = true

func _ready():
	id_pressed.connect(on_id_pressed)
	
func on_id_pressed(id: int):
	match id:
		0: # Import Psych Chart (Pre 1.0)
			%OpenDialog.show()
			
			var path = await %OpenDialog.file_selected
			
			var file = FileAccess.open(path, FileAccess.READ)
			var content = file.get_as_text()
			file.close()
			
			Events.chart_loaded.emit(content, Events.ChartSource.PSYCH_OLD)
		1: # Export CE2 Chart
			%SaveDialog.show()
			
			var path = await %SaveDialog.file_selected
			
			var indent = "\t" if pretty_output else ""
			
			var file = FileAccess.open(path, FileAccess.WRITE)
			file.store_line(JSON.stringify(Data.songData, indent, false))
			file.close()
		2: # Pretty Output (Add newlines)
			pretty_output = !pretty_output
			set_item_checked(get_item_index(2), pretty_output)
		
		
		
