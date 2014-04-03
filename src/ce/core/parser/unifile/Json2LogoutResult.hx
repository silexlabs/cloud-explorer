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
package ce.core.parser.unifile;

import ce.core.model.unifile.LogoutResult;

import ce.core.parser.json.Json2Primitive;

import haxe.Json;

class Json2LogoutResult {
	
	static public function parse(dataStr : String) : LogoutResult {

		var obj : Dynamic = Json.parse( dataStr );

		return {
				success: Json2Primitive.node2Bool(obj, "success", false),
				message: Json2Primitive.node2String(obj, "message", false)
			};
	}
}