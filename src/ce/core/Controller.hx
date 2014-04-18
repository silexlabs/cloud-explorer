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
import ce.core.model.Mode;

import ce.core.model.api.ReadOptions;
import ce.core.model.api.ExportOptions;
import ce.core.model.api.WriteOptions;

import ce.core.service.UnifileSrv;
import ce.core.service.FileSrv;

import haxe.ds.StringMap;

using ce.util.FileTools;
using StringTools;

class Controller {

	public function new(config : Config, iframe : js.html.IFrameElement) {

		this.config = config;

		this.state = new State();

		this.unifileSrv = new UnifileSrv(config);
		this.fileSrv = new FileSrv();

		this.application = new Application(iframe);

		initMvc();
	}

	var config : Config;
	var state : State;

	var application : Application;
	
	var unifileSrv : UnifileSrv;
	var fileSrv : FileSrv;


	///
	// API
	//

	public function pick(? options : Dynamic, onSuccess : CEBlob -> Void, onError : CEError -> Void) {

		state.currentMode = SingleFileSelection(onSuccess, onError);

		show();
	}

	/**
	 * TODO
	 *	- manage URL, DOM File Object, or <input type="file"/> as inputs
	 *  - manage options
	 *  - manage onProgress
	 */
	public function read(input : CEBlob, options : Null<ReadOptions>, onSuccess : String -> Void, onError : CEError -> Void, 
			onProgress : Int -> Void) {

		fileSrv.get(input.url, onSuccess, setError);
	}

	/**
	 * TODO
	 * 	- support url inputs
	 */
	public function exportFile(input : CEBlob, options : Null<ExportOptions>, onSuccess : CEBlob -> Void, onError : CEError -> Void) {

		state.currentMode = SingleFileExport(onSuccess, onError, input, options);

		show();
	}

	/**
	 * TODO
	 *  - data => Can be raw data, a CEBlob, a DOM File Object, or an <input type="file"/>.
	 */
	public function write(target : CEBlob, data : Dynamic, options : Null<WriteOptions>, onSuccess : CEBlob -> Void, onError : CEError -> Void, onProgress : Null<Int -> Void>) : Void {

		var explodedUrl : { srv : String, path : String, filename : String } = unifileSrv.explodeUrl(target.url);

		var fileBlob : js.html.Blob = new js.html.Blob([data], { "type": target.mimetype });

		unifileSrv.upload([explodedUrl.filename => fileBlob], explodedUrl.srv, explodedUrl.path, function() {

				if (state.currentFileList.get(explodedUrl.filename) == null) {

					refreshFilesList();
				}

				onSuccess(target);

			}, setError);
	}

	public function setAlert(msg : String, ? level : Int = 2, ? choices : Array<{ msg : String, cb : Void -> Void }>) : Void {

		if (choices == null || choices.length == 0) {

			application.onClicked = function() {

					application.setAlertPopupDisplayed(false);
				}

		} else {

			application.onClicked = function() { }
		}

		application.alertPopup.setMsg(msg, level, choices);

		application.setAlertPopupDisplayed(true);
	}

	public function setError(msg : String) : Void {

		application.setLoaderDisplayed(false); // FIXME should this be there ?
trace("ERROR HAPPENED");
		application.alertPopup.setMsg(msg, 0, [{ msg: "Continue", cb: function() { application.setAlertPopupDisplayed(false); }}]);

		application.setAlertPopupDisplayed(true);
	}

	///
	// INTERNALS
	//

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

				hide();
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

