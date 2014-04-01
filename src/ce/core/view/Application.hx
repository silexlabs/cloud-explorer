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
	static inline var SELECTOR_LOADER : String = ".loader";
	static inline var SELECTOR_HOME : String = ".home";
	static inline var SELECTOR_BROWSER : String = ".browser";



	public function new(iframe : js.html.IFrameElement) {

		this.iframe = iframe;

		init();
	}

	var iframe : js.html.IFrameElement;

	var rootElt : Element;

	var logoutBtn : Element;
	var closeBtn : Element;

	var loader : Element;
	var home : Element;
	var browser : Element;


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

	private function init() : Void {

		// init iframe
		iframe.style.display = "none";
		iframe.style.position = "absolute";
		iframe.style.top = iframe.style.left = iframe.style.bottom = iframe.style.right = "0";
		iframe.src = "cloud-explorer.html";

		// select elements
		trace("iframe.contentDocument= "+iframe.contentDocument.body.innerHTML);
		rootElt = iframe.contentDocument.getElementById(ID_APPLICATION);

		logoutBtn = rootElt.querySelector(SELECTOR_LOGOUT_BTN);
		closeBtn = rootElt.querySelector(SELECTOR_CLOSE_BTN);

		loader = rootElt.querySelector(SELECTOR_LOADER);
		home = rootElt.querySelector(SELECTOR_HOME);
		browser = rootElt.querySelector(SELECTOR_BROWSER);
	}
}