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
using ce.util.HtmlTools;

class AlertPopup {

	static inline var CLASS_ERROR : String = "error";
	static inline var CLASS_WARNING : String = "warning";

	static inline var SELECTOR_TEXT : String = ".txt";
	static inline var SELECTOR_CHOICE_TMPL : String = ".choice";

	public function new(elt : Element) {

		this.elt = elt;

		this.txtElt = elt.querySelector(SELECTOR_TEXT);

		this.choiceTmpl = txtElt.querySelector(SELECTOR_CHOICE_TMPL);
		txtElt.removeChild(choiceTmpl);

		this.choicesElts = [];
	}

	var elt : Element;
	var txtElt : Element;

	var choiceTmpl : Element;

	var choicesElts : Array<Element>;


	///
	// API
	//

	public function setMsg(msg : String, ? level : Int = 2, ? choices : Array<{ msg : String, cb : Void -> Void }>) : Void {

		while (choicesElts.length > 0) {

			txtElt.removeChild(choicesElts.pop());
		}
		txtElt.textContent = msg;

		if (choices != null) {

			for (c in choices) {

				var nc : Element = cast choiceTmpl.cloneNode(true);
				var tc : { msg : String, cb : Void -> Void } = c;
				nc.textContent = tc.msg;
				nc.addEventListener("click", function(?_){ tc.cb(); });
				txtElt.appendChild(nc);
			}
		}
		switch (level) {

			case 0:
				elt.toggleClass(CLASS_ERROR, true);
				elt.toggleClass(CLASS_WARNING, false);

			case 1:
				elt.toggleClass(CLASS_ERROR, false);
				elt.toggleClass(CLASS_WARNING, true);

			default:
				elt.toggleClass(CLASS_ERROR, false);
				elt.toggleClass(CLASS_WARNING, false);
		}

		haxe.Timer.delay(function(){ txtElt.style.marginTop = "-" + Std.string(txtElt.offsetHeight / 2 + 20) + "px"; }, 0);
	}
}