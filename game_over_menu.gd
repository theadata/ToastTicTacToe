extends CanvasLayer

signal restart

func _on_restart_button_pressed():
	#AudioPlayer.play_music_level()
	restart.emit()
