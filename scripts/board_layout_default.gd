const layout = {
	"Box_00": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_01": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_02": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_03": {
		"type": "ffw",
		"on_land": {"move_to": 16, "trigger_quiz": false, "visual_feedback": true},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_04": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_05": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_06": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_07": {
		"type": "ffw",
		"on_land": {"move_to": 14, "trigger_quiz": false, "visual_feedback": true},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_08": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_09": {
		"type": "rew",
		"on_land": {"move_to": 2, "trigger_quiz": false, "visual_feedback": true},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_10": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_11": {
		"type": "ffw",
		"on_land": {"move_to": 18, "trigger_quiz": false, "visual_feedback": true},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_12": {
		"type": "yellow",
		"on_land": {"do_nothing": true, "trigger_quiz": true},
		"on_correct": {
			"extra_turn": true,
			"trigger_quiz": true,
			"visual_feedback": true
		},
		"on_wrong": {
			"score": -1,
			"return_to_start": true,
			"trigger_quiz": true,
			"extra_turn": false,
			"visual_feedback": true
		}
	},
	"Box_13": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_14": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_15": {
		"type": "kick",
		"on_land": {"do_nothing": true, "trigger_quiz": true},
		"on_correct": {
			"score": 1,
			"jump_to_goal": true,
			"return_to_start": true,
			"trigger_quiz": true,
			"visual_feedback": true
		},
		"on_wrong": {
			"trigger_quiz": true,
			"extra_turn": false,
			"visual_feedback": true
		}
	},
	"Box_16": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_17": {
		"type": "red",
		"on_land": {"do_nothing": true, "trigger_quiz": true},
		"on_correct": {
			"extra_turn": true,
			"trigger_quiz": true,
			"visual_feedback": true
		},
		"on_wrong": {
			"reset_score": true,
			"return_to_start": true,
			"trigger_quiz": true,
			"extra_turn": false,
			"visual_feedback": true
		}
	},
	"Box_18": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_19": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_20": {
		"type": "rew",
		"on_land": {"move_to": 5, "trigger_quiz": false, "visual_feedback": true},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_21": {
		"type": "corner",
		"on_land": {"do_nothing": true, "trigger_quiz": true},
		"on_correct": {
			"score": 1,
			"jump_to_goal": true,
			"return_to_start": true,
			"trigger_quiz": true,
			"visual_feedback": true
		},
		"on_wrong": {
			"trigger_quiz": true,
			"extra_turn": false,
			"visual_feedback": true
		}
	},
	"Box_22": {
		"type": "rew",
		"on_land": {"move_to": 6, "trigger_quiz": false, "visual_feedback": true},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_23": {
		"type": "stay",
		"on_land": {"do_nothing": true, "trigger_quiz": false},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	},
	"Box_24": {
		"type": "corner",
		"on_land": {"do_nothing": true, "trigger_quiz": true},
		"on_correct": {
			"score": 1,
			"jump_to_goal": true,
			"return_to_start": true,
			"trigger_quiz": true,
			"visual_feedback": true
		},
		"on_wrong": {
			"trigger_quiz": true,
			"extra_turn": false,
			"visual_feedback": true
		}
	},
	"Box_25": {
		"type": "goal",
		"on_land": {
			"score": 1,
			"return_to_start": true,
			"jump_to_goal": true,
			"trigger_quiz": false,
			"visual_feedback": true
		},
		"on_correct": {"do_nothing": true, "trigger_quiz": false},
		"on_wrong": {"do_nothing": true, "trigger_quiz": false}
	}
}
