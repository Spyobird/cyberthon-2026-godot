class_name APIPlayerStateLoader
extends PlayerStateLoader

const BASE_URL = "http://127.0.0.1:9000"

var _http_request: HTTPRequest

func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.timeout = 1.0

func _make_request():
	var error = _http_request.request(BASE_URL)
	return error

func _handle_request_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_TIMEOUT:
		print("Timeout, check if server is running")
		return null
	elif result == HTTPRequest.RESULT_CANT_CONNECT:
		print("Cannot connect, check if server is running")
		return null
	elif result != HTTPRequest.RESULT_SUCCESS:
		print("Unexpected error: ", result)
		return null
	
	if response_code != 200:
		print("HTTP error: ", response_code)
		return null
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	if !json:
		print("JSON parse error")
		return null
	
	var messages = json.get("messages", {})
	return messages

func _parse_player_state(data: Dictionary) -> PlayerState:
	var inventory = data.get("inventory", [])
	var stats = data.get("stats", [])
	stats = Vector3i(stats.get(0), stats.get(1), stats.get(2))
	var moves = data.get("moves", [])
	return PlayerState.new(inventory, stats, moves)

func load_player_state() -> PlayerState:
	var error = _make_request()
	if error != OK:
		print("Error creating HTTP request")
		return null
	
	var args = await _http_request.request_completed
	var data = _handle_request_completed(args[0], args[1], args[2], args[3])
	if !data:
		return null
	return _parse_player_state(data)
	
