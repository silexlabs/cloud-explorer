package ce.core.parser.unifile;

import ce.core.model.unifile.ConnectResult;

import ce.core.parser.json.Json2Primitive;

import haxe.Json;

class Json2ConnectResult {
	
	static public function parse(dataStr : String) : ConnectResult {

		var obj : Dynamic = Json.parse( dataStr );

		return {
				success: Json2Primitive.node2Bool(obj, "success", false),
				message: Json2Primitive.node2String(obj, "message", false),
				authorizeUrl: Json2Primitive.node2String(obj, "authorize_url", false),
			};
	}
}