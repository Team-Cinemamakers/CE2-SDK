extends Node

static func psych_old_to_ce2(content):
	var parsed_content:Dictionary = JSON.parse_string(content)
	if !parsed_content.has("song"):
		print("Selected file is not a song")
		return null
		
	var song = parsed_content.song
	
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
			var noteLength = note[2]
			# Player section
			if section.mustHitSection:
				if noteData <= 3:
					playerNotes.push_back({
						"time": noteTime,
						"type": 0,
						"value": noteData,
						"length": noteLength
					})
				else:
					opponentNotes.push_back({
						"time": noteTime,
						"type": 0,
						"value": noteData - 4,
						"length": noteLength
					})
			# Opponent section
			else:
				if noteData <= 3:
					opponentNotes.push_back({
						"time": noteTime,
						"type": 0,
						"value": noteData,
						"length": noteLength
					})
				else:
					playerNotes.push_back({
						"time": noteTime,
						"type": 0,
						"value": noteData - 4,
						"length": noteLength
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
	
	# Temporary, no real event porting for now, but not having any events field WILL crash the engine
	converted["events"] = [
		
	]
	
	return converted
