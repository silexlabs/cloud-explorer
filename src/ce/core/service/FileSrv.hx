package ce.core.service;

import haxe.Http;

class FileSrv {

	public function new() { }

	public function get(url : String, onSuccess : String -> Void, onError : String -> Void) : Void {

		var http : Http = new Http(url);

		http.onData = onSuccess;

		http.onError = onError;

		http.onStatus = function(s){ trace("status "+s); }

		http.request(false);
	}
}