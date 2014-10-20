/**
 * Cloud Explorer, lightweight frontend component for file browsing with cloud storage services.
 * @see https://github.com/silexlabs/cloud-explorer
 *
 * Cloud Explorer works as a frontend interface for the unifile node.js module:
 * @see https://github.com/silexlabs/unifile
 *
 * @author Thomas Fétiveau, http://www.tokom.fr  &  Alexandre Hoyau, http://lexoyo.me
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package ce.core.service;

import ce.core.config.Config;

import ce.core.parser.unifile.Json2Service;
import ce.core.parser.unifile.Json2ConnectResult;
import ce.core.parser.unifile.Json2LoginResult;
import ce.core.parser.unifile.Json2Account;
import ce.core.parser.unifile.Json2File;
import ce.core.parser.unifile.Json2LogoutResult;
import ce.core.parser.unifile.Json2UploadResult;
import ce.core.parser.unifile.Json2UnifileError;

import ce.core.model.unifile.Service;
import ce.core.model.unifile.ConnectResult;
import ce.core.model.unifile.LoginResult;
import ce.core.model.unifile.Account;
import ce.core.model.unifile.File;
import ce.core.model.unifile.LogoutResult;
import ce.core.model.unifile.UploadResult;
import ce.core.model.unifile.UnifileError;

import js.html.Blob;
import js.html.DOMFormData;
import js.html.XMLHttpRequest;

import haxe.ds.StringMap;

using StringTools;

class UnifileSrv {

	static inline var ENDPOINT_LIST_SERVICES : String = "services/list";
	static inline var ENDPOINT_CONNECT : String = "{srv}/connect";
	static inline var ENDPOINT_LOGIN : String = "{srv}/login";
	static inline var ENDPOINT_ACCOUNT : String = "{srv}/account";
	static inline var ENDPOINT_LOGOUT : String = "{srv}/logout";
	static inline var ENDPOINT_LS : String = "{srv}/exec/ls/{path}";
	static inline var ENDPOINT_RM : String = "{srv}/exec/rm/{path}";
	static inline var ENDPOINT_MKDIR : String = "{srv}/exec/mkdir/{path}";
	static inline var ENDPOINT_CP : String = "exec/cp";
	static inline var ENDPOINT_MV : String = "{srv}/exec/mv/{path}";
	static inline var ENDPOINT_GET : String = "{srv}/exec/get/{uri}";
	static inline var ENDPOINT_PUT : String = "{srv}/exec/put/{path}";

	public function new(config : Config) : Void {

		this.config = config;
	}

	var config : Config;


	///
	// API
	//

	public function generateUrl(srv : String, path : String, filename : String) : String {

		return config.unifileEndpoint + ENDPOINT_GET.replace("{srv}", srv)
													.replace("{uri}", path.length > 1 ? path.substr(1) + filename : filename);
	}

	public function explodeUrl(url : String) : { srv : String, path : String, filename : String } {

		if (url.indexOf(config.unifileEndpoint) != 0) {

			throw "ERROR: can't convert url to path: " + url;
		}
		var parsedUrl : String = url.substr(config.unifileEndpoint.length);

		if (parsedUrl.indexOf("/exec/get/") != parsedUrl.indexOf("/")) {

			throw "ERROR: can't convert url to path: " + url;
		}
		var srv : String = parsedUrl.substr(0, parsedUrl.indexOf("/"));

		parsedUrl = parsedUrl.substr(parsedUrl.indexOf("/exec/get/") + "/exec/get/".length);

		var filename : String = "";
		var path : String = "";

		if (parsedUrl.lastIndexOf('/') > -1) {

			filename = parsedUrl.substr(parsedUrl.lastIndexOf('/')+1);
			path = parsedUrl.substr(0, parsedUrl.lastIndexOf('/')+1);
		
		} else {

			filename = parsedUrl;
		}

		return { 'srv': srv, 'path': path, 'filename': filename };
	}

	public function listServices(onSuccess : StringMap<Service> -> Void, onError : UnifileError -> Void) : Void {

		var req : XMLHttpRequest = new XMLHttpRequest();

		req.onload = function(?_) {

				if (req.status != 200) {

					var err : UnifileError = Json2UnifileError.parseUnifileError(req.responseText);

					onError(err);

				} else {

					var sl : Array<Service> = Json2Service.parseServiceCollection(req.responseText);

					var slm : StringMap<Service> = new StringMap();

					for (s in sl) {

						slm.set(s.name, s);
					}

					onSuccess(slm);
				}
			}

		req.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		req.open("GET", config.unifileEndpoint + ENDPOINT_LIST_SERVICES);
		
		req.send();
	}

	public function connect(srv : String, onSuccess : ConnectResult -> Void, onError : UnifileError -> Void) : Void {

		var req : XMLHttpRequest = new XMLHttpRequest();

		req.onload = function(?_) {

				if (req.status != 200) {

					var err : UnifileError = Json2UnifileError.parseUnifileError(req.responseText);

					onError(err);

				} else {

					onSuccess(Json2ConnectResult.parse(req.responseText));
				}
			}

		req.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		req.open("GET", config.unifileEndpoint + ENDPOINT_CONNECT.replace("{srv}", srv));
		
		req.send();
	}

	public function login(srv : String, onSuccess : LoginResult -> Void, onError : UnifileError -> Void) : Void {

		var req : XMLHttpRequest = new XMLHttpRequest();

		req.onload = function(?_) {

				if (req.status != 200) {

					var err : UnifileError = Json2UnifileError.parseUnifileError(req.responseText);

					onError(err);

				} else {

					onSuccess(Json2LoginResult.parse(req.responseText));
				}
			}

		req.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		req.open("GET", config.unifileEndpoint + ENDPOINT_LOGIN.replace("{srv}", srv));
		
		req.send();
	}

	public function account(srv : String, onSuccess : Account -> Void, onError : UnifileError -> Void) : Void {

		var req : XMLHttpRequest = new XMLHttpRequest();

		req.onload = function(?_) {

				if (req.status != 200) {

					var err : UnifileError = Json2UnifileError.parseUnifileError(req.responseText);

					onError(err);

				} else {

					onSuccess(Json2Account.parseAccount(req.responseText));
				}
			}

		req.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		req.open("POST", config.unifileEndpoint + ENDPOINT_ACCOUNT.replace("{srv}", srv));
		
		req.send();
	}

	public function logout(srv : String, onSuccess : LogoutResult -> Void, onError : UnifileError -> Void) : Void {

		var req : XMLHttpRequest = new XMLHttpRequest();

		req.onload = function(?_) {

				if (req.status != 200) {

					var err : UnifileError = Json2UnifileError.parseUnifileError(req.responseText);

					onError(err);

				} else {

					onSuccess(Json2LogoutResult.parse(req.responseText));
				}
			}

		req.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		req.open("GET", config.unifileEndpoint + ENDPOINT_LOGOUT.replace("{srv}", srv));
		
		req.send();
	}

	public function ls(srv : String, path : String, onSuccess : StringMap<File> -> Void, onError : UnifileError -> Void) : Void {

		// on FF, ls// throws an error
		path = path == '/' ? '' : path;

		var req : XMLHttpRequest = new XMLHttpRequest();

		req.onload = function(?_) {

				if (req.status != 200) {

					var err : UnifileError = Json2UnifileError.parseUnifileError(req.responseText);

					onError(err);

				} else {

					var fa : Array<File> = Json2File.parseFileCollection(req.responseText);

					var fsm : StringMap<File> = new StringMap();

					for (f in fa) {

						fsm.set(f.name, f);
					}

					onSuccess(fsm);
				}
			}

		req.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		req.open("GET", config.unifileEndpoint + ENDPOINT_LS.replace("{srv}", srv).replace("{path}", path), true);
		
		req.send();
	}

	public function rm(srv : String, path : String, onSuccess : Void -> Void, onError : UnifileError -> Void) : Void {

		var req : XMLHttpRequest = new XMLHttpRequest();

		req.onload = function(?_) {

				if (req.status != 200) {

					var err : UnifileError = Json2UnifileError.parseUnifileError(req.responseText);

					onError(err);

				} else {

					onSuccess();
				}
			}

		req.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		req.open("GET", config.unifileEndpoint + ENDPOINT_RM.replace("{srv}", srv).replace("{path}", path), true);
		
		req.send();
	}

	public function mkdir(srv : String, path : String, onSuccess : Void -> Void, onError : UnifileError -> Void) : Void {

		var req : XMLHttpRequest = new XMLHttpRequest();

		req.onload = function(?_) {

				if (req.status != 200) {

					var err : UnifileError = Json2UnifileError.parseUnifileError(req.responseText);

					onError(err);

				} else {

					onSuccess();
				}
			}

		req.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		req.open("GET", config.unifileEndpoint + ENDPOINT_MKDIR.replace("{srv}", srv).replace("{path}", path));
		
		req.send();
	}

	public function cp() : Void {

		
	}

	public function mv(srv : String, oldPath : String, newPath : String, onSuccess : Void -> Void, onError : UnifileError -> Void) : Void {

		var req : XMLHttpRequest = new XMLHttpRequest();

		req.onload = function(?_) {

				if (req.status != 200) {

					var err : UnifileError = Json2UnifileError.parseUnifileError(req.responseText);

					onError(err);

				} else {

					onSuccess();
				}
			}

		req.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		req.open("GET", config.unifileEndpoint + ENDPOINT_MV.replace("{srv}", srv).replace("{path}", oldPath + ":" + newPath));
		
		req.send();
	}

	public function upload(? blobs : StringMap<Blob>, ? files : js.html.FileList, srv : String, path : String, onSuccess : Void -> Void, onError : UnifileError -> Void) : Void {

		// enforce path as a folder path
		if (path != "" && path.lastIndexOf('/') != path.length - 1) { // TODO check in unifile if it's not a bug

			path += '/';
		}
		var formData : DOMFormData = new DOMFormData();

		if (files != null) {

			for (f in files) {

				if (Reflect.isObject(f)) { // raw data from drop event or input[type=file] contains methods we need to filter
trace("appended "+f.name);
					untyped __js__("formData.append('data', f, f.name);"); // @see https://github.com/HaxeFoundation/haxe/issues/2867
				}
			}
		}
		if (blobs != null) {

			if (Lambda.count(blobs) == 1) { // FIXME this is a temporary workaround for following issue on FF: https://bugzilla.mozilla.org/show_bug.cgi?id=690659

				path += blobs.keys().next();
			}
			for (fn in blobs.keys()) {

				untyped __js__("formData.append('data', blobs.get(fn), fn);"); // @see https://github.com/HaxeFoundation/haxe/issues/2867
			}
		}

		var xhttp : XMLHttpRequest = new XMLHttpRequest();

		xhttp.open("POST", config.unifileEndpoint + ENDPOINT_PUT.replace("{srv}", srv).replace("{path}", path));

		xhttp.onload = function(?_) {

				// FIXME check UploadResult (fix on unifile side difference between one file and several files upload results)
				//var resp : UploadResult = Json2UploadResult.parse(xhttp.responseText); 

				if (xhttp.status == 200) {
				
					onSuccess();
				
				} else {
				
					var err : UnifileError = Json2UnifileError.parseUnifileError(xhttp.responseText);

					onError(err);
				}
			};

		xhttp.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		xhttp.send(formData);
	}

	/**
	 * Requests a file from a Unifile endpoint.
	 */
	public function get(url : String, onSuccess : String -> Void, onError : UnifileError -> Void) : Void {

		var req : XMLHttpRequest = new XMLHttpRequest();

		req.onload = function(?_) {

				if (req.status != 200) {

					var err : UnifileError = Json2UnifileError.parseUnifileError(req.responseText);

					onError(err);

				} else {

					onSuccess(req.responseText);
				}
			}

		req.onerror = function(?_) {

				onError({ success: false, code: 0, message: "The request has failed." });
			}

		req.open("GET", url);
		
		req.send();
	}
}