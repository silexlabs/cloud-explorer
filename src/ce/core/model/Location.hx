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

class Location {

	public function new(s : Service, p : String) {

		this.service = s;
		this.path = p;
	}
	
	public var service (default, set) : Service;

	public var path (default, set) : String;


	///
	// CALLBACKS
	//

	public dynamic function onChanged() { }


	///
	// GETTERS / SETTERS
	//

	public function set_service(v : Service) : Service {

		if (v == service) {

			return v;
		}
		service = v;

		onChanged();

		return service;
	}

	public function set_path(v : String) : String {

		if (v == path) {

			return v;
		}
		path = v;

		onChanged();

		return path;
	}
}