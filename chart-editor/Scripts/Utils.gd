extends Node

func stoms(seconds:float) -> float:
	return seconds * 1000
	
func mstos(milliseconds:float) -> float:
	return milliseconds / 1000
	
func getMsPerBeat(bpm:float) -> float:
	return 60000 / bpm
	
func getMsPerStep(bpm:float) -> float:
	return 60000 / bpm / 4

func getTotalBeatsInSong(songLength:float) -> float:
	return stoms(songLength) / getMsPerBeat(Globals.songJson["info"]["bpm"])
	
func beatsToSteps(beats:int) -> int:
	return beats * 4
	
func stepsToBeats(steps:float) -> float:
	return steps / 4
	
func msToYPos(milliseconds:float, bpm:float) -> float:
	return milliseconds / getMsPerStep(bpm) * 50

func yPosToMs(y:float, bpm:float):
	return y / 50 * getMsPerStep(bpm)
