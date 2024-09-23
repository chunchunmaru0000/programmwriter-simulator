extends Node2D


var rnd = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_login_pressed() -> void:
	$err.frame = rnd.randi_range(0, 3)


func _on_bedni_pressed() -> void:
	$PopupPanel.show()


func _on_logbut_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gos.tscn")
