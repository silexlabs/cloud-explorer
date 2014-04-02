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

		var ceIframe : IFrameElement = iframeEltId != null ? cast js.Browser.document.getElementById(iframeEltId) : null;

		if (ceIframe == null) {

			ceIframe = js.Browser.document.createIFrameElement();

			js.Browser.document.appendChild(ceIframe);
		}

		var config : Config = new Config(); // TODO

		ctrl = new Controller(config, ceIframe);
	}
}