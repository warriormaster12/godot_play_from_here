extends Node
class_name PlayFromHere


static func setup(capture: Callable) -> void:
	if EngineDebugger.is_active():
		EngineDebugger.register_message_capture("PlayFromHere", capture)
		EngineDebugger.send_message("PlayFromHere:GetPlayFromHereTransform", [])
