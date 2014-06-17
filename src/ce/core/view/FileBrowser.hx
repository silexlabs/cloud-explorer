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
import js.html.NodeList;

import haxe.ds.StringMap;

import ce.core.model.SortField;
import ce.core.model.SortOrder;

using ce.util.HtmlTools;
using ce.util.FileTools;
using StringTools;

class FileBrowser {

	static inline var SELECTOR_SRV_LIST : String = ".services ul";
	static inline var SELECTOR_FILES_LIST : String = ".files ul";

	static inline var SELECTOR_SRV_ITEM_TMPL : String = "li";
	static inline var SELECTOR_NEW_FOLDER_ITEM : String = ".folder.new";
	static inline var SELECTOR_FOLDER_ITEM_TMPL : String = ".folder:nth-last-child(-n+1)";
	static inline var SELECTOR_FILE_ITEM_TMPL : String = ".file";
	static inline var SELECTOR_CONTEXT_MENU_ITEMS : String = "ul.contextMenu li";

	static inline var SELECTOR_NAME_BTN : String = ".titles .fileName";
	static inline var SELECTOR_TYPE_BTN : String = ".titles .fileType";
	static inline var SELECTOR_DATE_BTN : String = ".titles .lastUpdate";

	static inline var CLASS_SELECT_FOLDER : String = "selectFolders";
	static inline var CLASS_SRV_CONNECTED : String = "connected";

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

				untyped {
					if (e.keyIdentifier != null && e.keyIdentifier.toLowerCase() == "enter" ||
						e.key != null && e.key.toLowerCase() == "enter") {

				        onNewFolderName();
				    }
				}
			});
		newFolderInput.addEventListener("focusout", function(?_){ onNewFolderName(); });
		
		this.folderItemTmpl = fileListElt.querySelector(SELECTOR_FOLDER_ITEM_TMPL);
		fileListElt.removeChild(folderItemTmpl);

		var nameBtn = elt.querySelector(SELECTOR_NAME_BTN);
		nameBtn.addEventListener("click", function(?_){ onSortBtnClicked(Name); });
		var typeBtn = elt.querySelector(SELECTOR_TYPE_BTN);
		typeBtn.addEventListener("click", function(?_){ onSortBtnClicked(Type); });
		var dateBtn = elt.querySelector(SELECTOR_DATE_BTN);
		dateBtn.addEventListener("click", function(?_){ onSortBtnClicked(LastUpdate); });

		this.fileListItems = [];

		this.filters = null;
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

	public var filters (default, set) : Null<Array<String>>;

	public var fileListItems (default, null) : Array<FileListItem>;

	public var newFolderName (get, set) : Null<String>;


	///
	// CALLBACKS
	//

	public dynamic function onServiceLoginRequest(name : String) : Void { }

	public dynamic function onServiceLogoutRequest(name : String) : Void { }

	public dynamic function onServiceClicked(name : String) : Void { }

	public dynamic function onFileSelected(id : String) : Void { }

	public dynamic function onFileClicked(id : String) : Void { }

	public dynamic function onFileSelectClicked(id : String) : Void { }

	public dynamic function onFileDeleteClicked(id : String) : Void { }

	public dynamic function onFileCheckedStatusChanged(id : String) : Void { }

	public dynamic function onFileRenameRequested(id : String, value : String) : Void { }

	public dynamic function onNewFolderName() : Void { }

	public dynamic function onSortBtnClicked(field : SortField) : Void { }


	///
	// API
	//
/*
	public function setEmptyMsgDisplay(v : Bool) : Void {


	}
*/

	public function resetList() : Void {

		while(srvListElt.childNodes.length > 0) {

			srvListElt.removeChild(srvListElt.childNodes.item(0));
		}
	}

	public function removeService(name : String) : Void {

		srvListElt.removeChild(srvItemElts.get(name));
	}

	public function addService(name : String, displayName : String, ? connected : Bool) : Void {

		var newItem : Element = cast srvItemTmpl.cloneNode(true);
		newItem.className = name;
		//newItem.setAttribute("title", newItem.getAttribute("title").replace("{srvName}", displayName));

		newItem.addEventListener("click", function(?_){ onServiceClicked(name); });

		var lis : NodeList = newItem.querySelectorAll(SELECTOR_CONTEXT_MENU_ITEMS);

		for (i in 0...lis.length) {

			var li : Element = cast lis[i];

			li.textContent = li.textContent.replace("{srvName}", displayName);
			li.addEventListener("click", function(e:js.html.MouseEvent){

					e.stopPropagation();

					if (li.classList.contains("login")) {

						onServiceLoginRequest(name);

					} else if (li.classList.contains("logout")) {

						onServiceLogoutRequest(name);
					}

				});
		}

		srvListElt.appendChild(newItem);

		srvItemElts.set(name, newItem);

		if (connected) setSrvConnected(name , connected);
	}

	public function setSrvConnected(name : String, connected : Bool) : Void {

		srvItemElts.get(name).toggleClass(CLASS_SRV_CONNECTED , connected);
	}

	public function resetFileList() : Void {

		while(fileListItems.length > 0) {

			fileListElt.removeChild(fileListItems.pop().elt);
		}
	}

	public function addFolder(id : String, name : String, ? lastUpdate : Null<Date>, ? selectable : Bool = true) : Void {

		var newItem : Element = cast folderItemTmpl.cloneNode(true);

		var fli : FileListItem = new FileListItem(newItem);
		fli.name = name;
		fli.lastUpdate = lastUpdate;
		fli.onClicked = function() { onFileClicked(id); }
		fli.onSelectClicked = function() { onFileSelectClicked(id); }
		fli.onDeleteClicked = function() { onFileDeleteClicked(id); }
		fli.onRenameRequested = function() { onFileRenameRequested(id, fli.renameValue); }
		fli.onCheckedStatusChanged = function() { onFileCheckedStatusChanged(id); }
		fli.selectable = selectable;

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

		applyFilters(fli);

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

	public function sort(byField : SortField, order : SortOrder) : Void {

		fileListItems.sort(function(a:FileListItem,b:FileListItem){

				switch (order) {

					case Asc:

						return Reflect.getProperty(a, byField) > Reflect.getProperty(b, byField) ? 1 : -1;

					case Desc:

						return Reflect.getProperty(a, byField) < Reflect.getProperty(b, byField) ? 1 : -1;
				}
			});

		for (fit in fileListItems) {

			fileListElt.insertBefore(fit.elt, newFolderItem);
		}
	}


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


	public function set_filters(v : Null<Array<String>>) : Null<Array<String>> {

		if (filters == v) {

			return v;
		}
		filters = v;

		if (filters != null && filters.indexOf(ce.util.FileTools.DIRECTORY_MIME_TYPE) > -1) {

			elt.toggleClass(CLASS_SELECT_FOLDER, true);
		
		} else {

			elt.toggleClass(CLASS_SELECT_FOLDER, false);
		}
		for (f in fileListItems) {

			applyFilters(f);
		}
		return filters;
	}

	///
	// INTERNALS
	//

	private function applyFilters(f : FileListItem) : Void {

		if (f.type != FileTools.DIRECTORY_MIME_TYPE) {

			if (filters == null || filters.indexOf(f.type) != -1) {

				f.filteredOut = false;

			} else {

				f.filteredOut = true;
			}
		}
	}
}

