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

/**
 * An optional dictionary of key-value pairs that specify how the picker behaves.
 */
typedef PickOptions = {

	/**
	 * Specify the type of file that the user is allowed to pick. For example, if 
	 * you wanted images, specify image/* and users will only be able to select 
	 * images to upload. Similarly, you could specify application/msword for only 
	 * Word Documents.
	 * You can also specify an array of mimetypes to allow the user to select a 
	 * file from any of the given types.
	 */
	@:optional var mimetype : Null<String>;

	@:optional var mimetypes : Null<Array<String>>;

	/**
	 * Specify the type of file that the user is allowed to pick by extension. 
	 * Don't use this option with mimetype(s) specified as well
	 * You can also specify an array of extensions to allow the user to select 
	 * a file from any of the given types.
	 */
	@:optional var extension : Null<String>;

	@:optional var extensions : Null<Array<String>>;

	/**
	 * Where to load the Ink file picker UI into. Possible values are "window", 
	 * "modal", or the id of an iframe in the current document. Defaults to "modal". 
	 * Note that if the browser disables 3rd party cookies, the dialog will 
	 * automatically fall back to being served in a new window.
	 */
	// var container : String;

	/**
	 * Specify which services are displayed on the left panel, and in which order, by 
	 * name.
	 * Be sure that the services you select are compatible with the mimetype(s) or 
	 * extension(s) specified.
	 * Currently, the Ink file picker supports the following services, and we're adding 
	 * more all the time:
	 */
	// service
	// services

	/**
	 * Specifies which service to show upon opening. If not set, the user is shown their 
	 * most recently used location, or otherwise the computer upload page.
	 */
	// openTo

	/**
	 * Limit file uploads to be at max maxSize bytes.
	 */
	// maxSize

	/**
	 * Useful when developing, makes it so the onSuccess callback is fired immediately with 
	 * dummy data.
	 */
	//var debug : Bool = false;

	/**
	 * If you have security enabled, you'll need to have a valid Ink file picker policy and signature in order to perform the requested call. This allows you to select who can and cannot perform certain actions on your site.
	 * @see https://developers.inkfilepicker.com/docs/security/
	 */
	// policy: POLICY
	// signature: SIGNATURE
}