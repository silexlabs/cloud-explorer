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

import ce.core.model.SortField;
import ce.core.model.SortOrder;
import ce.core.model.Service;

import ce.core.model.oauth.OAuthResult;
import ce.core.parser.oauth.Str2OAuthResult;

import ce.core.config.Config;

import js.Browser;
import js.html.Element;

using ce.util.HtmlTools;
using StringTools;

class Application {

	static var oauthCbListener : String -> Void;

	@:expose('CEoauthCb')
	static function oauthCb(pStr : String) : Void { // FIXME this prevents from multi-instancing

		if (oauthCbListener != null) {

			oauthCbListener(pStr);
		}
	}

	static inline var PLACE_HOLDER_LOGOUT_NAME : String = "{name}";

	static inline var ID_APPLICATION : String = "cloud-explorer";

	static inline var CLASS_LOADING : String = "loading";
	static inline var CLASS_STARTING : String = "starting";
	static inline var CLASS_BROWSING : String = "browsing";
	static inline var CLASS_AUTHORIZING : String = "authorizing";
	static inline var CLASS_LOGGED_IN : String = "loggedin";
	static inline var CLASS_ALERTING : String = "alerting";
	static inline var CLASS_MAKING_NEW_FOLDER : String = "making-new-folder";
	static inline var CLASS_SELECTING : String = "selecting";

	static inline var CLASS_EXPORT_OVERWRITING : String = "export-overwriting";

	static inline var CLASS_MODE_SINGLE_FILE_SELECTION : String = "single-file-sel-mode";
	static inline var CLASS_MODE_SINGLE_FILE_EXPORT : String = "single-file-exp-mode";
	static inline var CLASS_MODE_IS_LOGGED_IN : String = "is-logged-in-mode";
	static inline var CLASS_MODE_REQUEST_AUTHORIZE : String = "request-authorize-mode";

	static inline var CLASS_ITEMS_LIST : String = "items-list";
	static inline var CLASS_ITEMS_ICONS : String = "items-icons";

	static inline var CLASS_PREFIX_SORTEDBY : String = "sortedby-";
	static inline var CLASS_PREFIX_SERVICE : String = "srv-";

	static inline var SELECTOR_LOGOUT_BTN : String = ".logoutBtn";
	static inline var SELECTOR_CLOSE_BTN : String = ".closeBtn";
	static inline var SELECTOR_HOME : String = ".home";
	static inline var SELECTOR_FILE_BROWSER : String = ".fileBrowser";
	static inline var SELECTOR_ALERT_POPUP : String = ".alertPopup";
	static inline var SELECTOR_AUTH_POPUP : String = ".authPopup";
	static inline var SELECTOR_BREADCRUMB : String = ".breadcrumb";
	static inline var SELECTOR_DROPZONE : String = ".dropzone";
	static inline var SELECTOR_EXPORT : String = ".export";
	static inline var SELECTOR_NEW_FOLDER_BTN : String = ".newFolderBtn";
	static inline var SELECTOR_PARENT_FOLDER_BTN : String = ".parentFolderBtn";
	static inline var SELECTOR_DELETE_BTN : String = ".deleteBtn";
	static inline var SELECTOR_ITEMS_LIST_BTN : String = ".listItemsBtn";
	static inline var SELECTOR_ITEMS_ICON_BTN : String = ".iconItemsBtn";

	public function new(iframe : js.html.IFrameElement, config : Config) {

		this.iframe = iframe;
		this.config = config;

		initFrame();

		oauthCbListener = listenOAuthCb;
	}

	var config : Config;

	var iframe : js.html.IFrameElement;

	var rootElt : Element;


	///
	// CALLBACKS
	//

	public dynamic function onClicked() : Void { }

	public dynamic function onSortBtnClicked(f : SortField) : Void { }

	public dynamic function onViewReady() : Void { }

	public dynamic function onLogoutClicked() : Void { }

	public dynamic function onCloseClicked() : Void { }

	public dynamic function onServiceLoginRequest(name : String) : Void { }

