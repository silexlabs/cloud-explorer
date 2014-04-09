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

typedef WriteOptions = {

	/**
	 * Specify that you want the data to be first decoded from base64 before being written to the file. 
	 * For example, if you have base64 encoded image data, you can use this flag to first decode the data 
	 * before writing the image file.
	 */
	@:optional var base64decode : Bool;

}