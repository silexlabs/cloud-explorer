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

import ce.core.model.api.PickOptions;
import ce.core.model.api.ReadOptions;
import ce.core.model.api.ExportOptions;

import ce.core.Controller;

@:expose("ce.api.CloudExplorer")
class CloudExplorer {

	///
	// API
	//

	/**
	 * Returns a fresh instance of Cloud Explorer
	 */
	static function get(? iframeEltId : Null<String>) : CloudExplorer {

		return new CloudExplorer(iframeEltId);
	}

	/**
	 * @see https://developers.inkfilepicker.com/docs/web/#pick
	 */
	public function pick(? options : Dynamic, onSuccess : CEBlob -> Void, onError : CEError -> Void) {

		if (onError == null) {

			untyped onError = onSuccess;
			untyped onSuccess = options;
			options = null;
		}
		if (onError == null) {

			throw "Missing mandatory parameters for CloudExplorer.pick(onSuccess : CEBlob -> Void, onError : CEError -> Void)";
		}
trace("options: "+options+"  onSuccess: "+onSuccess+"  onError: "+onError);
		ctrl.pick(options, onSuccess, onError);
	}

	/**
	 * @see https://developers.inkfilepicker.com/docs/web/#read
	 */
	//public function read(input : CEBlob, ? options : ReadOptions, onSuccess : String -> Void, onError : CEError -> Void, onProgress : Int -> Void) {
	public function read(arg1 : Dynamic, arg2 : Dynamic, arg3 : Dynamic, ? arg4 : Dynamic, ? arg5 : Dynamic) {

		var input : CEBlob = arg1; // TODO The object to read. Can be an CEBlob, a URL, a DOM File Object, or an <input type="file"/>.

		var options : Null<ReadOptions> = (Reflect.isObject(arg2)) ? arg2 : null;

		var onSuccess : String -> Void = options == null ? arg2 : arg3;
		var onError : CEError -> Void = options == null ? arg3 : arg4;
		var onProgress : Int -> Void = options == null ? arg4 : arg5;

		ctrl.read(input, options, onSuccess, onError, onProgress);
	}

	/**
	 * @see https://developers.inkfilepicker.com/docs/web/#export
	 */
	public function exportFile(arg1 : Dynamic, arg2 : Dynamic, arg3 : Dynamic, ? arg4 : Dynamic) : Void {

		var input : CEBlob = arg1; // An InkBlob or URL pointing to data you'd like to export. If you have a DOM File object or raw data, you can use the filepicker.store call to first generate an InkBlob

		var options : Null<ExportOptions> = (Reflect.isObject(arg2)) ? arg2 : null;

		var onSuccess : CEBlob -> Void = options == null ? arg2 : arg3;
		var onError : CEError -> Void = options == null ? arg3 : arg4;

		ctrl.exportFile(input, options, onSuccess, onError);
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