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
package ce.core;

import ce.core.config.Config;

import ce.core.view.Application;

import ce.core.model.CEBlob;
import ce.core.model.CEError;
import ce.core.model.State;

import ce.core.service.UnifileSrv;

import haxe.ds.StringMap;

class Controller {

	public function new(config : Config, iframe : js.html.IFrameElement) {

		this.config = config;

		this.state = new State();

		this.unifileSrv = new UnifileSrv(config);

		this.application = new Application(iframe);

		initMvc();
	}

	var config : Config;
	var state : State;

	var application : Application;
	
	var unifileSrv : UnifileSrv;


	///
	// API
	//

	public function pick(? options : Dynamic, onSuccess : CEBlob -> Void, onError : CEError -> Void) {

		show();

		//application.setHomeDisplayed(true);
	}

	public function setError(msg : String) : Void {

		trace("ERROR "+msg);
	}

	///
	// INTERNALS
	//

	private function show() : Void {

		if (state.serviceList == null) {

			application.setLoaderDisplayed(true);

			unifileSrv.listServices(function(sl : Array<ce.core.model.unifile.Service>) {

					var slm : StringMap<ce.core.model.unifile.Service> = new StringMap();

					for (s in sl) {

						slm.set(s.name, s);

						application.home.addService(s.name, s.displayName, s.description);
					}
					state.serviceList = slm;

					application.setLoaderDisplayed(false);

					application.setHomeDisplayed(true);

				}, setError);

		} else {

			application.setHomeDisplayed(true);
		}

		state.displayState = true;
	}

	private function initMvc() : Void {

		application.onViewReady = function() {

				state.readyState = true;
			}

		application.onLogoutClicked = function() {

				// TODO
				
			}

		application.onCloseClicked = function() {

				state.displayState = false;
			}

		application.onServiceClicked = function(name : String) {

				// TODO
				trace("connecting " + name + " chosen");

				unifileSrv.connect(name, function(cr : ce.core.model.unifile.ConnectResult) {

						if (cr.success) {

							state.serviceList.get(name).isConnected = true;

							application.authPopup.setServerName(state.serviceList.get(name).displayName);

							application.authPopup.onClicked = function(){

									// TODO open popup
									trace("open popup on "+cr.authorizeUrl);
								}

							application.setAuthPopupDisplayed(true);

						} else {

							state.serviceList.get(name).isConnected = false;

							setError(cr.message);
						}

					}, setError);
			}

		state.onDisplayStateChanged = function() {

				application.setDisplayed(state.displayState);
			}

		state.onReadyStateChanged = function() {


			}
	}
}