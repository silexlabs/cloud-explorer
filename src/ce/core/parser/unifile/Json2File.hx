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

import ce.core.model.unifile.File;

import ce.core.parser.json.Json2Primitive;

import haxe.Json;

class Json2File {

	static public function parseFileCollection(dataStr : String) : Array<File> {

		var col : Array<Dynamic> = Json.parse( dataStr );

		var fileCol : Array<File> = new Array();

		for (f in col) {

			fileCol.push(parseFile(f));
		}

		return fileCol;
	}

	static public function parseFile(obj : Dynamic) : File {

		return {
				name: Json2Primitive.node2String(obj, "name", false),
				bytes: Json2Primitive.node2Int(obj, "bytes", false),
				modified: Json2Primitive.node2String(obj, "modified", false), // FIXME would be better to get a timestamp from unifie
				isDir: Json2Primitive.node2Bool(obj, "is_dir", false)
			};
	}
}
