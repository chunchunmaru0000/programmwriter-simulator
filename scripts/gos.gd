extends Node2D

var uslugi: Array = Singleton.uslugi

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for a in 10:		
		var usluga = TextureRect.new()
		usluga.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		usluga.texture = load("res://images/gos_panel.png")
		usluga.custom_minimum_size = Vector2(632 - 8, 160)
		$UslugiScroll/UslugiBox.add_child(usluga)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_button_down() -> void:
	Singleton.save_progress()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
