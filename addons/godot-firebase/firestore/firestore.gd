extends Node

signal listed_documents(documents)

var base_url : String = "https://firestore.googleapis.com/v1/"
var extended_url : String = "projects/[PROJECT_ID]/databases/(default)/documents/"

var config : Dictionary = {}

var collections : Dictionary = {}
var auth : String
var request_list_node : HTTPRequest

func set_config(config_json : Dictionary) -> void:
		config = config_json
		extended_url = extended_url.replace("[PROJECT_ID]", config.projectId)
		request_list_node = HTTPRequest.new()
		request_list_node.connect("request_completed", self, "on_list_request_completed")
		add_child(request_list_node)

func collection(path : String) -> FirestoreCollection:
		if !collections.has(path):
				var coll = preload("res://addons/godot-firebase/firestore/firestore_collection.gd")
				var node = Node.new()
				node.set_script(coll)
				node.extended_url = extended_url
				node.base_url = base_url
				node.config = config
				node.auth = auth
				node.collection_name = path
				collections[path] = node
				add_child(node)
				return node
		else:
				return collections[path]

func list(path : String) -> void:
		if path:
				var url = base_url + extended_url + path + "/"
				request_list_node.request(url, ["Authorization: Bearer " + auth.idtoken], true, HTTPClient.METHOD_GET)

func on_list_request_completed(result : int, response_code : int, headers : PoolStringArray, body : PoolByteArray):
		print(JSON.parse(body.get_string_from_utf8()).result)

func _on_FirebaseAuth_login_succeeded(auth_result : String) -> void:
		auth = auth_result
		for collection_key in collections.keys():
				collections[collection_key].auth = auth
		pass
