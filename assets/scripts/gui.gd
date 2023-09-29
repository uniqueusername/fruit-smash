extends CanvasLayer

func _ready():
	$CenterContainer/p1_wins.visible = false
	$CenterContainer/p2_wins.visible = false
	$Label.visible = false

func _process(delta):
	if $Label.visible and Input.is_action_just_pressed("global_reset"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("mnk_reset"):
		get_tree().reload_current_scene()		

func _on_player_meter_changed(value):
	$MarginContainer/VBoxContainer/HBoxContainer/p1_meter.text = str(int(value)) + "%"

func _on_player_2_meter_changed(value):
	$MarginContainer/VBoxContainer/HBoxContainer/p2_meter.text = str(int(value)) + "%"

func _on_player_stock_changed(value):
	if value >= 0 and value < $MarginContainer/VBoxContainer/HBoxContainer2/p1_stock.get_child_count():
		$MarginContainer/VBoxContainer/HBoxContainer2/p1_stock.get_child(0).queue_free()

func _on_player_2_stock_changed(value):
	if value >= 0 and value < $MarginContainer/VBoxContainer/HBoxContainer2/p2_stock.get_child_count():
		$MarginContainer/VBoxContainer/HBoxContainer2/p2_stock.get_child(0).queue_free()

func _on_player_dead():
	$CenterContainer/p2_wins.visible = true
#	$CenterContainer/p2_wins/AnimationPlayer.play("intro")
	$Label/AnimationPlayer.play("blink")

func _on_player_2_dead():
	$CenterContainer/p1_wins.visible = true
#	$CenterContainer/p1_wins/AnimationPlayer.play("intro")
	$Label/AnimationPlayer.play("blink")
