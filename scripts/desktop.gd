extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var times = Singleton.time.split(':')
	$Time.text = times[1] + ':' + times[2]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_down() -> void:
	Singleton.go_to("res://scenes/game.tscn")


func _on_chrome_button_down() -> void:
	Singleton.go_to("res://scenes/chrome.tscn")


func _on_vs_button_down() -> void:
	Singleton.go_to("res://scenes/visual_studio.tscn")


func _on_video_stream_player_finished() -> void:
	remove_child($WinLoad)
	$AudioStreamPlayer2D.play()
