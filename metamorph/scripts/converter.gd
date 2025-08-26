extends Node

func _ready():
	Events.psych_chart_loaded.connect(on_psych_chart_loaded)
# ============================
# PSYCH TO CE2 CHART CONVERTER
# ============================
func on_psych_chart_loaded(content):
	var song = JSON.parse_string(content).song
	
	# New object that holds the converted song
	var converted = {}
	
	# ========
	# METADATA
	# ========
	
	converted["info"] = {
		# Metadata
		"name": song.song,
		"bpm": song.bpm,
		"scrollSpeed": song.speed,
		"stage": song.stage,
		"characters":[
			{
				"name": song.player1,
				"character": song.player1,
				"positionMarker": "playerPos"
			},
			{
				"name": song.player2,
				"character": song.player2,
				"positionMarker": "opponentPos"
			}
		],
		"songFiles": {
			"inst": "Inst",
			"vocals": "Vocals"
		},
		# Default strumline configuration
		"strumlines": [
			{
				"characters": [song.player1],
				"kerning": 125,
				"playable": true,
				"viewable": true,
				"position": [
					700,
					0
				],
				"scale": [
					0.75,
					0.75
				],
				"strumNotes": [
					{
						"angle": 270,
						"input": "noteLeft"
					},
					{
						"angle": 180,
						"input": "noteDown"
					},
					{
						"angle": 0,
						"input": "noteUp"
					},
					{
						"angle": 90,
						"input": "noteRight"
					}
				]
			},
			{
				"characters": [song.player2],
				"kerning": 125,
				"playable": false,
				"position": [
					0,
					0
				],
				"scale": [
					0.75,
					0.75
				],
				"strumNotes": [
					{
						"angle": 270,
						"input": "noteLeft"
					},
					{
						"angle": 180,
						"input": "noteDown"
					},
					{
						"angle": 0,
						"input": "noteUp"
					},
					{
						"angle": 90,
						"input": "noteRight"
					}
				]
			},
		]
	}
	
	# =====
	# NOTES
	# =====
	
	var playerNotes = []
	var opponentNotes = []
	
	for section in song.notes:
		for note in section.sectionNotes:
			var noteTime = note[0]
			var noteData = note[1]
			# Player section
			if section.mustHitSection:
				if noteData <= 3:
					playerNotes.push_back({
						"time": noteTime,
						"type": 0,
						"value": noteData
					})
				else:
					opponentNotes.push_back({
						"time": noteTime,
						"type": 0,
						"value": noteData - 4
					})
			# Opponent section
			else:
				if noteData <= 3:
					opponentNotes.push_back({
						"time": noteTime,
						"type": 0,
						"value": noteData
					})
				else:
					playerNotes.push_back({
						"time": noteTime,
						"type": 0,
						"value": noteData - 4
					})
				
				
	
	converted["strumlines"] = [
		{
			"characters": [song.player1],
			"notes": playerNotes
		},
		{
			"characters": [song.player2],
			"notes": opponentNotes
		}
	]
	
	var json = JSON.stringify(converted, "\t", false)
	Events.psych_chart_converted.emit(json)
