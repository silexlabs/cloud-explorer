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
import js.html.InputElement;

class DropZone {

	static inline var SELECTOR_INPUT : String = "div input";
	static inline var SELECTOR_BUTTON : String = "div button";

	public function new(elt : Element) {

		this.elt = elt;

		this.inputElt = cast elt.querySelector(SELECTOR_INPUT);
		inputElt.addEventListener("change", function(?_){ onInputFilesChanged(); });

		this.btnElt = elt.querySelector(SELECTOR_BUTTON);
		btnElt.addEventListener("click", function(?_){ onBtnClicked(); });
	}

	var elt : Element;
	var btnElt : Element;

	public var inputElt (default, null) : InputElement;


	///
	// CALLBACKS
	//

	public dynamic function onInputFilesChanged() : Void { }


	///
	// INTERNALS
	//

	private function onBtnClicked() : Void {

		inputElt.click();
	}
}