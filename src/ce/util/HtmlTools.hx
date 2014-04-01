package ce.util;

import js.html.Element;
import js.html.Event;

#if js
import js.html.Node;
#else
import cocktail.core.dom.Node;
#end

using Lambda;

/**
 * This class provides "jquery-like" HTML Element manipulation helper methods.
 * Designed to be imported with 'using' and to be chainable.
 */
class HtmlTools {

	/**
	 * Returns an HTML element's classes as an array of lower-case strings.
	 * Passing an array of string as the second parameter will replace the element's classes.
	 */
	public static function classes( el:Element , ?cl : Array<String> ) : Array<String> {

		if( cl != null ){
			//trace('setting classes ${cl.join(",")}');
			el.className = cl.join(" ");
		}
		return el.className.split(" ")
			.filter( function(s) return ( s != '' ) )
			.map( function(s) return s.toLowerCase() );
	}

	/**
	 * Toggles a class on an HTML element.
	 * Returns the element 
	 */
	public static function toggleClass( el:Element, cl:String, flag : Bool ) : Element {
		if( flag ){
			addClass( el , cl );
		}else{
			removeClass( el , cl );
		}
		return el;
	}

	/**
	 * Checks if the given class is present for the given HTML element.
	 * The method ignores case.
	 */
	public inline static function hasClass( el:Element, cl:String ) : Bool {
		return classes(el).has( cl.toLowerCase() );
	}

	/**
	 * Adds a class to an HTML element
	 * The 'cl' parameter can contain several space-separated classes
	 * Returns the element
	 */
	public static function addClass( el:Element , cl :String ){

		var cls = classes(el);
		var changed = false;
		for( c in cl.split(" ") ){
			if( !cls.has( c.toLowerCase() ) ){
				cls.push( c.toLowerCase() );
				changed = true;
			}
		}
		if( changed )
			classes(el,cls);
		return el;
	}
 
 	/**
	 * Removes a class from an HTML element
	 * The 'cl' parameter can contain several space-separated classes
	 * Returns the element
	 */
	public static function removeClass( el:Element , cl :String){
		var cls = classes(el);
		var changed = false;
		for( c in cl.split(" ") ){
			if( cls.remove( c.toLowerCase() ) )
				changed = true;
		}
		if( changed )
			classes(el,cls);
		return el;
	}

	/**
	 * Calculates an HTML element's "absolute" offset by recursively adding his ancestors' offsets
	 * Returned x corresponds to offsetLeft, y corresponds to offsetRight
	 */
	public static function offset( el:Element ) : { x : Int, y : Int }{
		var pos = { x : el.offsetLeft , y : el.offsetTop };
		var parent = parentElement(el);
		while( parent != null ){
			pos.x += parent.offsetLeft;
			pos.y += parent.offsetTop;
			parent = parentElement(parent);
		}
		return pos;
	}

	/**
	 * Returns an HTML Element's parent HTML Element,
	 * if the parent is not an Element (ie a Document), null is returned
	 */
	public static function parentElement( el : Element ) : Element {
		var parent = el.parentNode;
		if( parent != null && parent.nodeType == #if js Node.ELEMENT_NODE #else cocktail.core.dom.DOMConstants.ELEMENT_NODE #end ){
			return cast(parent);
		}
		return null;
	}

	/**
	 * Searches for a vendor-prefixed method called 'field' on an HTML Element, 
	 * and calls it with arguments 'args'.
	 * For non-JS platforms (Cocktail), the 'field' method is called directly
	 * TODO: Optimize by making it a macro
	 */
	public static function vendorPrefixCall( el : Node , field : String , ?args : Array<Dynamic> = null ) : Dynamic {

		if( args == null ) args = [];

		#if !js
			return Reflect.callMethod( el , Reflect.field( el, field ) , args );
		#else

		for( prefixed in vendorPrefix(field) ){
			var v = Reflect.field( el , prefixed );
			if( untyped __js__("typeof v") != "undefined" ){
				return Reflect.callMethod( el , v , args );
			}
		}

		return null;

		#end
	}

	/** 
	 * Return an array of all possible vendor-prefixed versions of 'field':
	 * [not prefixed], webkit, moz, ms, o
	 * Not supposed to work for CSS properties, only Javascript events, methods and properties
	 */
	public static function vendorPrefix( field : String , ?capitalize : Bool = true ) : Array<String> {
		var prefixes = ["","webkit","moz","ms","o"];
		var fields = [field];

		// exception for webkitIsFullScreen
		if( field == "fullScreen" ){
			fields.push("isFullScreen");
		}

		var prefixed = [];
		for( p in prefixes ){
			for( f in fields ){
				prefixed.push( p + ( capitalize ? ( f.substr(0,1).toUpperCase() + f.substr(1) ) : f ) );
			}
		}
		return prefixed;
	}

	/**
	 * Searches for a vendor-prefixed property called 'field' on an HTML Element,
	 * and returns its value.
	 * For non-JS platforms (Cocktail), the 'field' method is called directly
	 * TODO: Optimize by making it a macro
	 */
	public static function vendorPrefixProperty( el : Node , field : String ) : Dynamic {
		#if !js
			// if we're in Cocktail = no prefix
			return Reflect.field(el , field);
		#else
			for( prefixed in vendorPrefix( field ) ){
				var v = Reflect.field( el , prefixed );
				if( untyped __js__("typeof v") != "undefined" ){
					return v;
				}
			}
			return null;
		#end
	}

	/**
	 * Adds event listener to an HTML Node
	 * 'event' may be a space separated list of event types
	 */
	public inline static function addEvent( el : Node , event : String , callback : Event -> Void ){
		addEvents( el, event.split(" "), callback );
	}

	/**
	 * Adds several event listeners to an HTML Node
	 */
	public inline static function addEvents( el : Node , events : Array<String> , callback : Event -> Void ){
		for( e in events ){
			el.addEventListener( e , callback );
		}
	}

}