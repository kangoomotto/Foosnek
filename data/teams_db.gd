# res://data/teams_db.gd
extends Node

var teams: Array = [
	{
		"id": "emericos",
		"name": "Eméricos",
		"shield_path": "res://assets/images/teams/emericos/shield.png"
	},
	{
		"id": "salta",
		"name": "Salta",
		"shield_path": "res://assets/images/teams/salta/shield.png"
	},
	{
		"id": "atletico_potosi",
		"name": "Atlético Potosí",
		"shield_path": "res://assets/images/teams/atletico_potosi/shield.png"
	},
	{
		"id": "club_juana",
		"name": "Club Juana",
		"shield_path": "res://assets/images/teams/club_juana/shield.png"
	},
	{
		"id": "los_blues",
		"name": "Los Blues",
		"shield_path": "res://assets/images/teams/los_blues/shield.png"
	},
	{
		"id": "fc_benitos",
		"name": "FC Benitos",
		"shield_path": "res://assets/images/teams/fc_benitos/shield.png"
	},
	{
		"id": "tapatia",
		"name": "Tapatía",
		"shield_path": "res://assets/images/teams/tapatia/shield.png"
	},
	{
		"id": "melenas",
		"name": "Melenas",
		"shield_path": "res://assets/images/teams/melenas/shield.png"
	},
	{
		"id": "venados_fc",
		"name": "Venados FC",
		"shield_path": "res://assets/images/teams/venados_fc/shield.png"
	},
	{
		"id": "montesinos",
		"name": "Montesinos",
		"shield_path": "res://assets/images/teams/montesinos/shield.png"
	},
	{
		"id": "hidroelectricos",
		"name": "Hidroeléctricos",
		"shield_path": "res://assets/images/teams/hidroelectricos/shield.png"
	},
	{
		"id": "pachuca",
		"name": "Pachuca",
		"shield_path": "res://assets/images/teams/pachuca/shield.png"
	},
	{
		"id": "pipos",
		"name": "Pipos",
		"shield_path": "res://assets/images/teams/pipos/shield.png"
	},
	{
		"id": "leon",
		"name": "León",
		"shield_path": "res://assets/images/teams/leon/shield.png"
	},
	{
		"id": "crettaro",
		"name": "Crettaro",
		"shield_path": "res://assets/images/teams/crettaro/shield.png"
	},
	{
		"id": "demons",
		"name": "Demons",
		"shield_path": "res://assets/images/teams/demons/shield.png"
	},
	{
		"id": "zucaritos",
		"name": "Zucaritos",
		"shield_path": "res://assets/images/teams/zucaritos/shield.png"
	},
	{
		"id": "tollohcan",
		"name": "Tollohcan",
		"shield_path": "res://assets/images/teams/tollohcan/shield.png"
	},
	{
		"id": "cpu_fc",
		"name": "CPU FC",
		"shield_path": "res://assets/images/teams/cpu_fc/shield.png"
	}
] 

# 🔹 Get all teams
func get_teams() -> Array:
	return teams

# 🔹 Get team by ID
func get_team_by_id(team_id: String) -> Dictionary:
	for team in teams:
		if team["id"] == team_id:
			return team
	return {}

# 🔹 Get CPU Mascot Team (Default for Single Player)
func get_cpu_team() -> Dictionary:
	return get_team_by_id("cpu_fc")
