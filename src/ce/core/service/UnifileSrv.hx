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

import ce.core.model.unifile.Service;
import ce.core.model.unifile.ConnectResult;
import ce.core.model.unifile.LoginResult;
import ce.core.model.unifile.Account;
import ce.core.model.unifile.File;
import ce.core.model.unifile.LogoutResult;

import haxe.Http;

import haxe.ds.StringMap;

using StringTools;

class UnifileSrv {

	static inline var ENDPOINT_LIST_SERVICES : String = "services/list";
	static inline var ENDPOINT_CONNECT : String = "{srv}/connect";
	static inline var ENDPOINT_LOGIN : String = "{srv}/login";
	static inline var ENDPOINT_ACCOUNT : String = "{srv}/account";
	static inline var ENDPOINT_LOGOUT : String = "{srv}/logout";
	static inline var ENDPOINT_LS : String = "{srv}/exec/ls/{path}";
	static inline var ENDPOINT_RM : String = "exec/rm";
	static inline var ENDPOINT_MKDIR : String = "exec/mkdir";
	static inline var ENDPOINT_CP : String = "exec/cp";
	static inline var ENDPOINT_MV : String = "exec/mv";
	static public inline var ENDPOINT_GET : String = "{srv}/exec/get/{uri}";

	public function new(config : Config) : Void {

		this.config = config;
	}

	var config : Config;


	///
	// API
	//

	public function listServices(onSuccess : StringMap<Service> -> Void, onError : String -> Void) : Void {

		var http : Http = new Http(config.unifileEndpoint + ENDPOINT_LIST_SERVICES);

		http.onData = function(data : String) {

				var sl : Array<Service> = Json2Service.parseServiceCollection(data);

				var slm : StringMap<Service> = new StringMap();

				for (s in sl) {

					slm.set(s.name, s);
				}

				onSuccess(slm);
			}

		http.onError = onError;

		http.request(false);
	}

	public function connect(srv : String, onSuccess : ConnectResult -> Void, onError : String -> Void) : Void {

		var http : Http = new Http(config.unifileEndpoint + ENDPOINT_CONNECT.replace("{srv}", srv));

		http.onData = function(data : String) {

				onSuccess(Json2ConnectResult.parse(data));
			}

		http.onError = onError;

		http.request(false);
	}

	public function login(srv : String, onSuccess : LoginResult -> Void, onError : String -> Void) : Void {

		var http : Http = new Http(config.unifileEndpoint + ENDPOINT_LOGIN.replace("{srv}", srv));

		http.onData = function(data : String) {

				onSuccess(Json2LoginResult.parse(data));
			}

		http.onError = onError;

		http.request(false);
	}

	public function account(srv : String, onSuccess : Account -> Void, onError : String -> Void) : Void {

		var http : Http = new Http(config.unifileEndpoint + ENDPOINT_ACCOUNT.replace("{srv}", srv));

		http.onData = function(data : String) {

				onSuccess(Json2Account.parseAccount(data));
			}

		http.onError = onError;

		http.request(true);
	}

	public function logout(srv : String, onSuccess : LogoutResult -> Void, onError : String -> Void) : Void {

		var http : Http = new Http(config.unifileEndpoint + ENDPOINT_LOGOUT.replace("{srv}", srv));

		http.onData = function(data : String) {

				onSuccess(Json2LogoutResult.parse(data));
			}

		http.onError = onError;

		http.request(false);
	}

	public function ls(srv : String, path : String, onSuccess : StringMap<File> -> Void, onError : String -> Void) : Void {

		var http : Http = new Http(config.unifileEndpoint + ENDPOINT_LS.replace("{srv}", srv).replace("{path}", path));

		http.onData = function(data : String) {

				var fa : Array<File> = Json2File.parseFileCollection(data);

				var fsm : StringMap<File> = new StringMap();

				for (f in fa) {

					fsm.set(f.name, f);
				}

				onSuccess(fsm);
			}

		http.onError = onError;

		http.request(false);
	}

	public function rm() : Void {

		
	}

	public function mkdir() : Void {

		
	}

	public function cp() : Void {

		
	}

	public function mv() : Void {

		
	}

	public function get() : Void {


	}
}