extends TextureRect

# =========================================================
# 🔹 SIGNALS
# =========================================================
signal animation_finished  # Emitted when the shame animation finishes

# =========================================================
# 🔹 PUBLIC FUNCTION: Show the shame animation
# =========================================================
func show_popup(player_id: int) -> void:
	visible = true  # Make the Shame popup visible on screen
	# 🔹 Center the particles inside the popup area
	#$ShameParticles.position = Vector2(size.x / 2, 200)

	# 🔹 Restart particle system — this is crucial for unique materials
	$ShameParticles.emitting = false  # 🔹 Fully stop
	await get_tree().process_frame     # 🔹 Wait one frame
	$ShameParticles.restart()          # 🔹 Clear particles on GPU
	$ShameParticles.emitting = true    # 🔹 Play again

	# 🔹 Reset the popup’s opacity and position before animating
	modulate.a = 1.0  # Full opacity
	position = Vector2((get_viewport_rect().size.x - size.x) / 2, 200)  # Center horizontally

	# 🔹 Animate popup — position drops and fades out in parallel
	var tween := create_tween()
	tween.parallel().tween_property(self, "position:y", position.y + 500, 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1).set_delay(1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_on_fade_complete"))
	animation_finished.emit()
	EventsBus.shame_animation_done.emit()
	#Moves the popup down by 1000 pixels.
	#The movement will last 5 seconds.
	#modulate.a = 0.0 means invisible.
	#The fade-out won't begin until 1 second after the tween starts.
# =========================================================
# 🔹 CALLBACK: When animation is complete
# =========================================================
func _on_fade_complete():
	visible = false
	animation_finished.emit()
	EventsBus.goal_animation_done.emit()
