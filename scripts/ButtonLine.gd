extends Button

signal on_click(name)

func set_text(txt):
	text = txt

func _on_Button_pressed():
	emit_signal("on_click", text.substr(0, len(text) - 5))
