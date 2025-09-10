static func get_slot_type(index: int) -> String:
	return slot_types.get(index, "DEFAULT")

static var slot_types = {
	"corner": {
		"label": "¡Tiro de esquina!",
		"image_pool": [
			"res://assets/images/slot_cards/corner_01.png"
		]
	},
	"penalty": {
		"label": "¡Penal!",
		"image_pool": [
			"res://assets/images/slot_cards/penalty_01.png"
		]
	},
	"suddendeath": {
		"label": "¡Muerte súbita!",
		"image_pool": [
			"res://assets/images/slot_cards/penalty_01.png"
		]
	},
	"red": {
		"label": "¡Tarjeta roja!",
		"image_pool": [
			"res://assets/images/slot_cards/red_01.png",
			"res://assets/images/slot_cards/red_02.png",
		]
	},
	"yellow": {
		"label": "¡Tarjeta amarilla!",
		"image_pool": [
			"res://assets/images/slot_cards/yellow_01.png"
		]
	},
	"kick": {
		"label": "¡Tiro libre!",
		"image_pool": [
			"res://assets/images/slot_cards/kick_01.png"
		]
	}
}
