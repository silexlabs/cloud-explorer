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

class Home {

	static inline var SELECTOR_SRV_LIST : String = "ul";
	static inline var SELECTOR_SRV_ITEM_TMPL : String = "li";

	public function new(elt : Element) {

		this.elt = elt;

		this.listElt = elt.querySelector(SELECTOR_SRV_LIST);

		this.srvItemTmpl = elt.querySelector(SELECTOR_SRV_ITEM_TMPL);
		listElt.removeChild(srvItemTmpl);
	}

	var elt : Element;

	var listElt : Element;

	var srvItemTmpl : Element;


	///
	// CALLBACK
	//

	public dynamic function onServiceClicked(name : String) : Void { }


	///
	// API
	//

	public function addService(name : String, displayName : String, description : String) : Void {

		var newSrvIt : Element = cast srvItemTmpl.cloneNode(true);

		newSrvIt.textContent = displayName;
		newSrvIt.className = name;

		// TODO description as tooltip ?

		newSrvIt.addEventListener( "click", function(?_){ onServiceClicked(name); } );

		listElt.appendChild(newSrvIt);
	}
}