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
package ce.core.model.api;

typedef ExportOptions = {

	/**
	 * The mimetype of the file. Note that we try to guess the file extension of the file from this, 
	 * so image/png will result in a .png ending while image/* will not have an ending. If you don't 
	 * specify the mimetype, we will try to guess, otherwise will fall back to letting the user save 
	 * it as whatever extension they choose, which may cause issues (if they try to save text to 
	 * Facebook, for instance).
	 */
	@:optional var mimetype : Null<String>;

	/**
	 * Specify the type of the file by extension rather than mimetype. Don't use this option with 
	 * mimetype(s) specified as well.
	 */
	@:optional var extension : Null<String>;
}