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

import ce.core.model.unifile.Account;

import ce.core.parser.json.Json2Primitive;

import haxe.Json;

class Json2Account {

	static public function parseAccount(? dataStr : String, ? obj : Dynamic) : Null<Account> {

		if (obj == null) {

			if (dataStr == null) return null;

			obj = Json.parse( dataStr );
		}

		return {
			displayName: Json2Primitive.node2String(obj, "display_name", false),
			quotaInfo: Reflect.hasField(obj, "quota_info") ? parseQuotaInfo(Reflect.field(obj, "quota_info")) : null
		};
	}

	static public function parseQuotaInfo(obj : Dynamic) : QuotaInfo {

		return {
			available: Json2Primitive.node2Int(obj, "available", false),
			used: Json2Primitive.node2Int(obj, "used", false)
		};
	}
}