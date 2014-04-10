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

using StringTools;

class Breadcrumb {

	static inline var SELECTOR_PATH : String = "span.path";
	static inline var SELECTOR_PATH_ITEM_TMPL : String = "span.pathIt";
	static inline var SELECTOR_PATH_SEP_TMPL : String = "span.sep";

	public function new(elt : Element) {

		this.elt = elt;

		this.pathElt = elt.querySelector(SELECTOR_PATH);
		this.pathItemTmpl = pathElt.querySelector(SELECTOR_PATH_ITEM_TMPL);
		pathElt.removeChild(pathItemTmpl);
		this.pathSepTmpl = pathElt.querySelector(SELECTOR_PATH_SEP_TMPL);
		pathElt.removeChild(pathSepTmpl);
	}

	var elt : Element;

	var pathElt : Element;
	var pathItemTmpl : Element;
	var pathSepTmpl : Element;


	///
	// CALLBACKS
	//

	public dynamic function onNavBtnClicked(srv : String, path : String) : Void { }


	///
	// API
	//

	public function setBreadcrumbPath(srv : String, path : String) : Void {

		while (pathElt.childNodes.length > 0) {

			pathElt.removeChild(pathElt.firstChild);
		}
		var srvIt : Element = cast pathItemTmpl.cloneNode(true);
		srvIt.addEventListener("click", function(?_){ onNavBtnClicked(srv, "/"); });
		srvIt.textContent = srv;

		pathElt.appendChild(srvIt);

		var pathItems : Array<Element> = [];

		if (path.length > 0) {

			var parr : Array<String> = path.split("/");

			while (parr.length > 0) {

				var itPath : String = "/" + parr.join("/");
				var pit : String = parr.pop();

				if (pit.trim() != "") {

					var nit : Element = cast pathItemTmpl.cloneNode(true);
					nit.addEventListener("click", function(?_){ onNavBtnClicked(srv, itPath); });
					nit.textContent = pit;

					pathItems.push(nit);
				}
			}
		}
		while (pathItems.length > 0) {

			pathElt.appendChild(pathSepTmpl.cloneNode(true));
			pathElt.appendChild(pathItems.pop());
		}
	}
}