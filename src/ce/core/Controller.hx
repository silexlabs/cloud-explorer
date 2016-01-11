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
import ce.core.model.SortField;
import ce.core.model.SortOrder;

import ce.core.model.oauth.OAuthResult;
import ce.core.model.api.PickOptions;
import ce.core.model.api.ReadOptions;
import ce.core.model.api.ExportOptions;
import ce.core.model.api.WriteOptions;

import ce.core.parser.oauth.Str2OAuthResult;

import ce.core.service.UnifileSrv;

import ce.core.model.unifile.UnifileError;
import ce.core.ctrl.ErrorCtrl;

import haxe.ds.StringMap;

using ce.util.FileTools;
using ce.util.OptionTools;
using StringTools;

class Controller {

	public function new(config : Config, iframe : js.html.IFrameElement) {

		this.config = config;

		this.state = new State();

		this.unifileSrv = new UnifileSrv(config);

		this.application = new Application(iframe, config);

		this.errorCtrl = new ErrorCtrl(this, state, application);

		initMvc();
	}

	var config : Config;
	var state : State;

	var errorCtrl : ErrorCtrl;

	var application : Application;
	
	var unifileSrv : UnifileSrv;


	///
	// API
	//

	public function pick(? options : Null<PickOptions>, onSuccess : CEBlob -> Void, onError : CEError -> Void) {

		options.normalizePickOptions();

		state.currentMode = SingleFileSelection(onSuccess, onError, options);

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

		options.normalizeReadOptions();

		unifileSrv.get(input.url, onSuccess, function(e:UnifileError){

				onError(new ce.core.model.CEError(e.code));

			});
	}

	/**
	 * TODO
	 * 	- support url inputs
	 */
	public function exportFile(input : CEBlob, options : Null<ExportOptions>, onSuccess : CEBlob -> Void, onError : CEError -> Void) {

		options.normalizeExportOptions();

		state.currentMode = SingleFileExport(onSuccess, onError, input, options);

		show();
	}

	/**
	 * TODO
	 *  - data => Can be raw data, a CEBlob, a DOM File Object, or an <input type="file"/>.
	 */
	public function write(target : CEBlob, data : Dynamic, options : Null<WriteOptions>, onSuccess : CEBlob -> Void, onError : CEError -> Void, onProgress : Null<Int -> Void>) : Void {

		options.normalizeWriteOptions();

		var explodedUrl : { srv : String, path : String, filename : String } = unifileSrv.explodeUrl(target.url);

		var fileBlob : js.html.Blob = new js.html.Blob([data], { "type": target.mimetype });

		unifileSrv.upload([explodedUrl.filename => fileBlob], explodedUrl.srv, explodedUrl.path, function() {

				if (state.currentFileList.get(explodedUrl.filename) == null) {

					refreshFilesList();
				}

				onSuccess(target);

			}, function(e:UnifileError) {

				onError(new CEError(e.code));
			});
	}

	public function isLoggedIn(srvName : String, onSuccess : Bool -> Void, onError : CEError -> Void) : Void {

		state.currentMode = IsLoggedIn(onSuccess, onError, srvName);
		
		if (state.serviceList == null) {

			listServices();

		} else {

			if (state.serviceList.get(srvName) == null) {

				trace("unknown service "+srvName);

				onError(new CEError(CEError.CODE_BAD_PARAMETERS));
			
			} else {

				onSuccess(state.serviceList.get(srvName).isLoggedIn);
			}
		}
	}

