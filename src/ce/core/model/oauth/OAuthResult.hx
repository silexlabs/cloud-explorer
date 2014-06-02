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
package ce.core.model.oauth;

typedef OAuthResult = {

	/**
	 * true if the user chooses not to authorize the application.
	 */
	@:optional var notApproved : Bool;
	
	/**
	 * The request token that was just authorized. The request token secret isn't sent back.
	 */
	@:optional var oauthToken : String;
	
	/**
	 * The user's unique Dropbox ID.
	 */
	@:optional var uid : String;
}