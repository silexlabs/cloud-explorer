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

using ce.util.HtmlTools;

class Application {

	static inline var ID_APPLICATION : String = "cloud-explorer";

	static inline var CLASS_LOADING : String = "loading";
	static inline var CLASS_STARTING : String = "starting";
	static inline var CLASS_BROWSING : String = "browsing";

	static inline var SELECTOR_LOGOUT_BTN : String = ".logoutBtn";
	static inline var SELECTOR_CLOSE_BTN : String = ".closeBtn";
	static inline var SELECTOR_HOME : String = ".home";
	static inline var SELECTOR_BROWSER : String = ".browser";



	public function new(iframe : js.html.IFrameElement) {

		this.iframe = iframe;

		initFrame();
	}

	var iframe : js.html.IFrameElement;

	var rootElt : Element;

	var logoutBtn : Element;
	var closeBtn : Element;


	public var home (default, null) : Home;

	public var browser (default, null) : Browser;


	///
	// CALLBACKS
	//

	public dynamic function onViewReady() : Void { }

	public dynamic function onLogoutClicked() : Void { }

	public dynamic function onCloseClicked() : Void { }

	public dynamic function onServiceClicked(srvIndex : Int) : Void { }


	///
	// API
	//

	public function setDisplayed(v : Bool) : Void {

		iframe.style.display = v ? "block" : "none";
	}

	public function setLoaderDisplayed(v : Bool) : Void {

		rootElt.toggleClass(CLASS_LOADING , v);
	}

	public function setHomeDisplayed(v : Bool) : Void {

		rootElt.toggleClass(CLASS_STARTING , v);
	}

	public function setBrowserDisplayed(v : Bool) : Void {

		rootElt.toggleClass(CLASS_BROWSING , v);
	}


	///
	// INTERNALS
	//

	private function initFrame() : Void {

		// init iframe
		iframe.style.display = "none"; trace("initFrame");
		iframe.style.position = "absolute";
		iframe.style.top = iframe.style.left = iframe.style.bottom = iframe.style.right = "0";

		iframe.onload = function(?_){ initElts(); }

		iframe.src = "cloud-explorer.html";
	}

	private function initElts() : Void {

		// select elements
		rootElt = iframe.contentDocument.getElementById(ID_APPLICATION);

		logoutBtn = rootElt.querySelector(SELECTOR_LOGOUT_BTN);
		logoutBtn.addEventListener( "click", function(?_){ onLogoutClicked(); } );

		closeBtn = rootElt.querySelector(SELECTOR_CLOSE_BTN);
		closeBtn.addEventListener( "click", function(?_){ onCloseClicked(); } );

		home = new Home(rootElt.querySelector(SELECTOR_HOME));
		home.onServiceClicked = onServiceClicked;

		browser = new Browser(rootElt.querySelector(SELECTOR_BROWSER));

		onViewReady();
	}
}