	public dynamic function onServiceLogoutRequest(name : String) : Void { }

	public dynamic function onServiceClicked(name : String) : Void { }

	public dynamic function onFileClicked(id : String) : Void { }
	
	public dynamic function onFileSelectClicked(id : String) : Void { }

	public dynamic function onFileDeleteClicked(id : String) : Void { }

	public dynamic function onFileRenameRequested(id : String, value : String) : Void { }

	public dynamic function onFileCheckedStatusChanged(id : String) : Void { }

	public dynamic function onNavBtnClicked(srv : String, path : String) : Void { }

	public dynamic function onAuthorizationWindowBlocked() : Void { }

	public dynamic function onServiceAuthorizationDone(? r : Null<OAuthResult>) : Void { }

	public dynamic function onSaveExportClicked() : Void { }

	public dynamic function onOverwriteExportClicked() : Void { }

	public dynamic function onExportNameChanged() : Void { }

	public dynamic function onInputFilesChanged() : Void { }

	public dynamic function onNewFolderClicked() : Void { }

	public dynamic function onParentFolderClicked() : Void { }

	public dynamic function onItemsListClicked() : Void { }

	public dynamic function onItemsIconClicked() : Void { }

	public dynamic function onDeleteClicked() : Void { }

	public dynamic function onNewFolderName() : Void { }


	///
	// API
	//

	public var home (default, null) : Home;

	public var fileBrowser (default, null) : FileBrowser;

	public var authPopup (default, null) : AuthPopup;

	public var alertPopup (default, null) : AlertPopup;

	public var breadcrumb (default, null) : Breadcrumb;

	public var dropzone (default, null) : DropZone;

	public var export (default, null) : Export;

	public var location(get, null) : Null<String>;

	public var closeBtn (default, null) : Button;

	public var newFolderBtn (default, null) : Button;

	public var parentFolderBtn (default, null) : Button;

	public var itemsListBtn (default, null) : Button;

	public var itemsIconBtn (default, null) : Button;

	public var deleteBtn (default, null) : Button;

	public var logoutBtn (default, null) : Button;

	public function setCurrentService(s : Service) : Void {

		rootElt.toggleClass(CLASS_PREFIX_SERVICE + Service.Dropbox, false);
		rootElt.toggleClass(CLASS_PREFIX_SERVICE + Service.Ftp, false);
		rootElt.toggleClass(CLASS_PREFIX_SERVICE + Service.Www, false);

		rootElt.toggleClass(CLASS_PREFIX_SERVICE + s, true);
	}

	public function setSortField(v : String) : Void {

		rootElt.toggleClass(CLASS_PREFIX_SORTEDBY + SortField.Name, false);
		rootElt.toggleClass(CLASS_PREFIX_SORTEDBY + SortField.Type, false);
		rootElt.toggleClass(CLASS_PREFIX_SORTEDBY + SortField.LastUpdate, false);

		rootElt.toggleClass(CLASS_PREFIX_SORTEDBY + v, true);
	}

	public function setSortOrder(v : String) : Void {

		rootElt.toggleClass(SortOrder.Asc, false);
		rootElt.toggleClass(SortOrder.Desc, false);

		rootElt.toggleClass(v, true);
	}

	public function setListDisplayMode() : Void {
		
		this.rootElt.toggleClass(CLASS_ITEMS_LIST, true);
		this.rootElt.toggleClass(CLASS_ITEMS_ICONS, false);
	}

	public function setIconDisplayMode() : Void {

		this.rootElt.toggleClass(CLASS_ITEMS_ICONS, true);
		this.rootElt.toggleClass(CLASS_ITEMS_LIST, false);
	}

	public function setDisplayed(v : Bool) : Void {

		iframe.style.display = v ? "block" : "none";
	}

	public function setLoaderDisplayed(v : Bool) : Void {

		rootElt.toggleClass(CLASS_LOADING , v);
	}

	public function setLogoutButtonDisplayed(v : Bool) : Void {

		rootElt.toggleClass(CLASS_LOGGED_IN , v);
	}

