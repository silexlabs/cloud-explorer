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
import js.html.FileList;

using ce.util.HtmlTools;

class DropZone {

	static inline var SELECTOR_INPUT : String = "div input";
	static inline var SELECTOR_BUTTON : String = "div button";

	static inline var CLASS_DRAGGINGOVER : String = "draggingover";

	public function new(elt : Element) {

		this.elt = elt;

		this.inputElt = cast elt.querySelector(SELECTOR_INPUT);
		inputElt.addEventListener("change", function(?_){ onInputFilesChanged(); });

		this.btnElt = elt.querySelector(SELECTOR_BUTTON);
		btnElt.addEventListener("click", function(?_){ onBtnClicked(); });

		this.elt.addEventListener('dragover', function(e) {

				e.preventDefault();

				e.dataTransfer.dropEffect = 'copy';

				return false;
			});

		this.elt.addEventListener('dragenter', function(e) {

				this.elt.toggleClass(CLASS_DRAGGINGOVER, true);
			});

		this.elt.addEventListener('dragleave', function(e) {

				this.elt.toggleClass(CLASS_DRAGGINGOVER, false);
			});

		this.elt.addEventListener('drop', function(e) {

				e.preventDefault();
				e.stopPropagation();

				this.elt.toggleClass(CLASS_DRAGGINGOVER, false); // useful ?

				var fileList : FileList = e.dataTransfer.files;

				if (fileList.length > 0) {

					onFilesDropped(fileList);
				}
			});
	}

	var elt : Element;
	var btnElt : Element;

	public var inputElt (default, null) : InputElement;


	///
	// CALLBACKS
	//

	public dynamic function onInputFilesChanged() : Void { }

	public dynamic function onFilesDropped(files : FileList) : Void { }


	///
	// INTERNALS
	//

	private function onBtnClicked() : Void {

		inputElt.click();
	}
}