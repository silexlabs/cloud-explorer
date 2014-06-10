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
package ce.core.model;

import ce.core.model.unifile.Service;
import ce.core.model.unifile.File;
import ce.core.model.Location;
import ce.core.model.Mode;
import ce.core.model.DisplayMode;
import ce.core.model.SortField;
import ce.core.model.SortOrder;

import haxe.ds.StringMap;

class State {

	public function new() { }

	public var readyState (default, set) : Bool = false;

	public var displayState (default, set) : Bool = false;

	public var newFolderMode (default, set) : Bool = false;

	public var displayMode (default, set) : Null<DisplayMode> = null;

	public var serviceList (default, set) : Null<StringMap<Service>> = null;

	public var currentLocation (default, set) : Null<Location> = null;

	public var currentFileList (default, set) : Null<StringMap<File>> = null;

	public var currentMode (default, set) : Null<Mode> = null;

	public var currentSortField (default, set) : Null<SortField> = null;

	public var currentSortOrder (default, set) : Null<SortOrder> = null;


	///
	// CALLBACKS
	//

	public dynamic function onReadyStateChanged() { }

	public dynamic function onDisplayStateChanged() { }

	public dynamic function onServiceListChanged() { }

	public dynamic function onCurrentLocationChanged() { }

	public dynamic function onCurrentFileListChanged() { }

	public dynamic function onCurrentModeChanged() { }

	public dynamic function onNewFolderModeChanged() { }

	public dynamic function onDisplayModeChanged() { }

	public dynamic function onCurrentSortFieldChanged() { }

	public dynamic function onCurrentSortOrderChanged() { }

	public dynamic function onServiceLoginStateChanged(srvName : String) { }

	public dynamic function onServiceAccountChanged(srvName : String) { }


	///
	// SETTERS
	//

	public function set_currentSortField(v : Null<SortField>) : Null<SortField> {

		if (v == currentSortField) {

			return currentSortField;
		}
		currentSortField = v;
		currentSortOrder = Asc; // setting new sort field also reset the order

		onCurrentSortFieldChanged();

		return currentSortField;
	}

	public function set_currentSortOrder(v : Null<SortOrder>) : Null<SortOrder> {

		if (v == currentSortOrder) {

			return currentSortOrder;
		}
		currentSortOrder = v;

		onCurrentSortOrderChanged();

		return currentSortOrder;
	}

	public function set_newFolderMode(v : Bool) : Bool {

		if (v == newFolderMode) {

			return newFolderMode;
		}
		newFolderMode = v;

		onNewFolderModeChanged();

		return newFolderMode;
	}

	public function set_displayMode(v : DisplayMode) : DisplayMode {

		if (v == displayMode) {

			return displayMode;
		}
		displayMode = v;

		onDisplayModeChanged();

		return displayMode;
	}

	public function set_serviceList(v : Null<StringMap<Service>>) : Null<StringMap<Service>> {

		if (v == serviceList) {

			return v;
		}
		serviceList = v;

		for (s in serviceList) {

			s.onLoginStateChanged = function() { onServiceLoginStateChanged(s.name); }
			s.onAccountChanged = function() { onServiceAccountChanged(s.name); }

			if (s.account != null) {

				onServiceAccountChanged(s.name);
			}
		}
		
		onServiceListChanged();

		return serviceList;
	}

	public function set_currentFileList(v : Null<StringMap<File>>) : Null<StringMap<File>> {

		if (v == currentFileList) {

			return v;
		}
		currentFileList = v;
		// reset both sort field and sort order
		currentSortField = Name;
		currentSortOrder = Asc;
		
		onCurrentFileListChanged();

		return currentFileList;
	}

	public function set_currentMode(v : Null<Mode>) : Null<Mode> {

		if (v == currentMode) {

			return v;
		}
		currentMode = v;
		
		onCurrentModeChanged();

		return currentMode;
	}

	public function set_readyState(v : Bool) : Bool {

		if (v == readyState) {

			return v;
		}
		readyState = v;

		onReadyStateChanged();

		return readyState;
	}

	public function set_displayState(v : Bool) : Bool {

		if (v == displayState) {

			return v;
		}
		displayState = v;

		onDisplayStateChanged();

		return displayState;
	}

	public function set_currentLocation(v : Location) : Location {

		if (v == currentLocation) {

			return v;
		}
		currentLocation = v;

		if (currentLocation != null) {

			currentLocation.onChanged = function() { onCurrentLocationChanged(); }
		}

		onCurrentLocationChanged();

		return currentLocation;
	}
}