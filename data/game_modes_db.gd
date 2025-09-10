# res://data/game_modes_db.gd
extends Node

var modes = [
	{"id": "cpu", "name": "Single Player"},
	{"id": "pvp", "name": "Two Players\n (Hotseat)"},
	{"id": "demo", "name": "Multiplayer\nOnline"},
	{"id": "tournament", "name": "Tournament"}
]

func get_mode_by_id(id: String) -> Dictionary:
	for m in modes:
		if m["id"] == id:
			return m
	return {}
