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
import ce.core.model.Location;

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

				application.setLoaderDisplayed(true);

				unifileSrv.connect(name, function(cr : ce.core.model.unifile.ConnectResult) {

						if (cr.success) {

							state.serviceList.get(name).isConnected = true;

							application.authPopup.setServerName(state.serviceList.get(name).displayName);

							application.authPopup.onClicked = function(){

									application.onAuthorizationWindowBlocked = function(){

											setError("Can't open "+state.serviceList.get(name).displayName+" authorization window!");
										}

									application.onServiceAuthorizationDone = function() {

											login(name);
										}

									application.openAuthorizationWindow(cr.authorizeUrl);
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

		state.onServiceLoginStateChanged = function(srvName) {

				if (!state.serviceList.get(srvName).isLoggedIn) {

					application.fileBrowser.removeService(srvName);

					if (state.currentLocation.service == "srvName") {

						state.currentLocation = null;
					}

				} else {

					if (state.serviceList.get(srvName).account == null) {

						unifileSrv.account(srvName, function(a : ce.core.model.unifile.Account){

								state.serviceList.get(srvName).account = a;

							}, setError);
					}
					if (state.currentLocation == null) {

						state.currentLocation = new Location(srvName, "/");
					}
					application.fileBrowser.addService(srvName, state.serviceList.get(srvName).displayName);
				}
			}

		state.onServiceAccountChanged = function(srvName) {

				// TODO
			}

		state.onCurrentLocationChanged = function() {

				if (state.currentLocation == null) {

					state.currentFileList = null;

				} else {

					cd(state.currentLocation.service , state.currentLocation.path );
				}
			}

		state.onCurrentFileListChanged = function() {

				application.fileBrowser.resetFileList();

				if (state.currentFileList == null) {

					//application.fileBrowser.setEmptyMsgDisplay(true);

				} else {

					//application.fileBrowser.setEmptyMsgDisplay(false);

					for (f in state.currentFileList) {

						if (f.isDir) {

							application.fileBrowser.addFolder(f.name);

						} else {

							application.fileBrowser.addFile(f.name);
						}
					}
				}
			}
	}

	function cd(srvName : String, path : String) : Void {

		application.setLoaderDisplayed(true);

		unifileSrv.ls(srvName, path, function(files : Array<ce.core.model.unifile.File>){

				application.setFileBrowserDisplayed(true);

				application.setLoaderDisplayed(false);

				state.currentFileList = files;

			}, setError);
	}

	function login(srvName : String) : Void {

		if (!state.serviceList.get(srvName).isLoggedIn) {

			unifileSrv.login(srvName, function(lr : ce.core.model.unifile.LoginResult){

					application.setLoaderDisplayed(false);

					if (lr.success) {

						state.serviceList.get(srvName).isLoggedIn = true;
					
					} else {

						state.serviceList.get(srvName).isLoggedIn = false;
						setError('Could not login. Please try again.');
					}

				}, setError);
		}
	}
}