extends Panel

var songInfo

# Messy but no clue how to do it in another way
func _ready():
	Events.chart_converted.connect(load_chart_data)
	
	$SongName.text_submitted.connect(song_name_changed)
	$BPM.value_changed.connect(bpm_changed)
	$Stage.text_submitted.connect(stage_changed)
	$ScrollSpeed.value_changed.connect(scroll_speed_changed)
	$InstPath.text_submitted.connect(inst_path_changed)
	$VocalsPath.text_submitted.connect(vocals_path_changed)
	$PlayerChar.text_submitted.connect(player_char_changed)
	$OpponentChar.text_submitted.connect(opponent_char_changed)

	
func load_chart_data(content):
	songInfo = content.info
	
	$SongName.text = songInfo.name
	$BPM.value = songInfo.bpm
	$Stage.text = songInfo.stage
	$ScrollSpeed.value = songInfo.scrollSpeed
	$InstPath.text = songInfo.songFiles.inst
	$VocalsPath.text = songInfo.songFiles.vocals
	$PlayerChar.text = songInfo.characters[0].character
	$OpponentChar.text = songInfo.characters[1].character

func song_name_changed(new_value:String):
	Data.songData.info.name = new_value

func bpm_changed(new_value:float):
	Data.songData.info.bpm = new_value
	
func stage_changed(new_value:String):
	Data.songData.info.stage = new_value
	
func scroll_speed_changed(new_value:float):
	Data.songData.info.scrollSpeed = new_value
	
func inst_path_changed(new_value:String):
	Data.songData.info.songFiles.inst = new_value
	
func vocals_path_changed(new_value:String):
	Data.songData.info.songFiles.vocals = new_value
	
func player_char_changed(new_value:String):
	Data.songData.info.characters[0].character = new_value
	
func opponent_char_changed(new_value:String):
	Data.songData.info.characters[1].character = new_value
