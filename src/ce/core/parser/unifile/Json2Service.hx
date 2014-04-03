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

import ce.core.model.unifile.Service;

import ce.core.parser.json.Json2Primitive;

import haxe.Json;

class Json2Service {

	static public function parseServiceCollection(dataStr : String) : Array<Service> {

		var col : Array<Dynamic> = Json.parse( dataStr );

		var serviceCol : Array<Service> = new Array();

		for (s in col) {

			serviceCol.push(parseService(s));
		}

		return serviceCol;
	}

	static public function parseService(obj : Dynamic) : Service {

		return new Service(
				Json2Primitive.node2String(obj, "name", false),
				Json2Primitive.node2String(obj, "display_name", false),
				Json2Primitive.node2String(obj, "image_small", false),
				Json2Primitive.node2String(obj, "description", false),
				Json2Primitive.node2Bool(obj, "visible", false),
				Json2Primitive.node2Bool(obj, "isLoggedIn", false),
				Json2Primitive.node2Bool(obj, "isConnected", false),
				Reflect.hasField(obj, "user") ? Json2Account.parseAccount(null, Reflect.field(obj, "user")) : null
			);
	}
}
