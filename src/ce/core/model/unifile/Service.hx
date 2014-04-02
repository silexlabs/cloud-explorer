package ce.core.model.unifile;

typedef QuotaInfo = {

	var available : Int;
	var used : Int;
}

typedef User = {

	var displayName : String;
	var quotaInfo : QuotaInfo;
}

typedef Service = {

	var name : String;
	var displayName : String;
	var imageSmall : String;
	var description : String;
	var visible : Bool;
	var isLoggedIn : Bool;
	var isConnected : Bool;
	var user : Null<User>;
}