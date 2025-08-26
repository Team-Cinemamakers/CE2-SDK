extends Node

enum ChartSource {
	PSYCH_OLD
}

signal chart_loaded(content:String, chart_type:ChartSource)
signal chart_converted(content:Dictionary)
