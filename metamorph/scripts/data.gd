extends Node

var songData

func _ready():
	Events.chart_loaded.connect(on_chart_loaded)
	
func on_chart_loaded(content, source):
	match source:
		Events.ChartSource.PSYCH_OLD:
			songData = Converter.psych_old_to_ce2(content)
	
	if songData != null:
		Events.chart_converted.emit(songData)
