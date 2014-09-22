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
 * @see https://developers.inkfilepicker.com/docs/web/#errors
 */
class CEError {

	/**
	 * Bad parameters were passed to the server. This often will be the case when you turned on security but 
	 * haven't passed up a policy or signature.
	 */
	static public inline var CODE_BAD_PARAMETERS : Int = 400;

	static public inline var CODE_UNAUTHORIZED : Int = 401;

	/**
	 * The policy and/or signature don't allow you to make this request.
	 * @see https://developers.inkfilepicker.com/docs/security/
	 */
	static public inline var CODE_INVALID_REQUEST : Int = 403;

	public function new(code : Int) { }

	public var code (default, null) : Int;

	public function toString() : String {

		return Std.string(code);
	}
}