class FileListItem {

	static inline var CLASS_RENAMING : String = "renaming";
	static inline var CLASS_NOT_SELECTABLE : String = "nosel";
	static inline var CLASS_FILTERED_OUT : String = "filteredOut";
	static inline var CLASS_FOLDER : String = "folder"; // not ideal we have this in 3 constants FIXME
	static inline var CLASS_IMAGE : String = "image";
	static inline var CLASS_SOUND : String = "sound";
	static inline var CLASS_VIDEO : String = "video";

	public function new(elt : Element) {

		this.elt = elt;

		this.checkBoxElt = cast elt.querySelector("input[type='checkbox']");
		checkBoxElt.addEventListener("change", function(?_){ onCheckedStatusChanged(); });

		this.nameElt = elt.querySelector("span.fileName");
		nameElt.addEventListener( "click", function(?_){ onClicked(); } );

		this.renameInput = cast elt.querySelector("input[type='text']");
		renameInput.addEventListener("keydown", function(e : KeyboardEvent){
				untyped {				
					if (e.keyIdentifier != null && e.keyIdentifier.toLowerCase() == "enter" ||
						e.key != null && e.key.toLowerCase() == "enter") {

						elt.toggleClass(CLASS_RENAMING, false);
						onRenameRequested();
					}
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

		this.selectBtn = elt.querySelector("button.select");
		if (selectBtn != null) {
			selectBtn.addEventListener( "click", function(?_){ onSelectClicked(); } );
		}
	}

	var checkBoxElt : InputElement;
	var nameElt : Element;
	var renameInput : InputElement;
	var typeElt : Element;
	var dateElt : Element;

	var renameBtn : Element;
	var deleteBtn : Element;
	var selectBtn : Null<Element>;

	///
	// PROPERTIES
	//

	public var elt (default, null) : Element;

	public var isChecked (get, null) : Bool;

	public var name (get, set) : String;

	public var renameValue (get, set) : String;

	public var type (get, set) : String;

	@:isVar public var lastUpdate (get, set) : Date;

	public var selectable (get, set) : Bool;

	public var filteredOut (get, set) : Bool;

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

		if (elt.hasClass(CLASS_FOLDER)) {

			return FileTools.DIRECTORY_MIME_TYPE;
		}
		return typeElt.textContent;
	}

	public function set_type(v : String) : String {

		typeElt.textContent = v;

		elt.toggleClass(CLASS_IMAGE, v.indexOf("image/") == 0);
		elt.toggleClass(CLASS_SOUND, v.indexOf("audio/") == 0);
		elt.toggleClass(CLASS_VIDEO, v.indexOf("video/") == 0);

		return v;
	}

	public function get_lastUpdate() : Null<Date> {

		return lastUpdate;
	}

	public function set_lastUpdate(v : Null<Date>) : Null<Date> {

		lastUpdate = v;

		if (v != null) {

			dateElt.textContent = DateTools.format(lastUpdate, "%d/%m/%Y"); // FIXME "%x %X" not implemented yet in haxe/js
		
		} else {

			dateElt.innerHTML = "&nbsp;";
		}
		return v;
	}

	public function get_selectable() : Bool {

		return !elt.hasClass(CLASS_NOT_SELECTABLE);
	}

	public function set_selectable(v : Bool) : Bool {

		elt.toggleClass(CLASS_NOT_SELECTABLE, !v);

		return v;
	}

	public function get_filteredOut() : Bool {

		return elt.hasClass(CLASS_FILTERED_OUT);
	}

	public function set_filteredOut(v : Bool) : Bool {

		elt.toggleClass(CLASS_FILTERED_OUT, v);

		return v;
	}

	///
	// CALLBACKS
	//

	public dynamic function onCheckedStatusChanged() : Void { }

	public dynamic function onDeleteClicked() : Void { }

	public dynamic function onRenameRequested() : Void { }

	public dynamic function onSelectClicked() : Void { }

	public dynamic function onClicked() : Void { }
}