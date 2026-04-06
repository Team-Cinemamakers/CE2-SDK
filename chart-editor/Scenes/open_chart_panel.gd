extends Panel

@onready var songList = $SongList
@onready var openChart: Button = $OpenChart
@onready var cancel: Button = $Cancel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	openChart.pressed.connect(_open_chart)
	cancel.pressed.connect(_cancel)

func _cancel():
	self.visible = false
	
func _open_chart():
	print("Loading "+songList.get_item_text(songList.get_selected_items()[0]))
	Globals.load_chart(songList.get_item_text(songList.get_selected_items()[0]))
	# print("chart data: "+str(Globals.songJson))
	_cancel()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
