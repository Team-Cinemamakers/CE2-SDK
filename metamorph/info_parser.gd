extends Panel

func _ready():
	Events.psych_chart_loaded.connect(parse_psych_chart)
	
func parse_psych_chart(content):
	var song = JSON.parse_string(content).song
	
	$SongName.text = song.song
	pass
