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

import ce.core.model.unifile.Service;

import haxe.Http;

class UnifileSrv {

	static inline var ENDPOINT_LIST_SERVICES : String = "services/list";
	static inline var ENDPOINT_CONNECT : String = "connect";
	static inline var ENDPOINT_LOGIN : String = "login";
	static inline var ENDPOINT_LOGOUT : String = "logout";
	static inline var ENDPOINT_LS : String = "exec/ls";
	static inline var ENDPOINT_RM : String = "exec/rm";
	static inline var ENDPOINT_MKDIR : String = "exec/mkdir";
	static inline var ENDPOINT_CP : String = "exec/cp";
	static inline var ENDPOINT_MV : String = "exec/mv";
	static inline var ENDPOINT_GET : String = "exec/get";

	public function new(config : Config) : Void {

		this.config = config;
	}

	var config : Config;
/*
return $resource( serverUrl + ':service/:method/:command/:path ', {},
			{  // *very ugly* FIXME added space to keep the '/' at the end of the url
				listServices: {method:'GET', params:{service:'services', method:'list'}, isArray:true},
				connect: {method:'GET', params:{method:'connect'}, isArray:false},
				login: {method:'GET', params:{method:'login'}, isArray:false},
				logout: {method:'GET', params:{method:'logout'}, isArray:false},
				ls: {method:'GET', params:{method:'exec', command:'ls'}, isArray:true},
				rm: {method:'GET', params:{method:'exec', command:'rm'}, isArray:false},
				mkdir: {method:'GET', params:{method:'exec', command:'mkdir'}, isArray:false},
				cp: {method:'GET', params:{method:'exec', command:'cp'}, isArray:false},
				mv: {method:'GET', params:{method:'exec', command:'mv'}, isArray:false},
				get: {method:'GET', params:{method:'exec', command:'get'}, isArray:false} // FIXME buggy
			});
*/

	///
	// API
	//

	public function listServices(onSuccess : Array<Service> -> Void, onError : String -> Void) : Void {

		var http : Http = new Http(config.unifileEndpoint + ENDPOINT_LIST_SERVICES);

		http.onData = function(data : String) {

				onSuccess(Json2Service.parseServiceCollection(data));
			}

		http.onError = onError;

		http.request(false);
	}

	public function connect() : Void {


	}

	public function login() : Void {


	}

	public function logout() : Void {


	}

	public function ls() : Void {

		
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