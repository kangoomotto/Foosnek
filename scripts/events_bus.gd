extends Node

# =========================================================
# 🔹 CORE GAME FLOW — Start, dice, restart
# =========================================================
signal start_pressed
signal request_dice_roll
signal dice_roll_started
signal dice_rolled(value: int)
signal play_again_requested
signal hud_reset_requested
signal hud_start_requested
signal request_next_quiz
signal popup_ready
signal show_popup(slot_type: String, position: Vector2, is_correct: bool) # ✅ now supports is_correct
signal outcome_finished
signal grant_extra_turn(extra: bool)
signal request_goal_jump(chip: Node2D)

# =========================================================
# 🔹 QUIZ SYSTEM
# =========================================================
signal quiz_requested(chip: Node2D, slot_data: Dictionary)
signal quiz_completed(chip: Node2D, correct: bool)
signal popup_animation_done
signal quiz_delayed_requested(chip: Node2D, slot_data: Dictionary)

# =========================================================
# 🔹 SCORING
# =========================================================
signal score_updated(player_id: int, new_score: int)
signal goal_scored(player_id: int)

# =========================================================
# 🔹 MATCH STATE
# =========================================================
signal halftime_shown(stats: Dictionary)
signal halftime_closed
signal halftime_reached
signal match_ended
signal winner_declared(winner_id: int, stats: Dictionary)
signal winner_popup_requested(stats: Dictionary)
signal main_menu

# =========================================================
# 🔹 TIMER
# =========================================================
signal start_timer
signal pause_timer
signal resume_timer
signal timer_tick(minutes: int, seconds: int)

# =========================================================
# 🔹 SUDDEN DEATH
# =========================================================
signal sudden_death_started
signal sudden_death_score_updated(player_id: int, score: int)
signal sudden_death_start
signal goal_animation_requested(player_id: int)
signal shame_animation_requested(player_id: int)

# =========================================================
# 🔹 TEAMS / MODE
# =========================================================
signal game_mode_changed(mode: String)
signal game_mode_selected(mode: String)
signal selecting_player_changed(player_index: int)
signal team_selected(player_index: int, team_id: String)
signal team_shield_updated(player_index: int, shield_path: String)
signal cpu_team_assigned(team_name: String)
signal teams_finalized(team1_id: String, team2_id: String)
signal request_team_menu(player_index: int)
signal show_team_menu(player_index: int)
signal active_player_highlight_changed(player_index: int)

# =========================================================
# 🔹 COURT
# =========================================================
signal court_selected(court_data: Dictionary)

# =========================================================
# 🔹 ABOUT US
# =========================================================
signal about_us_opened(url: String)
signal about_us_feedback(comment: String)

# =========================================================
# 🔹 DEBUG
# =========================================================
@export var DEBUG_MODE: bool = false
@export var debug_force_dice: int = 0
