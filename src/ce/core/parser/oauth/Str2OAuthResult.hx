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
package ce.core.parser.oauth;

import ce.core.model.oauth.OAuthResult;

import ce.core.parser.json.Json2Primitive;

import haxe.Json;

class Str2OAuthResult {

	static inline var PARAM_NOT_APPROVED : String = "not_approved";
	static inline var PARAM_OAUTH_TOKEN : String = "oauth_token";
	static inline var PARAM_UID : String = "uid";
	
	static public function parse(dataStr : String) : OAuthResult {

		if (dataStr.indexOf('?') == 0) {
			dataStr = dataStr.substr(1);
		}
		var dataArr : Array<String> = dataStr.split("&");

		var res : OAuthResult = {};

		for (pStr in dataArr) {

			var kv : Array<String> = pStr.split("=");

			res = parseValue(res, kv[0], kv[1]);
		}
		return res;
	}
	
	static private function parseValue(obj : OAuthResult, key : String, value : String) : OAuthResult {

		switch (key) {

			case PARAM_NOT_APPROVED:

				obj.notApproved = value.toLowerCase() == "true" || value == "1" ? true : false;

			case PARAM_OAUTH_TOKEN:

				obj.oauthToken = value;

			case PARAM_UID:

				obj.uid = value;

			default:

				throw "unexpected parameter " + key;
		}
		return obj;
	}
}