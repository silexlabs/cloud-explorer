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

			unifileSrv.listServices(function(slm : StringMap<ce.core.model.unifile.Service>) {

					application.setLoaderDisplayed(false);

					state.serviceList = slm;

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

				// FIXME support logging out by service

				var srvName : Null<String> = null;

				for (s in state.serviceList) {

					if (s.isLoggedIn) {

						srvName = s.name;
						break;
					}
				}
				if (srvName != null) {

					unifileSrv.logout(srvName, function(lr : ce.core.model.unifile.LogoutResult){

							state.serviceList.get(srvName).isLoggedIn = false;

							if (!lr.success) {

								setError(lr.message);
							}

						}, setError);
				}	
			}

		application.onCloseClicked = function() {

				state.displayState = false;
			}

		application.onServiceClicked = function(name : String) {

				if (state.serviceList.get(name).isLoggedIn) {

					state.currentLocation = new Location(name, "/");
				
				} else {

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
			}

		application.onFileClicked = function(id : String) {

				if (id == "..") {

					cpd(state.currentLocation.service, state.currentLocation.path);

				} else if (state.currentFileList.get(id).isDir) {

					state.currentLocation.path += state.currentFileList.get(id).name + "/";
				}
			}

		state.onServiceListChanged = function() {

				var lastConnectedService : Null<String> = null;

				for (s in state.serviceList) {

					application.home.addService(s.name, s.displayName, s.description);

					if (s.isLoggedIn) {

						lastConnectedService = s.name;

						application.fileBrowser.addService(s.name, s.displayName);
					}
				}
				if (lastConnectedService != null) {

					if (state.currentLocation == null) {

						state.currentLocation = new Location(lastConnectedService, "/");
					}

					application.setLogoutButtonDisplayed(true);

					application.setFileBrowserDisplayed(true);

				} else {

					application.setHomeDisplayed(true);
				}
			}

		state.onDisplayStateChanged = function() {

				application.setDisplayed(state.displayState);
			}

		state.onReadyStateChanged = function() {


			}

		state.onServiceLoginStateChanged = function(srvName) {

				if (!state.serviceList.get(srvName).isLoggedIn) {

					application.fileBrowser.removeService(srvName);

					application.setLogoutButtonDisplayed(false); // FIXME dropdown list instead

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

					application.setLogoutButtonDisplayed(true);
				}
			}

		state.onServiceAccountChanged = function(srvName) {

				application.setLogoutButtonContent(state.serviceList.get(srvName).account.displayName);
			}

		state.onCurrentLocationChanged = function() {

				if (state.currentLocation == null) {

					state.currentFileList = null;

				} else { trace("new location "+state.currentLocation.path);

					cd(state.currentLocation.service , state.currentLocation.path );
				}
			}

		state.onCurrentFileListChanged = function() {

				application.fileBrowser.resetFileList();

				if (state.currentFileList == null) {

					//application.fileBrowser.setEmptyMsgDisplay(true);

				} else {

					//application.fileBrowser.setEmptyMsgDisplay(false);

					if (state.currentLocation.path != "/") {

						application.fileBrowser.addFolder("..", "..");
					}

					for (fid in state.currentFileList.keys()) {

						if (state.currentFileList.get(fid).isDir) {

							application.fileBrowser.addFolder(fid, state.currentFileList.get(fid).name);

						} else {

							application.fileBrowser.addFile(fid, state.currentFileList.get(fid).name);
						}
					}
				}
			}
	}

	private function cpd(srvName : String, path : String) : Void {

		if (path.length > 1) {

			if (path.lastIndexOf('/') == path.length - 1) path = path.substr(0, path.length - 2);
			path = path.substr(0, path.lastIndexOf('/') + 1);

			state.currentLocation.service = srvName;
			state.currentLocation.path = path;
		}
	}

	private function cd(srvName : String, path : String) : Void {

		application.setLoaderDisplayed(true);

		unifileSrv.ls(srvName, path, function(files : StringMap<ce.core.model.unifile.File>){

				state.currentFileList = files;

				application.setFileBrowserDisplayed(true);

				application.setLoaderDisplayed(false);

			}, setError);
	}

	private function login(srvName : String) : Void {

		if (!state.serviceList.get(srvName).isLoggedIn) {

			application.setLoaderDisplayed(true);

			unifileSrv.login(srvName, function(lr : ce.core.model.unifile.LoginResult){

					if (lr.success) {

						state.serviceList.get(srvName).isLoggedIn = true;
					
					} else {

						state.serviceList.get(srvName).isLoggedIn = false;
						setError('Could not login. Please try again.');
					}

					application.setLoaderDisplayed(false);

				}, setError);
		}
		else trace("WON'T LOGIN "+srvName+" AS ALREADY LOGGED IN !!!");
	}
}