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

typedef ReadOptions = {

	/**
	 * Specify that you want the data to be retuned converted into base 64. 
	 * This is very useful when the contents of the file are binary rather than text, for example with images. 
	 * For your convenience, the filepicker.base64.encode and filepicker.base64.decode methods are available for your convenience.
	 */
	@:optional var base64encode : Bool;

	/**
	 * If you know you want the file to be read as text, the Ink files library can be more efficient if you tell it to convert 
	 * everything into text.
	 */
	@:optional var asText : Bool;

	/**
	 * Whether the data should be pulled from the browser's cache, if possible. Defaults to false.
	 * Can make reads faster if you're sure the underlying file won't change.
	 */
	@:optional var cache : Bool;
}