	public function setHomeDisplayed(v : Bool) : Void {

		if (v) {

			cleanPreviousState();
		}

		rootElt.toggleClass(CLASS_STARTING , v);
	}

	public function setFileBrowserDisplayed(v : Bool) : Void {

		if (v) {

			cleanPreviousState();
		}

		rootElt.toggleClass(CLASS_BROWSING , v);
	}

	public function setExportOverwriteDisplayed(v : Bool) : Void {

		rootElt.toggleClass(CLASS_EXPORT_OVERWRITING , v);
	}

	public function setAuthPopupDisplayed(v : Bool) : Void {

		rootElt.toggleClass(CLASS_AUTHORIZING , v);
	}

	public function setAlertPopupDisplayed(v : Bool) : Void {

		rootElt.toggleClass(CLASS_ALERTING , v);
	}

	public function setNewFolderDisplayed(v : Bool) : Void {

		if (!v) {

			fileBrowser.newFolderName = "";
		}
		rootElt.toggleClass(CLASS_MAKING_NEW_FOLDER , v);

		if (v) {

			fileBrowser.focusOnNewFolder();
		}
	}

	public function setSelecting(v : Bool) : Void {

		rootElt.toggleClass(CLASS_SELECTING , v);
	}

	public function openAuthorizationWindow(url : String) : Void {

		// note: we might need to improve this method in order to have different possible sizes by cloud service
		var authPopup = Browser.window.open(url, "authPopup", "height=829,width=1035");

		if (authPopup == null || authPopup.closed || authPopup.closed == null) {
			
			onAuthorizationWindowBlocked();
		
		} else {

			if (authPopup.focus != null) { authPopup.focus(); }

			var timer = new haxe.Timer(500);
			
			timer.run = function() {
//trace("authPopup= "+authPopup+"  authPopup.closed= "+authPopup.closed);
					if (authPopup.closed) {

						timer.stop();

						onServiceAuthorizationDone();
					}
				}
		}
	}

	public function setModeState(v : ce.core.model.Mode) : Void {

		var cms : Null<String> = currentModeState();
//trace("current UI mode is: "+cms);
		if (cms != null) {

			rootElt.toggleClass(cms , false);
		}
		if (v != null) {

			switch (v) {

				case SingleFileSelection(_):

					rootElt.toggleClass(CLASS_MODE_SINGLE_FILE_SELECTION , true);

				case SingleFileExport(_):

					rootElt.toggleClass(CLASS_MODE_SINGLE_FILE_EXPORT , true);

				case IsLoggedIn(_):

					rootElt.toggleClass(CLASS_MODE_IS_LOGGED_IN , true);

				case RequestAuthorize(_):

					rootElt.toggleClass(CLASS_MODE_REQUEST_AUTHORIZE , true);
			}
		}
	}

	///
	// GETTER / SETTER
	//

	public function get_location() : Null<String> {

		if (iframe == null) return null;

		return iframe.contentDocument.location.origin;
	}


	///
	// INTERNALS
	//

	function listenOAuthCb(pStr : String) : Void {

		var o : OAuthResult = Str2OAuthResult.parse(pStr);

		onServiceAuthorizationDone(o);
	}

	function currentModeState() : Null<String> {

		for (c in rootElt.className.split(" ")) {

			if( Lambda.has([CLASS_MODE_SINGLE_FILE_SELECTION, CLASS_MODE_SINGLE_FILE_EXPORT], c) ) {

				return c;
			}
		}
		return null;
	}

	function currentState() : Null<String> {

		for (c in rootElt.className.split(" ")) {

			if( Lambda.has([CLASS_STARTING, CLASS_BROWSING], c) ) {

				return c;
			}
		}
		// if we're here, we have a problem (no current state ?!)
		return null;
	}

	private function cleanPreviousState() : Void {

		var cs : Null<String> = currentState(); //trace("current state = "+cs);

		rootElt.toggleClass(CLASS_AUTHORIZING, false);
		
		if (cs != null) {

			rootElt.toggleClass(cs, false);
		}
	}

