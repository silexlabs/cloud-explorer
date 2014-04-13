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

using ce.util.HtmlTools;

class FileBrowser {

	static inline var SELECTOR_SRV_LIST : String = ".services ul";
	static inline var SELECTOR_FILES_LIST : String = ".files ul";

	static inline var SELECTOR_SRV_ITEM_TMPL : String = "li";
	static inline var SELECTOR_NEW_FOLDER_ITEM : String = ".folder.new";
	static inline var SELECTOR_FOLDER_ITEM_TMPL : String = ".folder:nth-last-child(-n+1)";
	static inline var SELECTOR_FILE_ITEM_TMPL : String = ".file";

	static inline var SELECTOR_NAME_BTN : String = ".titles .fileName";
	static inline var SELECTOR_TYPE_BTN : String = ".titles .fileType";
	static inline var SELECTOR_DATE_BTN : String = ".titles .lastUpdate";

	static inline var CLASS_SORT_ORDER_ASC : String = "asc";
	static inline var CLASS_SORT_ORDER_DESC : String = "desc";
	static inline var CLASS_PREFIX_SORTBY : String = "sortby-";

	public function new(elt : Element) {

		this.elt = elt;

		this.srvItemElts = new StringMap();

		this.srvListElt = elt.querySelector(SELECTOR_SRV_LIST);
		this.srvItemTmpl = srvListElt.querySelector(SELECTOR_SRV_ITEM_TMPL);
		srvListElt.removeChild(srvItemTmpl);

		this.fileListElt = elt.querySelector(SELECTOR_FILES_LIST);

		this.fileItemTmpl = fileListElt.querySelector(SELECTOR_FILE_ITEM_TMPL);
		fileListElt.removeChild(fileItemTmpl);
		
		this.newFolderItem = fileListElt.querySelector(SELECTOR_NEW_FOLDER_ITEM);
		this.newFolderInput = cast newFolderItem.querySelector("input");
		newFolderInput.addEventListener("keydown", function(e : KeyboardEvent){

				if (e.keyIdentifier.toLowerCase() == "enter") {

			        onNewFolderName();
			    }
			});
		newFolderInput.addEventListener("focusout", function(?_){ onNewFolderName(); });
		
		this.folderItemTmpl = fileListElt.querySelector(SELECTOR_FOLDER_ITEM_TMPL);
		fileListElt.removeChild(folderItemTmpl);

		var nameBtn = elt.querySelector(SELECTOR_NAME_BTN);
		nameBtn.addEventListener("click", function(?_){ toggleSort("name"); });
		var typeBtn = elt.querySelector(SELECTOR_TYPE_BTN);
		typeBtn.addEventListener("click", function(?_){ toggleSort("type"); });
		var dateBtn = elt.querySelector(SELECTOR_DATE_BTN);
		dateBtn.addEventListener("click", function(?_){ toggleSort("lastUpdate"); });

		this.fileListItems = [];
	}

	var elt : Element;

	// lists
	var srvListElt : Element;
	var fileListElt : Element;

	// templates
	var srvItemTmpl : Element;
	var fileItemTmpl : Element;
	var folderItemTmpl : Element;

	// items
	var newFolderItem : Element;
	var newFolderInput : InputElement;

	var srvItemElts : StringMap<Element>;

	public var fileListItems (default, null) : Array<FileListItem>;

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

	public dynamic function onFileSelected(id : String) : Void { }

	public dynamic function onFileClicked(id : String) : Void { }

	public dynamic function onFileDeleteClicked(id : String) : Void { }

	public dynamic function onFileCheckedStatusChanged(id : String) : Void { }

	public dynamic function onFileRenameRequested(id : String, value : String) : Void { }

	public dynamic function onNewFolderName() : Void { }


	///
	// API
	//
/*
	public function setEmptyMsgDisplay(v : Bool) : Void {


	}
*/
	public function removeService(name : String) : Void {

		srvListElt.removeChild(srvItemElts.get(name));
	}

	public function addService(name : String, displayName : String) : Void {

		var newItem : Element = cast srvItemTmpl.cloneNode(true);
		newItem.className = name;
		newItem.textContent = displayName;

		newItem.addEventListener( "click", function(?_){ onServiceClicked(name); } );

		srvListElt.appendChild(newItem);

		srvItemElts.set(name, newItem);
	}

	public function resetFileList() : Void {

		while(fileListItems.length > 0) {

			fileListElt.removeChild(fileListItems.pop().elt);
		}
	}

	public function addFolder(id : String, name : String, ? lastUpdate : Null<Date>) : Void {

		var newItem : Element = cast folderItemTmpl.cloneNode(true);

		var fli : FileListItem = new FileListItem(newItem);
		fli.name = name;
		fli.lastUpdate = lastUpdate;
		fli.onClicked = function() { onFileClicked(id); }
		fli.onDeleteClicked = function() { onFileDeleteClicked(id); }
		fli.onRenameRequested = function() { onFileRenameRequested(id, fli.renameValue); }

		fileListItems.push(fli);

		fileListElt.insertBefore(newItem, newFolderItem);
	}

	public function addFile(id : String, name : String, type : Null<String>, lastUpdate : Date) : Void {

		var newItem : Element = cast fileItemTmpl.cloneNode(true);

		var fli : FileListItem = new FileListItem(newItem);
		fli.name = name;
		if (type != null) {

			fli.type = type;
		}
		fli.lastUpdate = lastUpdate;
		fli.onClicked = function() { onFileClicked(id); }
		fli.onDeleteClicked = function() { onFileDeleteClicked(id); }
		fli.onRenameRequested = function() { onFileRenameRequested(id, fli.renameValue); }
		fli.onCheckedStatusChanged = function() { onFileCheckedStatusChanged(id); }

		fileListItems.push(fli);

		fileListElt.insertBefore(newItem, newFolderItem);
	}
	/*
		return function(date, uppercase) {
			return new Date(date).toLocaleDateString()
		}
	*/

