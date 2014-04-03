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
package ce.core.model.unifile;

typedef File = {

	var name : String;
	var bytes : Int;
	var modified : String; // FIXME would be better if unifile sent back a timestamp instead of "Wed, 08 Jan 2014 09:26:15 +0000",
	var isDir : Bool;
}