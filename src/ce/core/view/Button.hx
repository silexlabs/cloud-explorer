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
package ce.core.view;

import js.html.Element;

using ce.util.HtmlTools;

class Button {

	static inline var ATTR_DISABLED : String = "disabled";
	static inline var ATTR_VALUE_DISABLED : String = "disabled";

	public function new(elt : Element) {

		this.elt = elt;

		this.elt.addEventListener( "click", function(?_){ onClicked(); } );
	}

	var elt : Element;


	///
	// API
	//

	public dynamic function onClicked() : Void { }

	public var enabled (get, set) : Bool;


	///
	// GETTER / SETTER
	//

	private function get_enabled() : Bool {

		return !elt.hasAttribute(ATTR_DISABLED);
	}

	private function set_enabled(v : Bool) : Bool {

		if (v && elt.hasAttribute(ATTR_DISABLED)) {

			elt.removeAttribute(ATTR_DISABLED);
		}
		if (!v && !elt.hasAttribute(ATTR_DISABLED)) {

			elt.setAttribute(ATTR_DISABLED, ATTR_VALUE_DISABLED);
		}
		return v;
	}
}