	public function focusOnNewFolder() : Void {

		newFolderInput.focus();
	}

	///
	// INTERNALS
	//

	private function currentSortBy() : Null<String> {

		for (c in elt.className.split(" ")) {

			if( Lambda.has([CLASS_PREFIX_SORTBY + "name", CLASS_PREFIX_SORTBY + "type", CLASS_PREFIX_SORTBY + "lastupdate"], c) ) {

				return c;
			}
		}
		return null;
	}

	private function currentSortOrder() : Null<String> {

		for (c in elt.className.split(" ")) {

			if( Lambda.has([CLASS_SORT_ORDER_ASC, CLASS_SORT_ORDER_DESC], c) ) {

				return c;
			}
		}
		return null;
	}

	private function toggleSort(? by : String = "name") : Void {

		var csb : Null<String> = currentSortBy();
		var cso : Null<String> = currentSortOrder();

		if (csb == CLASS_PREFIX_SORTBY + by.toLowerCase()) {

			if (cso == CLASS_SORT_ORDER_ASC) {

				elt.toggleClass(CLASS_SORT_ORDER_ASC , false);
				elt.toggleClass(CLASS_SORT_ORDER_DESC , true);

				sort(by, false);

			} else {

				elt.toggleClass(CLASS_SORT_ORDER_ASC , true);
				elt.toggleClass(CLASS_SORT_ORDER_DESC , false);

				sort(by, true);
			}
			
		} else {

			if (csb != null) {
				elt.toggleClass(csb , false);
			}
			if (cso != null) {
				elt.toggleClass(cso , false);
			}
			elt.toggleClass(CLASS_PREFIX_SORTBY + by , true);
			elt.toggleClass(CLASS_SORT_ORDER_ASC , true);

			sort(by, true);
		}
	}

	private function sort(? by : String = "name", ? ascOrder : Bool = true) : Void {

		fileListItems.sort(function(a:FileListItem,b:FileListItem){

				if (ascOrder) {

					return Reflect.getProperty(a,by) > Reflect.getProperty(b,by) ? 1 : -1;

				} else {

					return Reflect.getProperty(a,by) < Reflect.getProperty(b,by) ? 1 : -1;
				}

			});

		for (fit in fileListItems) {

			fileListElt.insertBefore(fit.elt, newFolderItem);
		}
	}
}

class FileListItem {

	static inline var CLASS_RENAMING : String = "renaming";

	public function new(elt : Element) {

		this.elt = elt;

		this.checkBoxElt = cast elt.querySelector("input[type='checkbox']");
		checkBoxElt.addEventListener("change", function(?_){ onCheckedStatusChanged(); });

		this.nameElt = elt.querySelector("span.fileName");
		nameElt.addEventListener( "click", function(?_){ onClicked(); } );

		this.renameInput = cast elt.querySelector("input[type='text']");
		renameInput.addEventListener("keydown", function(e : KeyboardEvent){

				if (e.keyIdentifier.toLowerCase() == "enter") {

					elt.toggleClass(CLASS_RENAMING, false);
					onRenameRequested();
				}
			});
		renameInput.addEventListener("focusout", function(?_){

				elt.toggleClass(CLASS_RENAMING, false);
				onRenameRequested();
			});

		this.typeElt = elt.querySelector("span.fileType");
		this.dateElt = elt.querySelector("span.lastUpdate");

		this.renameBtn = elt.querySelector("button.rename");
		this.renameBtn.addEventListener( "click", function(?_){

				elt.toggleClass(CLASS_RENAMING, true);

				renameInput.value = nameElt.textContent;
				renameInput.focus();
			});

		this.deleteBtn = elt.querySelector("button.delete");
		this.deleteBtn.addEventListener( "click", function(?_){ onDeleteClicked(); } );
	}

	var checkBoxElt : InputElement;
	var nameElt : Element;
	var renameInput : InputElement;
	var typeElt : Element;
	var dateElt : Element;

	var renameBtn : Element;
	var deleteBtn : Element;

	///
	// PROPERTIES
	//

	public var elt (default, null) : Element;

	public var isChecked (get, null) : Bool;

	public var name (get, set) : String;

	public var renameValue (get, set) : String;

	public var type (get, set) : String;

	@:isVar public var lastUpdate (get, set) : Date;

	///
	// GETTERS / SETTERS
	//

	public function get_isChecked() : Bool {

		return checkBoxElt.checked;
	}

	public function get_renameValue() : String {
		
		return renameInput.value;
	}

	public function set_renameValue(v : String) : String {
		
		renameInput.value = v;

		return v;
	}

	public function get_name() : String {
		
		return nameElt.textContent;
	}

	public function set_name(v : String) : String {

		nameElt.textContent = v;

		return v;
	}

	public function get_type() : String {

		return typeElt.textContent;
	}

	public function set_type(v : String) : String {

		typeElt.textContent = v;

		return v;
	}

	public function get_lastUpdate() : Null<Date> {

		return lastUpdate;
	}

	public function set_lastUpdate(v : Null<Date>) : Null<Date> {

		lastUpdate = v;

		if (v != null) {

			dateElt.textContent = DateTools.format(lastUpdate, "%d/%m/%Y"); // FIXME "%x %X" not implemented yet in haxe/js
		}
		return v;
	}

	///
	// CALLBACKS
	//

	public dynamic function onCheckedStatusChanged() : Void { }

	public dynamic function onDeleteClicked() : Void { }

	public dynamic function onRenameRequested() : Void { }

	public dynamic function onClicked() : Void { }
}