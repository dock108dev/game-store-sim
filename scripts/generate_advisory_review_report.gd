extends SceneTree

const AdvisoryReviewReportScript: GDScript = preload(
	"res://game/scripts/automation/advisory_review_report.gd"
)


func _init() -> void:
	var args: Dictionary = _parse_args(OS.get_cmdline_user_args())
	if not bool(args.get("ok", false)):
		push_error(str(args.get("error", "Invalid advisory review arguments.")))
		quit(2)
		return
	var manifest_path: String = str(args.get("manifest", ""))
	var manifest: Dictionary = _read_json(manifest_path)
	if manifest.is_empty():
		push_error("Cannot read source manifest: %s" % manifest_path)
		quit(3)
		return
	var result: Dictionary = AdvisoryReviewReportScript.write_reports(
		manifest_path,
		manifest,
		str(args.get("output_dir", ""))
	)
	if not bool(result.get("ok", false)):
		push_error(str(result.get("error", "Cannot write advisory review report.")))
		quit(4)
		return
	print("Advisory review JSON: %s" % str(result.get("json_path", "")))
	print("Advisory review Markdown: %s" % str(result.get("markdown_path", "")))
	quit(0)


func _parse_args(raw_args: PackedStringArray) -> Dictionary:
	var manifest_path: String = ""
	var output_dir: String = ""
	var i: int = 0
	while i < raw_args.size():
		var arg: String = raw_args[i]
		match arg:
			"--manifest":
				if i + 1 >= raw_args.size():
					return {"ok": false, "error": "--manifest requires a path"}
				manifest_path = raw_args[i + 1]
				i += 2
			"--output-dir":
				if i + 1 >= raw_args.size():
					return {"ok": false, "error": "--output-dir requires a path"}
				output_dir = raw_args[i + 1]
				i += 2
			_:
				if arg.begins_with("--manifest="):
					manifest_path = arg.get_slice("=", 1)
				elif arg.begins_with("--output-dir="):
					output_dir = arg.get_slice("=", 1)
				i += 1
	if manifest_path.is_empty():
		return {"ok": false, "error": "Missing required --manifest path"}
	return {"ok": true, "manifest": manifest_path, "output_dir": output_dir}


func _read_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}
