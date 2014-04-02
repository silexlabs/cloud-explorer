package ce.core.parser.json;

/**
 * Common methods to parse JSON feeds
 */
class Json2Primitive {
	
	static public function checkPath( node : Dynamic, path : String, optional : Bool = false ) : Null<Dynamic> {
//trace("checking "+path+" on "+node);
		var pathes : Array<String> = path.split('.');

		//return doCheckPath( node, pathes, optional );
		var n : Null<Dynamic> = doCheckPath( node, pathes, optional );

		if ( n == null && !optional ) {

			trace(path + " not found !");
		}
//trace("checking "+path+" returned "+n);
		return n;
	}

	static public function doCheckPath( node : Dynamic, pathes : Array<String>, optional : Bool = false ) : Null<Dynamic> {

		var p = pathes.shift();

		if ( !Reflect.hasField( node, p ) || Reflect.field(node, p) == null ) {

			if (!optional) {

				trace(p+' not found !');
				// TODO throw ?
			}
			return null;
		}
		if ( pathes.length > 0 ) {

			return doCheckPath( Reflect.field(node, p), pathes, optional );
		}
		
		return Reflect.field( node, p );
	}

	static public function node2String( node : Dynamic, path : String, nullable : Bool = false ) : Null<String> {

		var n : Null<Dynamic> = checkPath( node, path, nullable );

		if( n == null ) {

			if (!nullable) {

				// TODO throw ?
			}
			return null;
		}
		return Std.string( n );
	}

	static public function node2Float( node : Dynamic, path : String, nullable : Bool = false ) : Null<Float> {

		return Std.parseFloat( node2String( node, path, nullable ) );
	}

	static public function node2Int( node : Dynamic, path : String, nullable : Bool = false ) : Null<Int> {

		return Std.parseInt( node2String( node, path, nullable ) );
	}

	static public function node2Bool( node : Dynamic, path : String, nullable : Bool = false ) : Bool {

		var v : Null<String> = node2String( node, path, nullable );

		return ( v != null ? (v == "true" || v == "1") : false );
	}
}