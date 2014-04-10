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
import js.html.InputElement;
import js.html.KeyboardEvent;

import haxe.ds.StringMap;

class FileBrowser {

	static inline var SELECTOR_SRV_LIST : String = ".services ul";
	static inline var SELECTOR_FILES_LIST : String = ".files ul";

	static inline var SELECTOR_SRV_ITEM_TMPL : String = "li";
	static inline var SELECTOR_NEW_FOLDER_ITEM : String = ".folder.new";
	static inline var SELECTOR_FOLDER_ITEM_TMPL : String = ".folder";
	static inline var SELECTOR_FILE_ITEM_TMPL : String = ".file";

	public function new(elt : Element) {

		this.elt = elt;

		this.srvItemElts = new StringMap();

		this.srvList = elt.querySelector(SELECTOR_SRV_LIST);
		this.srvItemTmpl = srvList.querySelector(SELECTOR_SRV_ITEM_TMPL);
		srvList.removeChild(srvItemTmpl);

		this.fileList = elt.querySelector(SELECTOR_FILES_LIST);

		fileItemTmpl = fileList.querySelector(SELECTOR_FILE_ITEM_TMPL);
		fileList.removeChild(fileItemTmpl);
		
		newFolderItem = fileList.querySelector(SELECTOR_NEW_FOLDER_ITEM);
		fileList.removeChild(newFolderItem);
		newFolderInput = cast newFolderItem.querySelector("input");
		newFolderInput.addEventListener("keydown", function(e : KeyboardEvent){

				if (e.keyIdentifier.toLowerCase() == "enter") {

			        onNewFolderName();
			    }
			});
		newFolderInput.addEventListener("focusout", function(?_){ onNewFolderName(); });
		
		folderItemTmpl = fileList.querySelector(SELECTOR_FOLDER_ITEM_TMPL);
		fileList.removeChild(folderItemTmpl);
	}

	var elt : Element;

	var srvList : Element;
	var fileList : Element;

	var srvItemTmpl : Element;
	var fileItemTmpl : Element;
	var folderItemTmpl : Element;
	var newFolderItem : Element;
	var newFolderInput : InputElement;

	var srvItemElts : StringMap<Element>;

	public var newFolderName (get, set) : Null<String>;


	///
	// GETTERS / SETTERS
	//

	public function get_newFolderName() : Null<String> {

		return newFolderInput.value;
	}

	public function set_newFolderName(v : Null<String>) : Null<String> {

		newFolderInput.value = v;

		return v;
	}


	///
	// CALLBACKS
	//

	public dynamic function onServiceClicked(name : String) : Void { }

	public dynamic function onFileClicked(id : String) : Void { }

	public dynamic function onNewFolderName() : Void { }


	///
	// API
	//
/*
	public function setEmptyMsgDisplay(v : Bool) : Void {


	}
*/
	public function removeService(name : String) : Void {

		srvList.removeChild(srvItemElts.get(name));
	}

	public function addService(name : String, displayName : String) : Void {

		var newItem : Element = cast srvItemTmpl.cloneNode(true);
		newItem.textContent = displayName;

		newItem.addEventListener( "click", function(?_){ onServiceClicked(name); } );

		srvList.appendChild(newItem);

		srvItemElts.set(name, newItem);
	}

	public function resetFileList() : Void {

		while(fileList.childNodes.length > 0) {

			fileList.removeChild(fileList.firstChild);
		}
		fileList.appendChild(newFolderItem);
	}

	public function addFolder(id : String, name : String) : Void {

		var newItem : Element = cast folderItemTmpl.cloneNode(true);
		newItem.textContent = name;

		newItem.addEventListener( "click", function(?_){ onFileClicked(id); } );

		fileList.insertBefore(newItem, newFolderItem);
	}

	public function addFile(id : String, name : String) : Void {

		var newItem : Element = cast fileItemTmpl.cloneNode(true);
		newItem.textContent = name;

		newItem.addEventListener( "click", function(?_){ onFileClicked(id); } );

		fileList.insertBefore(newItem, newFolderItem);
	}

	public function focusOnNewFolder() : Void {

		newFolderInput.focus();
	}
}