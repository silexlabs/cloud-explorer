package ce.core.view;

import js.html.Element;

using StringTools;

class AuthPopup {

	static inline var SELECTOR_LINK : String = "a";
	static inline var SELECTOR_TEXT : String = "span";

	static inline var PLACE_HOLDER_SRV_NAME : String = "{srvName}";

	public function new(elt : Element) {

		this.elt = elt;

		this.linkElt = elt.querySelector(SELECTOR_LINK);
		linkElt.addEventListener("click", function(?_){ onClicked(); });

		this.textElt = elt.querySelector(SELECTOR_TEXT);
		this.txtTmpl = textElt.textContent; trace("txtTmpl= "+txtTmpl);
	}

	var elt : Element;

	var linkElt : Element;
	var textElt : Element;

	var txtTmpl : String;

	///
	// CALLBACKS
	//

	public dynamic function onClicked() : Void { }


	///
	// API
	//

	public function setServerName(srvName : String) {

		textElt.textContent = txtTmpl.replace(PLACE_HOLDER_SRV_NAME, srvName);
	}
}