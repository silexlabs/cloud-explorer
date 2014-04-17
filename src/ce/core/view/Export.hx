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

using StringTools;

class Export {

	static inline var SELECTOR_INPUT : String = "input";
	static inline var SELECTOR_PATH : String = "span.path";
	static inline var SELECTOR_EXT : String = "span.ext";
	static inline var SELECTOR_SAVE_BUTTON : String = ".saveBtn";
	static inline var SELECTOR_OVERWRITE_BUTTON : String = ".overwriteBtn";

	public function new(elt : Element) {

		this.elt = elt;

		this.inputElt = cast elt.querySelector(SELECTOR_INPUT);
		inputElt.addEventListener("input", function(?_) { onExportNameChanged(); });

		this.pathElt = elt.querySelector(SELECTOR_PATH);

		this.extElt = elt.querySelector(SELECTOR_EXT);

		this.saveBtnElt = elt.querySelector(SELECTOR_SAVE_BUTTON);
		saveBtnElt.addEventListener("click", function(?_){ onSaveBtnClicked(); });

		this.overwriteBtnElt = elt.querySelector(SELECTOR_OVERWRITE_BUTTON);
		overwriteBtnElt.addEventListener("click", function(?_){ onOverwriteBtnClicked(); });
	}

	var elt : Element;

	var inputElt : InputElement;
	var extElt : Element;
	var pathElt : Element;
	var saveBtnElt : Element;
	var overwriteBtnElt : Element;

	public var exportName (get, set) : Null<String>;

	public var ext (null, set) : Null<String>;

	public var path (null, set) : Null<String>;


	///
	// CALLBACKS
	//

	public dynamic function onNavBtnClicked(srv : String, path : String) : Void { }

	public dynamic function onSaveBtnClicked() : Void { }

	public dynamic function onOverwriteBtnClicked() : Void { }

	public dynamic function onExportNameChanged() : Void { }


	///
	// GETTERS / SETTERS
	//

	public function get_exportName() : Null<String> {
		
		return inputElt.value;
	}

	public function set_exportName(v : Null<String>) : Null<String> {

		inputElt.value = v;

		return v;
	}

	public function set_ext(v : Null<String>) : Null<String> {

		extElt.textContent = v;

		return v;
	}

	public function set_path(v : Null<String>) : Null<String> {

		pathElt.textContent = v;

		return v;
	}
}