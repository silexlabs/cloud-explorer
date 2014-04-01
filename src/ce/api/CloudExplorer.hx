package ce.api;

import js.html.IFrameElement;

import ce.core.config.Config;
import ce.core.model.CEBlob;
import ce.core.model.CEError;

import ce.core.Controller;

@:expose("ce.api.CloudExplorer")
class CloudExplorer {

	///
	// API
	//

	/**
	 * 
	 */
	static function get(? iframeEltId : Null<String>) : CloudExplorer {

		return new CloudExplorer(iframeEltId);
	}

	/**
	 * @see https://developers.inkfilepicker.com/docs/web/#pick
	 */
	public function pick(? options : Dynamic, onSuccess : CEBlob -> Void, onError : CEError -> Void) {

		ctrl.pick(options, onSuccess, onError);
	}


	///
	// INTERNALS
	//

	var ctrl : ce.core.Controller;

	private function new(? iframeEltId : Null<String>) {

		var ceIf : IFrameElement = iframeEltId != null ? cast js.Browser.document.getElementById(iframeEltId) : null;

		if (ceIf == null) {

			// TODO
		}

		ceIf.style.display = "none";
		ceIf.src = "cloud-explorer.html";

		var config : Config = new Config(); // TODO

		ctrl = new Controller(config, ceIf);
	}
}