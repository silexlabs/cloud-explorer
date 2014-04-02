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

import haxe.ds.StringMap;

class State {

	public function new() { }

	public var readyState (default, set) : Bool = false;

	public var displayState (default, set) : Bool = false;

	public var serviceList (default, set) : Null<StringMap<Service>> = null;


	///
	// CALLBACKS
	//

	public dynamic function onReadyStateChanged() { }

	public dynamic function onDisplayStateChanged() { }

	public dynamic function onServiceListChanged() { }


	///
	// SETTERS
	//

	public function set_serviceList(v : Null<StringMap<Service>>) : Null<StringMap<Service>> {

		if (v == serviceList) {

			return v;
		}
		serviceList = v;

		onServiceListChanged();

		return serviceList;
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
}