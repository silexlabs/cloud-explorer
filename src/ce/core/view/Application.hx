package ce.core.view;

class Application {



	public function new(iframe : js.html.IFrameElement) {

		this.iframe = iframe;
	}

	var iframe : js.html.IFrameElement;

	///
	// API
	//

	public function setDisplayed(v : Bool) : Void {

		iframe.style.display = v ? "block" : "none";
	}
}