	public function requestAuthorize(srvName : String, onSuccess : Void -> Void, onError : CEError -> Void) : Void {

		state.currentMode = RequestAuthorize(onSuccess, onError, srvName);

		if (state.serviceList == null) {

			listServices();

		} else {

			if (state.serviceList.get(srvName) == null) {

				trace("unknown service "+srvName);
				onError(new CEError(CEError.CODE_BAD_PARAMETERS));
			
			} else if (state.serviceList.get(srvName).isLoggedIn) {

				trace("user already logged into "+srvName);
				onSuccess();

			} else {

				state.displayState = true;

				connect(srvName);
			}
		}
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

	///
	// INTERNALS
	//

	private function initMvc() : Void {

		application.onViewReady = function() {

				state.displayMode = List;

				state.currentSortField = Name;

				state.readyState = true;
			}

		application.onLogoutClicked = function() {

				logoutAll();
			}

		application.onCloseClicked = function() {

				hide();
			}

		application.onServiceLoginRequest = function(name : String) {

				if (state.serviceList.get(name).isLoggedIn) {

					throw "unexpected call to login "+name;
				
				} else {

					connect(name);
				}
			}

		application.onServiceLogoutRequest = function(name : String) {

				if (!state.serviceList.get(name).isLoggedIn) {

					throw "unexpected call to logout "+name;
				}
				logout(name);
			}

		application.onServiceClicked = function(name : String) {

				if (state.serviceList.get(name).isLoggedIn) {

					state.currentLocation = new Location(name, "/");
				
				} else {

					connect(name);
				}
			}

		application.onFileSelectClicked = function(id : String) { // folder selection case

				var f : ce.core.model.unifile.File = state.currentFileList.get(id);

				switch (state.currentMode) {

						case SingleFileSelection(onSuccess, onError, options) if (f.isDir):

							onSuccess({
									url: unifileSrv.generateUrl(state.currentLocation.service, state.currentLocation.path, f.name),
									filename: f.name,
									mimetype: ce.util.FileTools.DIRECTORY_MIME_TYPE,
									size: null,
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

		application.onParentFolderClicked = function() {

				cpd(state.currentLocation.service, state.currentLocation.path);
			}

		application.onFileClicked = function(id : String) {

				var f : ce.core.model.unifile.File = state.currentFileList.get(id);

				if (state.currentMode == null) {

					if (f.isDir) {

						state.currentLocation.path += state.currentFileList.get(id).name + "/";
					}
					return;
				}

				switch (state.currentMode) {

					case SingleFileSelection(onSuccess, onError, options) if (!f.isDir):

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

					case SingleFileExport(onSuccess, onError, input, options) if (!f.isDir):

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

						}, errorCtrl.setUnifileError);
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

		application.onFilesDropped = function(files : js.html.FileList) {

				application.setLoaderDisplayed(true);

				unifileSrv.upload(files, state.currentLocation.service, state.currentLocation.path, function() {

					//trace("file(s) uploaded with success");

					refreshFilesList();

				}, errorCtrl.setUnifileError);
			}

		application.onInputFilesChanged = function() {

				application.setLoaderDisplayed(true);

				unifileSrv.upload(application.dropzone.inputElt.files, state.currentLocation.service, state.currentLocation.path, function() {

					//trace("file(s) uploaded with success");

					refreshFilesList();

				}, errorCtrl.setUnifileError);
			}

		application.onNavBtnClicked = function(srv : String, path : String) {

				state.currentLocation = new Location(srv, path);
			}

		application.onNewFolderClicked = function() {

				state.newFolderMode = !state.newFolderMode;
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

					state.newFolderMode = false;

				} else {

					var mkDirPath : String = state.currentLocation.path;

					mkDirPath = (mkDirPath == "/" || mkDirPath == "") ? name : mkDirPath + "/" + name;

					unifileSrv.mkdir(state.currentLocation.service, mkDirPath, function(){

							state.newFolderMode = false;

							refreshFilesList();

						}, function(e : UnifileError){ 

							state.newFolderMode = false;

							errorCtrl.setUnifileError(e);

						});
				}
			}

		application.onItemsListClicked = function() {

				state.displayMode = List;
			}

		application.onItemsIconClicked = function() {

				state.displayMode = Icons;
			}

		application.onSortBtnClicked = function(field : SortField) {

				if (state.currentSortField == field) {

					state.currentSortOrder = state.currentSortOrder == Asc ? Desc : Asc;
				
				} else {

					state.currentSortField = field;
				}
			}

		state.onServiceListChanged = function() {

				switch (state.currentMode) {

					case IsLoggedIn(onSuccess, onError, srvName) :

						isLoggedIn(srvName, onSuccess, onError);

					case RequestAuthorize(onSuccess, onError, srvName):

						requestAuthorize(srvName, onSuccess, onError);

					case SingleFileSelection(_), SingleFileExport(_):

						// nothing in particular
				}

				var lastConnectedService : Null<String> = null;

				application.home.resetList();
				application.fileBrowser.resetList();
				application.fileBrowser.resetFileList();

				for (s in state.serviceList) {

					application.home.addService(s.name, s.displayName, s.description);

					if (s.isLoggedIn) {

						lastConnectedService = s.name;
					}
					application.fileBrowser.addService(s.name, s.displayName, s.isLoggedIn);
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

				application.fileBrowser.setSrvConnected(srvName, state.serviceList.get(srvName).isLoggedIn);

				switch (state.currentMode) {

					case SingleFileSelection(_), SingleFileExport(_):

						// nothing

					case IsLoggedIn(_):

						throw "unexpected mode: " + state.currentMode;

					case RequestAuthorize(onSuccess, _, _):

						onSuccess();
						hide();
				}

				if (!state.serviceList.get(srvName).isLoggedIn) {

					if (state.currentLocation.service == srvName) {

						for (s in state.serviceList) {

							if (s.isLoggedIn) {

								state.currentLocation = new Location(s.name, "/");
								return;
							}
						}
						state.currentLocation = null;
					}

				} else {

					application.setLogoutButtonDisplayed(true);

					if (state.serviceList.get(srvName).account == null) {

						unifileSrv.account(srvName, function(a : ce.core.model.unifile.Account){

								state.serviceList.get(srvName).account = a;

							}, errorCtrl.setUnifileError);
					}
					state.currentLocation = new Location(srvName, "/");
				}
			}

		state.onDisplayModeChanged = function() {

				switch(state.displayMode) {

					case List:

						application.setListDisplayMode();

					case Icons:

						application.setIconDisplayMode();
				}				
			}

		state.onCurrentLocationChanged = function() {

				if (state.currentLocation == null) {

					state.currentFileList = null;

					application.setLogoutButtonDisplayed(false);

					application.setHomeDisplayed(true);

				} else { //trace("new location "+state.currentLocation.path);

					// TODO make util to manipulate easily and safely file pathes (getFolderName(), getPath(), ...)
					var p = state.currentLocation.path;
					while (p.length > 0 && p.lastIndexOf("/") == p.length - 1) p = p.substr(0, p.length - 1);
	
					application.breadcrumb.setBreadcrumbPath(state.currentLocation.service, state.currentLocation.path);
					application.setCurrentService(state.currentLocation.service);

					cd(state.currentLocation.service , state.currentLocation.path );
				}
			}

		state.onCurrentFileListChanged = function() {

				application.fileBrowser.resetFileList();

				application.setSelecting(false);

				application.setSortField(state.currentSortField);
				application.setSortOrder(state.currentSortOrder);

				if (state.currentFileList == null) {

					//application.fileBrowser.setEmptyMsgDisplay(true);

				} else {

					//application.fileBrowser.setEmptyMsgDisplay(false);

					if (state.currentLocation.path != "/") {

						application.parentFolderBtn.enabled = true;

					} else {

						application.parentFolderBtn.enabled = false;
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

					// reset file filtering
					application.fileBrowser.filters = null;

					switch (state.currentMode) {

						case IsLoggedIn(_), RequestAuthorize(_):

							// nothing...

						case SingleFileSelection(onSuccess, onError, options):

							if (options != null) {

								if ((options.mimetype != null || options.mimetypes != null) &&
									(options.extension != null || options.extensions != null)) {

									throw "Cannot pass in both mimetype(s) and extension(s) parameters to the pick function";
								}

								var filters : Null<Array<String>> = null;

								// check conflicts between filtering options
								if (options.mimetype != null || options.mimetypes != null) {

									if (options.mimetype != null) {

										if (options.mimetypes != null) {

											throw "Cannot pass in both mimetype and mimetypes parameters to the pick function";
										}
										filters = [options.mimetype];
									
									} else {

										filters = options.mimetypes;
									}

								} else {

									var extensions : Null<Array<String>> = null;

									if (options.extension != null) {

										if (options.extensions != null) {

											throw "Cannot pass in both extension and extensions parameters to the pick function";
										}
										extensions = [options.extension];
									
									} else {

										extensions = options.extensions;
									}
									if (extensions != null && extensions.length > 0) {

										filters = [];

										for (e in extensions) {

											var mimetype : Null<String> = FileTools.getMimeType((e.indexOf('.') == 0) ? e : "." + e);
											
											if (mimetype != null && filters.indexOf(e) == -1) {

												filters.push(mimetype);
											}
										}
									}
								}
								if (filters != null) {

									application.fileBrowser.filters = filters;
								}
							}

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

		state.onNewFolderModeChanged = function() {

				application.setNewFolderDisplayed(state.newFolderMode);
			}

		state.onCurrentSortOrderChanged = function() {

				application.setSortOrder(state.currentSortOrder);
				application.fileBrowser.sort(state.currentSortField, state.currentSortOrder);
			}

		state.onCurrentSortFieldChanged = function() {

				application.setSortField(state.currentSortField);
				application.setSortOrder(state.currentSortOrder);
				application.fileBrowser.sort(state.currentSortField, state.currentSortOrder);
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

					}, errorCtrl.setUnifileError);
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

			}, errorCtrl.setUnifileError);
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

			}, errorCtrl.setUnifileError);
	}

	public function connect(srv : ce.core.model.Service) : Void {

		if (state.serviceList.get(srv).isLoggedIn) {

			trace("unexpected call to connect "+srv);
			return;
		}
		application.setLoaderDisplayed(true);

		unifileSrv.connect(srv, function(cr : ce.core.model.unifile.ConnectResult) {

				state.serviceList.get(srv).isConnected = true;

				application.authPopup.setServerName(state.serviceList.get(srv).displayName);

				application.authPopup.onClicked = function() {

						application.onAuthorizationWindowBlocked = function() {

								application.setAuthPopupDisplayed(false);

								setAlert("Popup Blocker is enabled! Please add this site to your exception list and reload the page.", 0);
							}

						application.onServiceAuthorizationDone = function(? result : Null<OAuthResult>) {

								application.setAuthPopupDisplayed(false);
								// Will ask Unifile if the client is logged
								login(srv);
								// Unbind to prevent the timer to call it a second time
								application.onServiceAuthorizationDone = null;
							}

						var authUrl : String = cr.authorizeUrl + (cr.authorizeUrl.indexOf('?') > -1 ? '&' : '?')
													+ 'oauth_callback=' + StringTools.urlEncode(application.location
													+ (!application.location.endsWith('/') && !config.path.startsWith('/') ? '/' : '') + 
													config.path + (!config.path.endsWith('/') && config.path.length > 0 ? '/' : '') + 'oauth-cb.html');

						application.openAuthorizationWindow(authUrl);
					}

				application.setAuthPopupDisplayed(true);

			}, function(e : UnifileError) {

				state.serviceList.get(srv).isConnected = false;

				errorCtrl.manageConnectError(e.message);

			});
	}

	private function login(srv : ce.core.model.Service) : Void {

		if (!state.serviceList.get(srv).isLoggedIn) {

			application.setLoaderDisplayed(true);

			unifileSrv.login(srv, function(lr : ce.core.model.unifile.LoginResult){

					application.setLoaderDisplayed(false);

					state.serviceList.get(srv).isLoggedIn = true;

				}, function(e:UnifileError){

					state.serviceList.get(srv).isLoggedIn = false;
					
					errorCtrl.manageLoginError(e.message);

				});
		
		} else {

			trace("can't log into "+srv+" as user already logged in!");
		}
	}

	private function logout(srv : ce.core.model.Service) : Void {

		if (state.serviceList.get(srv).isLoggedIn) {

			application.setLoaderDisplayed(true);

			unifileSrv.logout(srv, function(lr : ce.core.model.unifile.LogoutResult){
		
					application.setLoaderDisplayed(false);

					state.serviceList.get(srv).isLoggedIn = false;

				}, function(e:UnifileError) {

					errorCtrl.setUnifileError(e);

				});
		
		} else {

			trace("can't log out from "+srv+" as user not yet logged in!");
		}
	}

	private function logoutAll() : Void {
		
		application.setLoaderDisplayed(true);

		var loggedInSrvs : Array<String> = [];

		for (srv in state.serviceList) {

			if (srv.isLoggedIn) {

				loggedInSrvs.push(srv.name);
			}
		}
		for (srv in loggedInSrvs) {

			//logout(srv.name); don't do that or it will try to do stuff on state updates

			var s = srv;

			unifileSrv.logout(s, function(lr : ce.core.model.unifile.LogoutResult){

					loggedInSrvs.remove(s);

					if (loggedInSrvs.length == 0) {

						application.setLoaderDisplayed(false);

						listServices();
					}

				}, function(e:UnifileError) {

					errorCtrl.setUnifileError(e);
				});
		}
	}

	private function listServices() : Void {

		application.setLoaderDisplayed(true);

		unifileSrv.listServices(function(slm : StringMap<ce.core.model.unifile.Service>) {

				application.setLoaderDisplayed(false);

				state.serviceList = slm;

			}, function(e:UnifileError){

				errorCtrl.manageListSrvError(e.message);

			});
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

			listServices();

		} else {

			application.setFileBrowserDisplayed(true);
		}

		state.displayState = true;
	}
}
