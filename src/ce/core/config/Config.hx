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
package ce.core.config;

/*
TODO
	- list of enabled services ?
*/
class Config {

	static inline var PROP_NAME_UNIFILE_ENDPOINT : String = "unifile-url";

	static inline var PROP_NAME_CE_PATH : String = "path";

	static inline var PROP_VALUE_DEFAULT_UNIFILE_ENDPOINT : String = "http://localhost:6805/api/1.0/";

	static inline var PROP_VALUE_DEFAULT_CE_PATH : String = "";

	public function new() { }

	/**
	 * The unifile service endpoint / url
	 * @see https://github.com/silexlabs/unifile/
	 */
	public var unifileEndpoint (default, null) : String = PROP_VALUE_DEFAULT_UNIFILE_ENDPOINT;

	/**
	 * The cloud-explorer/ folder path
	 */
	public var path (default, null) : String = PROP_VALUE_DEFAULT_CE_PATH;

	///
	// API
	//

	public function readProperty(name : String, value : String) : Void {

		switch(name) {

			case PROP_NAME_UNIFILE_ENDPOINT:

				unifileEndpoint = value;

			case PROP_NAME_CE_PATH:

				path = value;

			default:

				throw "Unexpected configuration property " + name;
		}
	}
}