	private function initFrame() : Void {

		// init iframe
		iframe.style.display = "none";
		iframe.style.position = "absolute";
		iframe.style.top = iframe.style.left = "0";
		iframe.style.width = iframe.style.height = "100%";

		iframe.onload = function(?_){ initElts(); }

		iframe.src = config.path + "cloud-explorer.html";

		//Application.oauthCb = function(p : String) { trace("oauthCb p="+p); onServiceAuthorizationDone(p); } // FIXME that's not ideal and prevent from multi instancing
	}

	private function initElts() : Void {

		// select elements
		rootElt = iframe.contentDocument.getElementById(ID_APPLICATION);

		logoutBtn = new Button(rootElt.querySelector(SELECTOR_LOGOUT_BTN));
		logoutBtn.onClicked = onLogoutClicked;

		closeBtn = new Button(rootElt.querySelector(SELECTOR_CLOSE_BTN));
		closeBtn.onClicked = onCloseClicked;

		breadcrumb = new Breadcrumb(rootElt.querySelector(SELECTOR_BREADCRUMB));
		breadcrumb.onNavBtnClicked = function(srv : String, path : String) { onNavBtnClicked(srv, path); }

		export = new Export(rootElt.querySelector(SELECTOR_EXPORT));
		export.onSaveBtnClicked = function() { onSaveExportClicked(); }
		export.onOverwriteBtnClicked = function() { onOverwriteExportClicked(); }
		export.onExportNameChanged = function() { onExportNameChanged(); }

		home = new Home(rootElt.querySelector(SELECTOR_HOME));
		home.onServiceClicked = function(name : String) { onServiceClicked(name); }

		fileBrowser = new FileBrowser(rootElt.querySelector(SELECTOR_FILE_BROWSER));
		fileBrowser.onServiceLogoutRequest = function(name : String) { onServiceLogoutRequest(name); }
		fileBrowser.onServiceLoginRequest = function(name : String) { onServiceLoginRequest(name); }
		fileBrowser.onServiceClicked = function(name : String) { onServiceClicked(name); }
		fileBrowser.onFileClicked = function(id : String) { onFileClicked(id); }
		fileBrowser.onFileSelectClicked = function(id : String) { onFileSelectClicked(id); }
		fileBrowser.onFileDeleteClicked = function(id : String) { onFileDeleteClicked(id); }
		fileBrowser.onFileCheckedStatusChanged = function(id : String) { onFileCheckedStatusChanged(id); }
		fileBrowser.onFileRenameRequested = function(id : String, value : String) { onFileRenameRequested(id, value); }
		fileBrowser.onNewFolderName = function() { onNewFolderName(); }
		fileBrowser.onSortBtnClicked = function(f:SortField) { onSortBtnClicked(f); }

		dropzone = new DropZone(rootElt.querySelector(SELECTOR_DROPZONE));
		dropzone.onInputFilesChanged = function() { onInputFilesChanged(); }

		authPopup = new AuthPopup(rootElt.querySelector(SELECTOR_AUTH_POPUP));

		alertPopup = new AlertPopup(rootElt.querySelector(SELECTOR_ALERT_POPUP));

		newFolderBtn = new Button(rootElt.querySelector(SELECTOR_NEW_FOLDER_BTN));
		newFolderBtn.onClicked = onNewFolderClicked;

		parentFolderBtn = new Button(rootElt.querySelector(SELECTOR_PARENT_FOLDER_BTN));
		parentFolderBtn.onClicked = onParentFolderClicked;

		itemsListBtn = new Button(rootElt.querySelector(SELECTOR_ITEMS_LIST_BTN));
		itemsListBtn.onClicked = onItemsListClicked;

		itemsIconBtn = new Button(rootElt.querySelector(SELECTOR_ITEMS_ICON_BTN));
		itemsIconBtn.onClicked = onItemsIconClicked;

		deleteBtn = new Button(rootElt.querySelector(SELECTOR_DELETE_BTN));
		deleteBtn.onClicked = onDeleteClicked;

		rootElt.addEventListener("click", function(?_){ onClicked(); });

		onViewReady();
	}
}