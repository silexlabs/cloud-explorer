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

/**
 * @see https://developers.inkfilepicker.com/docs/web/#inkblob
 */
typedef CEBlob = {

	/**
	 * The most critical part of the file, the url points to where the file is stored and acts as a sort of "file path".
	 * The url is what is used when making the underlying GET and POST calls to Ink when you do a filepicker.read or 
	 * filepicker.write call.
	 */
	var url : String;

	/**
	 * The name of the file, if available.
	 */
	var filename : Null<String>;

	/**
	 * The mimetype of the file, if available.
	 */
	var mimetype : Null<String>;

	/**
	 * The size of the file in bytes, if available. We will attach this directly to the InkBlob when we have it, 
	 * otherwise you can always get the size by calling filepicker.stat
	 */
	var size : Null<Int>;

	/**
	 * If the file was stored in one of the file stores you specified or configured (S3, Rackspace, Azure, etc.), 
	 * this parameter will tell you where in the file store this file was put.
	 */
	var key : Null<String>;

	/**
	 * If the file was stored in one of the file stores you specified or configured (S3, Rackspace, Azure, etc.), 
	 * this parameter will tell you in which container this file was put.
	 */
	var container : Null<String>;

	/**
	 * This flag specifies whether the underlying file is writeable. In most cases this will be true, but if a user 
	 * uploads a photo from facebook, for instance, the original file cannot be written to. In these cases, you should 
	 * use the filepicker.exportFile call as a way to give the user the ability to save their content.
	 */
	var isWriteable : Bool;

	/**
	 * The path of the InkBlob indicates its position in the hierarchy of files uploaded when {folders:true} is set. 
	 * In situations where the file was not uploaded as part of or along with a folder, path will not be defined.
	 */
	var path : Null<String>;
}