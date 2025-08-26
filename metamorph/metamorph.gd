extends Control

func _ready():
	$LoadPsychButton/OpenDialog.file_selected.connect(on_psych_chart_selected)
	
	$LoadPsychButton.pressed.connect(func ():
		$LoadPsychButton/OpenDialog.visible = true	
		)
		
	Events.psych_chart_converted.connect(on_psych_chart_converted)

func on_psych_chart_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	Events.psych_chart_loaded.emit(content)

func on_psych_chart_converted(content) -> void:	
	$LoadPsychButton/SaveDialog.visible = true
	
	var path = await $LoadPsychButton/SaveDialog.file_selected
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_line(content)
	file.close()
	
	
