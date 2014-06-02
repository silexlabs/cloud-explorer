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

class Service {

	public function new(n : String, dn : String, is : String, d : String, v : Bool, il : Bool, ic : Bool, ioa : Bool, ? a : Null<Account>) {

		this.name = n;
		this.displayName = dn;
		this.imageSmall = is;
		this.description = d;
		this.visible = v;
		this.isLoggedIn = il;
		this.isConnected = ic;
		this.isOAuth = ioa;
		this.account = a;
	}

	public var name (default, null) : String;
	public var displayName (default, null) : String;
	public var imageSmall (default, null) : String;
	public var description (default, null) : String;
	public var visible (default, null) : Bool;
	public var isLoggedIn (default, set) : Bool;
	public var isOAuth (default, null) : Bool;
	public var isConnected (default, default) : Bool;
	public var account (default, set) : Null<Account>;

	///
	// CALLBACKS
	//

	public dynamic function onLoginStateChanged() : Void { }

	public dynamic function onAccountChanged() : Void { }


	///
	// GETTERS / SETTERS
	//

	public function set_isLoggedIn(v : Bool) : Bool {

		if (v == isLoggedIn) {

			return v;
		}
		isLoggedIn = v;

		onLoginStateChanged();

		return isLoggedIn;
	}

	public function set_account(v : Null<Account>) : Null<Account> {

		if (v == account) {

			return v;
		}
		account = v;

		onAccountChanged();

		return account;
	}
}