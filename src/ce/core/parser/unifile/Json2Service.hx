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

		return {
			name: Json2Primitive.node2String(obj, "name", false),
			displayName: Json2Primitive.node2String(obj, "display_name", false),
			imageSmall: Json2Primitive.node2String(obj, "image_small", false),
			description: Json2Primitive.node2String(obj, "description", false),
			visible: Json2Primitive.node2Bool(obj, "visible", false),
			isLoggedIn: Json2Primitive.node2Bool(obj, "isLoggedIn", false),
			isConnected: Json2Primitive.node2Bool(obj, "isConnected", false),
			user: Reflect.hasField(obj, "user") ? parseUser(Reflect.field(obj, "user")) : null
		};
	}

	static public function parseUser(obj : Dynamic) : User {

		return {
			displayName: Json2Primitive.node2String(obj, "display_name", false),
			quotaInfo: parseQuotaInfo(Reflect.field(obj, "quota_info"))
		};
	}

	static public function parseQuotaInfo(obj : Dynamic) : QuotaInfo {

		return {
			available: Json2Primitive.node2Int(obj, "available", false),
			used: Json2Primitive.node2Int(obj, "used", false)
		};
	}
}
