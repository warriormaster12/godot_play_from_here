@tool
class_name PlayFromHereDebuggerPlugin
extends EditorDebuggerPlugin

var active: bool = false
var use_selected_pos: bool = false
var selected_point_position: Vector3 = Vector3.ZERO

func _has_capture(capture: String) -> bool:
	return capture == "PlayFromHere"

func _capture(message: String, data: Array, session_id: int) -> bool:
	if !active: return true

	var session: EditorDebuggerSession = get_session(session_id)

	match message:
		"PlayFromHere:GetPlayFromHereTransform":
			capture_get_editor_transform(session)
		_:
			push_warning("Unknown debugger message '%s'" % [message])
			return false

	return true


func capture_get_editor_transform(session: EditorDebuggerSession) -> void:
	var transform:Transform3D = EditorInterface.get_editor_viewport_3d().get_camera_3d().transform
	if use_selected_pos:
		var out_transform: Transform3D = Transform3D(transform.basis, selected_point_position)
		session.send_message("PlayFromHere:SetPlayFromHereTransform", [out_transform])
	else:
		session.send_message("PlayFromHere:SetPlayFromHereTransform", [transform])
