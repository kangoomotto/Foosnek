extends Node

# =========================================================
# 🔹 COURT LAYOUT DEFINITIONS
# =========================================================
var layouts: Array = [
	{
		"id": "stadium",
		"name": "Stadium",
		"bg": "res://assets/images/boards/board_bg_layout_stadium.png"
	},
	{
		"id": "beach",
		"name": "Beach",
		"bg": "res://assets/images/boards/board_bg_layout_beach.png"
	},
	{
		"id": "street",
		"name": "Street",
		"bg": "res://assets/images/boards/board_bg_layout_street.png"
	}
]

func get_court_by_id(court_id: String) -> Dictionary:
	for court in layouts:
		if court["id"] == court_id:
			return court
	return {}