												setAlert("Popup Blocker is enabled! Please add this site to your exception list and reload the page.", 0);
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

				} else {

					var f : ce.core.model.unifile.File = state.currentFileList.get(id);

					if (state.currentMode == null) {

						if (f.isDir) {

							state.currentLocation.path += state.currentFileList.get(id).name + "/";
						}
						return;
					}

					switch (state.currentMode) {

						case SingleFileSelection(onSuccess, onError) if (!f.isDir):

							onSuccess({
									url: unifileSrv.generateUrl(state.currentLocation.service, state.currentLocation.path, f.name),
									filename: f.name,
									mimetype: f.name.getMimeType(),
									size: f.bytes,
									key: null, // FIXME not supported yet
									container: null, // FIXME not supported yet
									isWriteable: true, // FIXME not managed yet
									path: state.currentLocation.path
								});

							hide();

						default:

							state.currentLocation.path += state.currentFileList.get(id).name + "/";
					}
				}
			}

		application.onFileDeleteClicked = function(id : String) {

				var f : ce.core.model.unifile.File = state.currentFileList.get(id);

				setAlert("Are you sure you want to delete " + f.name + " from your " +
							state.serviceList.get(state.currentLocation.service).displayName + " storage?",
								1, [
									{
										msg: "Yes, delete it",
										cb: function(){

												application.setAlertPopupDisplayed(false);

												deleteFile(id);
											}
									},
									{
										msg: "No, do not delete it",

										cb: function(){

												application.setAlertPopupDisplayed(false);

											}
									}
								]);
			}

		application.onFileCheckedStatusChanged = function(?_) {

				for (f in application.fileBrowser.fileListItems) {

					if (f.isChecked) {

						application.setSelecting(true);
						return;
					}
				}
				application.setSelecting(false);
			}

		application.onFileRenameRequested = function(id : String, value : String) {

				var f : ce.core.model.unifile.File = state.currentFileList.get(id);

				if (value != f.name) {

					var oldPath : String = state.currentLocation.path;
					var newPath : String = state.currentLocation.path;

					// make it a reusable util
					oldPath = (oldPath == "/" || oldPath == "") ? f.name : oldPath + "/" + f.name;
					newPath = (newPath == "/" || newPath == "") ? value : newPath + "/" + value;

					application.setLoaderDisplayed(true);

					unifileSrv.mv(state.currentLocation.service, oldPath, newPath, function() {

							application.setLoaderDisplayed(false);

							refreshFilesList();

						}, setError);
				}
			}

		application.onOverwriteExportClicked = function() {

				switch(state.currentMode) {

					case SingleFileExport(onSuccess, onError, input, options):

						var fname : String = application.export.exportName;

						if (options != null ) {	// FIXME find a way to avoid doing that each time we need the full filename

							if (options.mimetype != null && options.mimetype.getExtension() != null) {

								fname += options.mimetype.getExtension();

							} else if (options.extension != null) {

								fname += options.extension.indexOf(".") != 0 ? "." + options.extension : options.extension;
							}
						}

						setAlert("Do you confirm overwriting of " + fname + "?", 1, [
							{
								msg: "Yes, do overwrite it.",
								cb: function() {

										application.setAlertPopupDisplayed(false);

										doExportFile();

										hide();
									}
							},
							{
								msg: "No, do not overwrite it.",
								cb: function() {

										application.setAlertPopupDisplayed(false);
									}
							}]);

					default: throw "unexpected mode "+state.currentMode;
				}
			}

		application.onSaveExportClicked = function() {

				doExportFile();

				hide();
			}

		application.onExportNameChanged = function() {

				if (application.export.exportName != "") {

					switch(state.currentMode) {

						case SingleFileExport(onSuccess, onError, input, options):

							// FIXME actually write the file
							
							var fname : String = application.export.exportName;

							if (options != null ) {

								if (options.mimetype != null && options.mimetype.getExtension() != null) {

									fname += options.mimetype.getExtension();

								} else if (options.extension != null) {

									fname += options.extension.indexOf(".") != 0 ? "." + options.extension : options.extension;
								}
							}
							for (f in state.currentFileList) {

								if (f.name == fname) {

									application.setExportOverwriteDisplayed(true);
									return;
								}
							}
							application.setExportOverwriteDisplayed(false);

						default: throw "unexpected mode "+state.currentMode;
					}
				}
			}

		application.onInputFilesChanged = function() {

				unifileSrv.upload(application.dropzone.inputElt.files, state.currentLocation.service, state.currentLocation.path, function() {

					//trace("file(s) uploaded with success");

					refreshFilesList();

				}, setError);
			}

		application.onNavBtnClicked = function(srv : String, path : String) {

				state.currentLocation = new Location(srv, path);
			}

		application.onNewFolderClicked = function() {

				application.setNewFolderDisplayed(true);
			}

		application.onDeleteClicked = function() {

				setAlert("Are you sure you want to delete the selected files from your " +
					state.serviceList.get(state.currentLocation.service).displayName + " storage?", 1,
						[
							{ msg: "Yes, delete the selected files", cb: function(){ application.setAlertPopupDisplayed(false); deleteSelectedFiles(); }}, 
							{ msg: "No, do not delete the selected files", cb: function(){ application.setAlertPopupDisplayed(false); }}
						]);
			}

		application.onNewFolderName = function() {

				var name = application.fileBrowser.newFolderName;

				// TODO check name sanity

				if (name.trim() == "") {

					application.setNewFolderDisplayed(false);

				} else {

					var mkDirPath : String = state.currentLocation.path;

					mkDirPath = (mkDirPath == "/" || mkDirPath == "") ? name : mkDirPath + "/" + name;

					unifileSrv.mkdir(state.currentLocation.service, mkDirPath, function(){

							application.setNewFolderDisplayed(false);

							refreshFilesList();

						}, function(e : String){ 

							application.setNewFolderDisplayed(false);

							setError(e);

						});
				}
			}

		state.onServiceListChanged = function() {

				var lastConnectedService : Null<String> = null;

				application.home.resetList();

				for (s in state.serviceList) {

					application.home.addService(s.name, s.displayName, s.description);

					if (s.isLoggedIn) {

						lastConnectedService = s.name;
					}

					application.fileBrowser.addService(s.name, s.displayName);
				}
				if (lastConnectedService != null) {

					if (state.currentLocation == null) {

						state.currentLocation = new Location(lastConnectedService, "/");
					}

					application.setLogoutButtonDisplayed(true);

					application.setFileBrowserDisplayed(true);

				} else {

					application.setLogoutButtonDisplayed(false);

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
					for (s in state.serviceList) {

						if (s.isLoggedIn) {

							return;
						}
					}
					application.setHomeDisplayed(true);

				} else {

					if (state.serviceList.get(srvName).account == null) {

						unifileSrv.account(srvName, function(a : ce.core.model.unifile.Account){

								state.serviceList.get(srvName).account = a;

							}, setError);
					}
					if (state.currentLocation == null) {

						state.currentLocation = new Location(srvName, "/");
					}
					//application.fileBrowser.addService(srvName, state.serviceList.get(srvName).displayName);

					application.setLogoutButtonDisplayed(true);
				}
			}

		state.onServiceAccountChanged = function(srvName) {

				application.setLogoutButtonContent(state.serviceList.get(srvName).account.displayName);
			}

		state.onCurrentLocationChanged = function() {

				if (state.currentLocation == null) {

					state.currentFileList = null;

				} else { //trace("new location "+state.currentLocation.path);

					// TODO make util to manipulate easily and safely file pathes (getFolderName(), getPath(), ...)
					var p = state.currentLocation.path;
					while (p.length > 0 && p.lastIndexOf("/") == p.length - 1) p = p.substr(0, p.length - 1);
	
					application.breadcrumb.setTitle(p.length > 1 ? p.substr(p.lastIndexOf('/')+1) : state.currentLocation.service);

					application.breadcrumb.setBreadcrumbPath(state.currentLocation.service, state.currentLocation.path);

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

							application.fileBrowser.addFolder(fid, state.currentFileList.get(fid).name, state.currentFileList.get(fid).modified);

						} else {

							application.fileBrowser.addFile(fid, state.currentFileList.get(fid).name, state.currentFileList.get(fid).name.getMimeType(), state.currentFileList.get(fid).modified);
						}
					}
				}
			}

		state.onCurrentModeChanged = function() {

				if (state.currentMode != null) {

					switch (state.currentMode) {

						case SingleFileSelection(onSuccess, onError):

							// nothing specific...

						case SingleFileExport(onSuccess, onError, input, options):

							var ext : Null<String> = options != null && options.mimetype != null ? FileTools.getExtension(options.mimetype) : null;

							if (ext == null && options != null && options.extension != null) {

								ext = (options.extension.indexOf('.') == 0) ? options.extension : "." + options.extension;
							}
							application.export.ext = ext != null ? ext : "";

							application.export.exportName = "";

							application.setExportOverwriteDisplayed(false);
					}
				}

				application.setModeState(state.currentMode);
			}
	}

	private function deleteSelectedFiles() : Void {

		var toDelCnt : Int = 0;

		for (f in application.fileBrowser.fileListItems) {

			if (f.isChecked) {

				toDelCnt++;

				var rmDirPath : String = state.currentLocation.path;

				rmDirPath = (rmDirPath == "/" || rmDirPath == "") ? f.name : rmDirPath + "/" + f.name;

				application.setLoaderDisplayed(true);

				unifileSrv.rm(state.currentLocation.service, rmDirPath, function(){

						toDelCnt--;

						if (toDelCnt == 0) {

							application.setLoaderDisplayed(false);

							refreshFilesList();
						}

					}, setError);
			}
		}
	}

	private function deleteFile(id : String) : Void {

		var f : ce.core.model.unifile.File = state.currentFileList.get(id);

		var rmDirPath : String = state.currentLocation.path;

		rmDirPath = (rmDirPath == "/" || rmDirPath == "") ? f.name : rmDirPath + "/" + f.name;

		application.setLoaderDisplayed(true);

		unifileSrv.rm(state.currentLocation.service, rmDirPath, function() {

				application.setLoaderDisplayed(false);

				refreshFilesList();

			}, setError);
	}

	/**
	 * Actually exports a file.
	 * FIXME the function actually writes nothing yet but just return a CEBlob
	 */
	private function doExportFile() : Void {

		switch(state.currentMode) {

			case SingleFileExport(onSuccess, onError, input, options):

				// FIXME actually write the file
				
				var fname : String = application.export.exportName;

				if (options != null ) {

					if (options.mimetype != null && options.mimetype.getExtension() != null) {

						fname += options.mimetype.getExtension();

					} else if (options.extension != null) {

						fname += options.extension.indexOf(".") != 0 ? "." + options.extension : options.extension;
					}
				}

				onSuccess({ url: unifileSrv.generateUrl(state.currentLocation.service, state.currentLocation.path, fname), 
							filename: fname, 
							mimetype: options != null && options.mimetype != null ? options.mimetype : fname.getMimeType(), 
							size: null, 
							key: null,
							container: null,
							isWriteable: true,
							path: null });

			default: // nothing
		}
	}

	/**
	 * Change to parent directory.
	 */
	private function cpd(srvName : String, path : String) : Void {

		if (path.length > 1) {

			if (path.lastIndexOf('/') == path.length - 1) path = path.substr(0, path.length - 2);
			path = path.substr(0, path.lastIndexOf('/') + 1);

			state.currentLocation.service = srvName;
			state.currentLocation.path = path;
		}
	}

	private function refreshFilesList() : Void {

		cd(state.currentLocation.service , state.currentLocation.path );
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

	private function hide() : Void {

		state.displayState = false;
	}

	private function show() : Void {

		var goHome : Bool = true;

		if (state.serviceList != null) {

			for (s in state.serviceList) {

				if (s.isLoggedIn) {

					goHome = false;
					break;
				}
			}
		}
		if (goHome || state.currentFileList == null) {

			application.setLoaderDisplayed(true);

			unifileSrv.listServices(function(slm : StringMap<ce.core.model.unifile.Service>) {

					application.setLoaderDisplayed(false);

					state.serviceList = slm;

				}, setError);

		} else {

			application.setFileBrowserDisplayed(true);
		}

		state.displayState = true;
	}
}