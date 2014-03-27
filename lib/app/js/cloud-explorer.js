'use strict';

/**
 * Front-end component for the unifile node.js server
 * @see https://github.com/silexlabs/unifile
 * @author Thomas Fétiveau, http://www.tokom.fr/  &  Alexandre Hoyau, http://www.intermedia-paris.fr/
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */

/**
 * TODO
 * manage cases when moving/pasting files where other files with same name exists...
 * unselect files when clicked somewhere else ?
 * fix # anchor part in url should not appear (since angular 1.1.4)
 * create alert/error system with focus on inputs for faulty uses (like: rename file to a invalid name, ...)
 * console messages + display
 * bootstrap styling
 * move between services [need fix in unifile]
 * drag from CE to desktop
 * upload progress
 * selectable items should allow mass moving by drag n drop ?
 * download link won't propose to save file in Firefox 20 if not same origin, we could force download from server side [unifile]
 */

/**
 * TODO create a "factory", a prototype ?
 *
 * CEBlob.url
 * The most critical part of the file, the url points to where the file is stored and acts as a sort of "file path".
 * The url is what is used when making the underlying GET and POST calls to Ink when you do a filepicker.read or filepicker.write call.
 *
 * CEBlob.filename
 * The name of the file, if available
 *
 * CEBlob.mimetype
 * The mimetype of the file, if available.
 *
 * CEBlob.size
 * The size of the file in bytes, if available. We will attach this directly to the InkBlob when we have it, otherwise you can always get the size by calling filepicker.stat
 *
 * CEBlob.isWriteable
 * This flag specifies whether the underlying file is writeable. In most cases this will be true, but if a user uploads a photo from facebook,
 * for instance, the original file cannot be written to. In these cases, you should use the filepicker.exportFile call as a way to give the user the ability to save their content.
 */

////////////
// Internals
////////////

var ceInstance = null;
/**
 * out 	onSuccess
 * in 	mode
 */
var __ceInstance = {};

var ONE_FILE_SEL_MODE = 1; // select one file only
var ONE_FILE_SAVE_MODE = 2; // write or overwrite one file only
var ONE_FOLDER_SEL_MODE = 3; // select one folder only

function openCE()
{
	if (ceInstance == null)
	{
		ceInstance = document.getElementById("CE");
	}
	__ceInstance["refresh"]();
	if (ceInstance.style.display != "block")
	{
		ceInstance.style.display = "block";
	}
}
function closeCE()
{
	ceInstance.style.display = "none";
}

/**
 * TODO match method signature: pick([options], onSuccess(InkBlob){}, onError(FPError){})
 * TODO manage onError
 * TODO manage file upload
 * TODO return CEBlob
 */
function ce_pick() {

	var onSuccess;
	var onError;
	
	__ceInstance["mode"] = ONE_FILE_SEL_MODE;

	if (typeof(arguments[0]) != 'function') {

		if (arguments[0].folders === true) {

			__ceInstance["mode"] = ONE_FOLDER_SEL_MODE;
		}
		onSuccess = arguments[1];
		if (arguments.length > 2) onError = arguments[2];

	} else {

		onSuccess = arguments[0];
		if (arguments.length > 1) onError = arguments[1];
	}
	__ceInstance["onSuccess"] = function(data) {
		closeCE();
		if (onSuccess != undefined) {
			onSuccess(data);
		}
	}
	__ceInstance["onError"] = function(data) {
		closeCE();
		if (onError != undefined) {
			onError(data);
		}
	}
	__ceInstance["cancel"] = function(data) {
		closeCE();
	}
	openCE();
}
/**
 * TODO match method signature: ce_exportFile(input, [options], onSuccess, onError, onProgress)
 * When does Alex use it ? use store() first ?
 * signature: ce_exportFile(input, [options], onSuccess, onError)
 */
function ce_exportFile()
{
	if (arguments.length == 0)
	{
		throw "Incorrect number of arguments in call to exportFile. Method signature is: exportFile(input, [options], onSuccess, onError) ";
	}
	__ceInstance["mode"] = ONE_FILE_SAVE_MODE;

	if (arguments[0].mimetype == null) {

		throw "exporting folders not supported"
	}
	__ceInstance["input"] = arguments[0];

	__ceInstance["options"] = (arguments.length >=2 && typeof(arguments[1]) != 'function') ? arguments[1] : null;
	var sc = null;
	if (arguments.length >= 2 && typeof(arguments[1]) == 'function')
	{
		sc = arguments[1];
	}
	else if (arguments.length >= 3)
	{
		sc = arguments[2];
	}
	__ceInstance["onSuccess"] = function(data) {
		closeCE();
		if (sc != null)
		{
			sc(data);
		}
	}
	__ceInstance["cancel"] = function(data) {
		closeCE();
	}
	// TODO onError
	openCE();
}
/**
 * TODO ce_read(input, [options], onSuccess, onError, onProgress)
 * @param
 */
function ce_read(input, onSuccess, onError) {

	__ceInstance.read(input, onSuccess, onError);
}
/**
 * TODO match method signature: ce_write(target, data, [options], onSuccess, onError, onProgress)
 * TODO support "CEBlob, a DOM File Object, or an <input type="file"/>" as data
 *
 * @param target An CEBlob pointing to the file you'd like to write to.
 * @param data The data to write to the target file, or an object that holds the data. Can be raw data, an CEBlob, a DOM File Object, or an <input type="file"/>.
 * @param onSuccess The function to call if the write is successful. We'll return an CEBlob as a JSON object.
 */
function ce_write(target, data, onSuccess, onError) {
	__ceInstance.write(target, data, onSuccess, onError);
}


//////////////
// Exposed API
//////////////

var cloudExplorer = {};
cloudExplorer.pick = ce_pick;
cloudExplorer.exportFile = ce_exportFile;
cloudExplorer.read = ce_read;
cloudExplorer.write = ce_write;


////////
// UTILS
////////

function getExtByMimeType( mt )
{

	switch (mt.toLowerCase())
	{
		case 'image/png':
			return 'png';
		case 'image/jpeg':
			return 'jpg';
		case 'text/html':
			return 'html';
		default:
			throw 'Unknown MIME Type: '+mt;
	}
}
function getMimeByExt( ext )
{

	switch ( ext.toLowerCase() )
	{
		case 'png':
			return 'image/png';
		case 'jpg':
			return 'image/jpeg';
		case 'html':
			return 'text/html';
		default:
			return null;
	}
}
/* MD lexoyo, use this to have an absolute path to the server
function getBase() {

	return window.location.origin.replace(':', '\\:') +'/';
}
*/
/////////////////////////
// AngularJS CE component
/////////////////////////

/* Config */
angular.module('ceConf', [])

	.constant( 'server.url', '../api/v1.0/' )
	//.constant( 'server.url', 'http://unifile.silexlabs.org/api/v1.0/' )

	.constant( 'server.url.unescaped', '../api/v1.0/' ) // Need to get rid of this as soon as we use an angular version that is not buggy on this
	//.constant( 'server.url.unescaped', 'http://unifile.silexlabs.org/api/v1.0/' ) // Need to get rid of this as soon as we use an angular version that is not buggy on this

	.constant( 'console.level', 0 ) // 0: DEBUG, 1: INFO, 2: WARNING, 3: ERROR, 4: NOTHING (no console)

	.config(['$httpProvider', function($httpProvider)
	{
		delete $httpProvider.defaults.headers.common["X-Requested-With"];
		$httpProvider.defaults.useXDomain = true;
		$httpProvider.defaults.withCredentials = true;
	}]);


/* Services */
angular.module('ceServices', ['ngResource', 'ceConf'])

	.factory('$ceConsoleSrv', [ '$rootScope', 'console.level', function( $rootScope, level )
	{
		return {
			"log": function( msg, l ) { if ( l >= level ) $rootScope.$emit("log", msg, l); }
		};
	}])

	.factory('$unifileStub', ['$resource', 'server.url', function( $resource, serverUrl )
	{
		//return $resource(CEConfig.serverUrl+':service/:method/:command/?:path/', {}, {  // workaround: "?" is to keep a "/" at the end of the URL
		return $resource( serverUrl + ':service/:method/:command/:path ', {},
			{  // *very ugly* FIXME added space to keep the '/' at the end of the url
				listServices: {method:'GET', params:{service:'services', method:'list'}, isArray:true},
				connect: {method:'GET', params:{method:'connect'}, isArray:false},
				login: {method:'GET', params:{method:'login'}, isArray:false},
				logout: {method:'GET', params:{method:'logout'}, isArray:false},
				ls: {method:'GET', params:{method:'exec', command:'ls'}, isArray:true},
				rm: {method:'GET', params:{method:'exec', command:'rm'}, isArray:false},
				mkdir: {method:'GET', params:{method:'exec', command:'mkdir'}, isArray:false},
				cp: {method:'GET', params:{method:'exec', command:'cp'}, isArray:false},
				mv: {method:'GET', params:{method:'exec', command:'mv'}, isArray:false},
				get: {method:'GET', params:{method:'exec', command:'get'}, isArray:false} // FIXME buggy
			});
	}])

	.factory('$ceUtils', [ 'server.url.unescaped', function(serverUrl)
	{
		function urlToPath(url) {
			if (url.indexOf(serverUrl) != 0)
			{
				console.error("ERROR: can't convert url to path: "+url);
				return null;
			}
			var parsedUrl = url.substr(serverUrl.length);
			if (parsedUrl.indexOf("/exec/get/") != parsedUrl.indexOf("/"))
			{
				console.error("ERROR: can't convert url to path: "+url);
				return null;
			}
			var srv = parsedUrl.substr(0, parsedUrl.indexOf("/"));
			parsedUrl = parsedUrl.substr(parsedUrl.indexOf("/exec/get/")+"/exec/get/".length);

			var filename = "";
			var path = "";
			if (parsedUrl.lastIndexOf('/') > -1)
			{
				filename = parsedUrl.substr(parsedUrl.lastIndexOf('/')+1);
				path = parsedUrl.substr(0, parsedUrl.lastIndexOf('/')+1);
			}
			else
			{
				filename = parsedUrl;
			}
			return { 'srv':srv, 'path':path, 'filename': filename };
		}
		function pathToUrl(path) {
			if ( path.srv === undefined || path.path === undefined || path.filename === undefined )
			{
				console.error("ERROR: can't convert path to url: "+JSON.stringify(path));
				return null;
			}
			var ret = serverUrl+path.srv+"/exec/get/"+path.path;
			if (path.path.length > 0)
			{
				ret += '/';
			}
			ret += path.filename;
			return ret;
		}
		return {
			urlToPath: urlToPath,
			pathToUrl: pathToUrl
		}
	}])

	.factory('$unifileSrv', ['$unifileStub', '$http', 'server.url.unescaped', function($unifileStub, $http, serverUrl)
	{
		// array of available services from unifile
		var services = [];
		// the current navigation data
		var currentNav = { "path": null, "files": [], "srv": null }; //;
		// the clipboard var used for copy/paste
		var clipboard = { "mode":0, "path":"", "files":[] }; // mode=0 => copy, mode=1 => cut
		// account data by service
		var account = {};

		function listServices()
		{
			if (services.length == 0)
			{
				$unifileStub.listServices({}, function(list){
					for (var i in list)
					{
						services .push(list[i]);
					}
				});
			}
			return services;
		}
		function isConnected(srvName)
		{
			for (var si in services)
			{
				if (services[si]["name"] == srvName || srvName == undefined)
				{
					if (services[si].hasOwnProperty("isLoggedIn") && services[si]["isLoggedIn"]===true)
					{
						return true;
					}
					if (srvName != undefined)
					{
						return false;
					}
				}
			}
			return false;
		}
		function logout()
		{
			for (var si = 0; si < services.length; si++)
			{
				if (services[si]["isLoggedIn"])
				{
					(function(srv) {
						$unifileStub.logout({service:srv["name"]}, function (status)
							{
								srv["isLoggedIn"] = false;

							});
					})(services[si]);
				}
			}
			currentNav = { "path": null, "files": [], "srv": null }; //;
		}
		function login(srvName)
		{
			for (var si = 0; si < services.length; si++) // FIXME angular 1.1.3 doesn't accept both filter and associative arrays in ng-repeat. As soon as it does, optimize it to make services an associative array
			{
				if (services[si]["name"]!=srvName)
				{
					continue;
				}
				if (!services[si]["isLoggedIn"])
				{
					var res = $unifileStub.login({service:srvName}, function (status)
						{

							if (res.success == true)
							{
								services[si]["isLoggedIn"] = true;

								if ( currentNav.path == undefined )
								{
									// if tree empty we set current dir
									cd(services[si]['name'], "");
								}
							}
							else
							{
								services[si]["isLoggedIn"] = false;
								console.error('Could not login. Please retry.');
							}
						},
						function (obj) // FIXME
						{
							console.error('Could not login. Try connect first, then follow the auth URL and try login again.');
							console.error(obj.data); // FIXME
							console.error(obj.status); // FIXME
							services[si]["isConnected"] = false;
							services[si]["isLoggedIn"] = false;
						});
				}
				return;
			}
		}
		function cd(srvName, path) {

			if (account[srvName] == undefined)
			{
				getAccount(srvName);
			}
			$unifileStub.ls({service:srvName, path:path}, function (res)
				{

					//currentNav = { "srv": srvName, "path": path, "files": res };
					currentNav["srv"] = srvName;
					currentNav["path"] = path;
					currentNav["files"] = res;
				},
				function(obj)
				{
					console.error('Error while calling ls');
					console.error(obj.data); // FIXME
					console.error(obj.status); // FIXME
				});
		}
		//$unifileSrv.mv($scope.fileSrv, evData.path, $scope.filePath, evData.files);
		function mv(oldSrv, newSrv, oldPath, newPath, files) { // FIXME manage errors
			if (oldPath!='' && oldPath[oldPath.length-1]!='/')
			{
				oldPath+='/';
			}
			if (newPath!='' && newPath[newPath.length-1]!='/')
			{
				newPath+='/';
			}
			for (var fi in files)
			{
				(function(file)
				{
					$unifileStub.mv({service:newSrv, path:oldPath+file.name+':'+newPath+file.name}, function()		// FIXME unifile should manage mv between srvs
					{
						var op = oldPath.substring(0, oldPath.lastIndexOf('/'));

						var np = newPath.substring(0, newPath.lastIndexOf('/'));


						if (op == currentNav["path"])
						{
							for(var i in currentNav['files'])
							{
								if (currentNav['files'][i]['name']===file.name) {
									currentNav['files'].splice(i, 1);
									break;
								}
							}
						}
						if (np == currentNav["path"])
						{
							currentNav['files'].push(file);
						}
					}, function()
					{
						/* TODO */
						console.error("ERROR after mv");
					});
				})(files[fi]);
			}
		}
		function getAccount(srv)
		{
			if (srv == undefined)
			{
				for (var si in services )
				{
					if ( services[si]["isLoggedIn"] )
					{
						srv = services[si]['name'];
						break;
					}
				}
			}

			if (account[srv] == undefined && srv != undefined)
			{
				return $http({
					method: 'POST',
					url: serverUrl+srv+'/account/',
					headers: {'Content-Type': undefined},
					transformRequest: angular.identity
				})
				.success(function(data, status) {
					account[srv] = data;

				});
			}

		}
		function setClipboardContent(mode) {
			clipboard["mode"] = mode;
			clipboard["files"] = [];
			var rp = '';
			if (currentNav["path"]!='' && currentNav["path"]!=undefined)
			{
				rp = currentNav["path"] + '/';
			}
			clipboard["path"] = rp;
			for(var fi in currentNav['files'])
			{
				if (currentNav['files'][fi]['isSelected']===true) {
					clipboard["files"].push(currentNav['files'][fi]);
				}
			}
		}
		function remove(file) { // FIXME manage errors
			/*for(var fi in currentNav.files)
			{
				var cf = currentNav.files[fi];
				if (cf.isSelected===true)
				{*/
					var fp = currentNav.path;
					if (fp != '')
					{
						fp += '/';
					}
					fp += file.name;
					console.warn("calling rm with file.name= "+file.name);
					(function(file) {
						$unifileStub.rm({service:currentNav.srv, path:fp}, function() {
							for(var fir in currentNav.files)
							{
								if (currentNav.files[fir] == file)
								{
									var temp = currentNav.files.splice(fir,1);

									return;
								}
							}
						});
					})(file);
			/*	}
			}*/
		}
		function paste() { // FIXME manage errors
			if (clipboard["files"].length == 0 || currentNav["path"]==clipboard["path"])
			{
				return;
			}
			var rp = '';
			if (currentNav["path"]!='' && currentNav["path"]!=undefined)
			{
				rp = currentNav["path"] + '/';
			}
			for (var fi in clipboard["files"])
			{
				(function(file){
					var nfp = rp + file['name'];

					if (clipboard["mode"]==0)
					{
						$unifileStub.cp({service:currentNav["srv"], path:clipboard["path"]+file.name+':'+nfp}, function() {

							file.isSelected = false;
							currentNav["files"].push(file); // paste happens always in current directory
						});
					}
					else
					{
						$unifileStub.mv({service:currentNav["srv"], path:clipboard["path"]+file.name+':'+nfp}, function() {

							file.isSelected = false;
							currentNav["files"].push(file); // paste happens always in current directory
						});
					}
				})(clipboard["files"][fi]);
			}
			if (clipboard["mode"]==1) // clear clipboard if cut mode
			{
				clipboard["mode"]=0;
				clipboard["files"]=[];
			}
		}
		function isCorrectFileName(name)
		{
			if (name === undefined || name == "")
			{
				return false;
			}
			//TODO other checks on characters used...
			return true;
		}
		function mkdir(mkdirName)
		{ // FIXME manage errors
			var rp = currentNav.path;
			if (rp != '')
			{
				rp += '/';
			}
			$unifileStub.mkdir({service:currentNav.srv, path:rp+mkdirName}, function () {

					currentNav.files.push({ 'name': mkdirName, 'is_dir': true }); // FIXME see if unifile couldn't send back the file json object
				});
		}
		function togleSelect(file)
		{

			for(var fi in currentNav.files)
			{
				if (currentNav.files[fi] == file)
				{
					if (currentNav.files[fi]["isSelected"])
					{
						currentNav.files[fi]["isSelected"] = !currentNav.files[fi]["isSelected"];
					}
					else
					{
						currentNav.files[fi]["isSelected"] = true;
					}
					currentNav.files[fi]["lastSelectionDate"] = Date.now();

					if (!__ceInstance)
					{
						return;
					}
				}
				//else if (__ceInstance && __ceInstance["mode"]===ONE_FILE_SEL_MODE)
				else if (__ceInstance)
				{
					currentNav.files[fi]["isSelected"] = false;
				}
			}
		}
		function upload(uploadFiles, path, onSuccess, onError)
		{
			//enforce path as a folder path
			if (path != "" && path.lastIndexOf('/') != path.length-1) // TODO check in unifile if it's not a bug
			{
				path += '/';
			}
			var formData = new FormData();
			var fn = [];
			for(var i in uploadFiles)
			{
				if(typeof uploadFiles[i] == 'object') // raw data from drop event or input[type=file] contains methods we need to filter
				{
					formData.append('data', uploadFiles[i], uploadFiles[i].name);
					fn.push({ "name": uploadFiles[i].name });
				}
			}
			if (fn.length == 1) // FIXME this is a temporary workaround for following issue on FF: https://bugzilla.mozilla.org/show_bug.cgi?id=690659
			{
				path += fn[0].name;
			}
			return $http({
					method: 'POST',
					url: serverUrl+currentNav.srv+'/exec/put/'+path, // FIXME address as config value, srv as param
					data: formData,
					headers: {'Content-Type': undefined},
					transformRequest: angular.identity
				})
				.success(function(data, status, headers, config) {
					var p = path;
					var cp = currentNav.path;
					if (fn.length == 1) {
						if (p.indexOf('/')==-1) {
							p = '';
						} else {
							p = p.substring(0, p.lastIndexOf('/'));
						}
					} else {
						cp += '/';
					}
					if ( p == cp ) // FIXME that's ugly, check if we cannot do better
					{
						for (var i in fn)
						{
							var fe = false;
							for (var y in currentNav.files) {
								if (currentNav.files[y]['name'] == fn[i].name) {
									fe = true;
									break;
								}
							}
							if ( !fe ) {
								currentNav.files.push({ 'name': fn[i].name, 'is_dir': false }); // FIXME see if unifile couldn't send back the file json objects
							}
						}
					}

					if (onSuccess != undefined) {
						onSuccess();
					}
				})
				.error(function(data, status, headers, config) {
				    if (onError != undefined) {
				    	onError(data);
				    }
				});
		}
		function get(srv, path, onSuccess, onError)
		{

			$http({
					method: 'GET',
					url: serverUrl+srv+'/exec/get/'+path, // FIXME address as config value, srv as param
					transformRequest: angular.identity
				})
				.success(function(data, status, headers, config) {

					if (onSuccess != undefined) {
						onSuccess(data);
					}
				})
				.error(function(data, status, headers, config) {
				    if (onError != undefined) {
				    	onError(data);
				    }
				});
		}
		return {
			services: function() { return services; },
			isConnected: isConnected,
			currentNav: function() { return currentNav; },
			clipboard: function() { return clipboard; },
			listServices: listServices,
			login: login,
			logout: logout,
			cd: cd,
			mv: mv,
			setClipboardContent: setClipboardContent,
			remove: remove,
			paste: paste,
			mkdir:mkdir,
			isCorrectFileName: isCorrectFileName,
			togleSelect: togleSelect,
			upload: upload,
			get: get,
			getAccount: getAccount,
			account: function() { return account; }
		};
	}]);


/* Controllers */
angular.module('ceCtrls', ['ceServices'])
	.filter("typeFile", function() {
    	return function(filename, uppercase) {
    		return filename.split(".")[1]
    	}
    })
	.filter("customDate", function() {
    	return function(date, uppercase) {
    		return new Date(date).toLocaleDateString()
    	}
    })
	/**
	 * Sets some exposed functions to the outside world
	 */
	.controller('CEBrowserCtrl', ['$scope', '$rootScope', '$unifileSrv', '$unifileStub', '$ceUtils', '$window', function($scope, $rootScope, $unifileSrv, $unifileStub, $ceUtils, $window)
		{
			var displayName = "";
			$scope.authPopup = { show: false, srvName: '', url: '' };

			$scope.popupBlocked = { val: false };
			$scope.isPopupBlocked = function() {
				return $scope.popupBlocked.val;
			}
			$scope.$watch( $unifileSrv.account, accountChanged, true );

			$scope.getDisplayName = function() {

				return displayName;
			}
			function accountChanged(account)
			{
				for (var s in account)
				{
					if (account[s]["display_name"] != undefined)
					{
						displayName = account[s]["display_name"];
					}
				}
			}

			if (__ceInstance)
			{

				__ceInstance["read"] = function(input, onSuccess, onError) {
					var path = $ceUtils.urlToPath(input.url);


					$scope.$apply( function($scope){
						$unifileSrv.get(path.srv, path.path+path.filename, function (data) {

							if (onSuccess != undefined) {
								onSuccess(data);
							}
						}, function(error) {
							console.error("onError error= "+JSON.stringify(error));
							if (onError != undefined) {
								onError(error);
							}
						});
					});
				};
				__ceInstance["write"] = function(target, data, onSuccess, onError) {
					var path = $ceUtils.urlToPath(target.url);
					var fileContent = [data];
					var fileBlob = new Blob(fileContent, { "type" : target.mimetype });
					fileBlob["name"] = path.filename;

					$scope.$apply( function($scope){
						$unifileSrv.upload( [fileBlob], path.path, function() {
							if (onSuccess != undefined) {
								onSuccess(target);
							}
						}, function(error) {
							console.error("onError error= "+JSON.stringify(error));
							if (onError != undefined) {
								onError(error);
							}
						});
					});
				};
				__ceInstance["refresh"] = function() {

					$rootScope.$digest();
				}
			}
			else
			{

			}
			$scope.abort = function() {
				__ceInstance["cancel"]();
			};
			$scope.logout = function() {
				$unifileSrv.logout();
				__ceInstance["cancel"]();
			};

			/**
			 * Opens the application authorization popup for the given service
			 */
			$scope.authorize = function()/*url, serviceName*/
			{
				var authPopup = $window.open( $scope.authPopup.url, 'authPopup', 'height=829,width=1035,dialog'); // FIXME parameterize size? per service ?
				if (!authPopup || authPopup.closed || typeof authPopup.closed=='undefined') {
					$scope.popupBlocked.val = true;
					return;
				}
				$scope.popupBlocked.val = false;
				if ($window.focus) { authPopup.focus() }
				if (authPopup)
				{
					// timer based solution until we find something better to listen to the child window events (close, url change...)
					var timer = setInterval(function()
						{
							if (authPopup.closed)
							{
								clearInterval(timer);
								$scope.$apply( function($scope){$unifileSrv.login($scope.authPopup.srvName);} );
								$scope.authPopup.show = false;
							}
						}, 500);
				}
				else
				{
					console.error('ERROR: Authorization popup could not be opened');
				}
			}
		}
	])


	/**
	 * Controls the browser left pane
	 */
	.controller('CELeftPaneCtrl', ['$scope', '$unifileSrv', '$unifileStub', function($scope, $unifileSrv, $unifileStub)
		{
			// the services folder tree
			$scope.srvList = [];

			// scope contains the service + folders tree and need to be able to enable/disable a branch (service) id its isConnected flag changes
			function servicesChanged(services)
			{
				$scope.srvList = [];
				for (var i in services) {
					if (services[i] != null && services[i].hasOwnProperty('display_name')) {
						$scope.srvList.push(services[i]);
					}
				}
			}
			$scope.$watch( $unifileSrv.services, servicesChanged, true);

			// Initiate the list of services (should it be somewhere else ?)
			$unifileSrv.listServices();
		}])

	/**
	 * Controls the browser right pane
	 */
	.controller('CERightPaneCtrl', ['$scope', '$unifileSrv', '$ceUtils', function($scope, $unifileSrv, $ceUtils)
		{
			// scope contains the current path, the list of folders and files in the current path
			$scope.$watch( $unifileSrv.currentNav, currentNavChanged, true);

			$scope.isConnected = function ()
			{

				return ($scope.srv != null);
			}

			/**
			 *
			 */
			$scope.hideSelectBtn = function()
			{
				if (__ceInstance && (__ceInstance["mode"] === ONE_FILE_SEL_MODE || __ceInstance["mode"] === ONE_FILE_SAVE_MODE))
				{
					for(var fi in $scope.files)
					{
						if ($scope.files[fi].isSelected===true)
						{
							return $scope.files[fi].is_dir;
						}
					}
				}
				return true;
			}
			$scope.hideSaveAsBtn = function()
			{

				if (__ceInstance && __ceInstance["mode"] === ONE_FILE_SAVE_MODE)
				{
					return false;
				}
				return true;
			}
			$scope.hideUploadBtn = function()
			{
				if (!__ceInstance || (__ceInstance && __ceInstance["mode"] === ONE_FILE_SEL_MODE))
				{
					return false;
				}
				return true;
			}
			/**
			 *
			 */
			function currentNavChanged(currNav)
			{

				if (currNav.path!==undefined)
				{

					$scope.path = currNav.path;
					$scope.srv = currNav.srv;
					$scope.files = currNav.files;
					$scope.isEmptySelection = true;
					for(var fi in $scope.files)
					{
						if ($scope.files[fi].isSelected===true)
						{
							$scope.isEmptySelection = false;
							break;
						}
					}
				}
				else
				{
					$scope.path = null;
					$scope.srv = null;
					$scope.files = [];
				}
			}
			$scope.isCtrlBtnsVisible = function() {
				return ($unifileSrv.currentNav().path !== undefined);
			}
			$scope.showLinkToParent = function()
			{
				if ( $scope.path == undefined || $scope.path == '' || $scope.path == '/' )
				{
					return false;
				}
				return true;
			};

			$scope.breadCrumb = [];
			$scope.currentDir = undefined;
			$scope.enterDirBreadCrumb = function(path)
			{
				$scope.removeAllChecked();
				if (!$unifileSrv.isConnected($scope.fileSrv))
				{
					connect($scope.fileSrv);
				}
				else if ($scope.file != null && $scope.file.is_dir || $scope.file == null)
				{
					$unifileSrv.cd($scope.srv, path);
				}
			};
			/*
			*	When the path change, the breacrumb is updated
			*/
			$scope.setBreadCrumbLink = function()
			{
				$scope.$watch('path', function() 
				{
					$scope.breadCrumb.length = 0;
					var tabPath = $scope.path.split("/");
					for (var i = 0; i < tabPath.length; i++) 
					{
						var link = {
							name:"",
							path:"",
							sep:"/"
						};
						link.name = tabPath[i];
						link.path = "";
						for (var j = 0; j <= i; j++) 
						{
							link.path += tabPath[j]+"/";
						}
						link.path = link.path.substr(0, link.path.lastIndexOf('/'));
						if(i>0) link.sep = " / ";
						$scope.breadCrumb.push(link);
					}
					$scope.currentDir = $scope.breadCrumb[$scope.breadCrumb.length-1].name || $scope.srv;
				});
			};
			$scope.showBreadCrumbLink = function(){
				if ( $scope.path == undefined || $scope.path == '' || $scope.path == '/' )
				{
					return false;
				}
				return true;
			};

			$scope.checked = [];
			$scope.checkedFile = [];
			/*
			*	update the list of files selected
			*/
			$scope.checkIt = function(name, file)
			{
				var indexOf = $scope.checked.indexOf(name);
				if(indexOf == -1)
				{
					$scope.checked.push(name)
					$scope.checkedFile[name] = file;
				}else
				{
					$scope.checked.splice(indexOf, 1);
					delete $scope.checkedFile[name];
				}
			}
			$scope.showCheckedOption = function()
			{
				if($scope.checked.length > 0)
				{
					return true;
				}
				return false;
			};
			/*
			*	Remove all selected files
			* 	TODO => confirmation popin ?
			*/
			$scope.removeAllChecked = function()
			{
				for (var fileName in $scope.checkedFile)
				{
					$unifileSrv.remove($scope.checkedFile[fileName]);
					delete $scope.checkedFile[fileName];
				};
				$scope.checked.length = 0;
				$scope.showCheckedOption()
			}
			$scope.resetSelected = function()
			{
				for (var fileName in $scope.checkedFile)
				{
					delete $scope.checkedFile[fileName];
				};
				$scope.checked.length = 0;
			}
			
			/**
			 * mkdir command
			 */
			$scope.doMkdir = function(mkdirName)
			{

				if (!$unifileSrv.isCorrectFileName(mkdirName))
				{
					console.error("WARNING: name given for new directory is not valid: "+mkdirName);
					//TODO show this either in console or through a new alert service
				}
				else
				{

					$unifileSrv.mkdir(mkdirName);
					$scope.mkdirOn = false; // FIXME, should be set to false when server response received
				}
			}
			$scope.isEmptyClipboard = function() {
				return ($unifileSrv.clipboard()["files"].length === 0);
			}
			/*$scope.remove = function() {
				$unifileSrv.remove();
			}*/
			/*$scope.copy = function()
			{
				$unifileSrv.setClipboardContent(0);
			};
			$scope.cut = function()
			{
				$unifileSrv.setClipboardContent(1);
			};
			$scope.paste = function()
			{
				$unifileSrv.paste();
			};*/
			/*$scope.chose = function()
			{
				for(var fi in $scope.files)
				{
					if ($scope.files[fi].isSelected===true)
					{
						__ceInstance.onSuccess({
													'url': $ceUtils.pathToUrl({'srv':$scope.srv, 'path':$scope.path, 'filename':$scope.files[fi].name}),
													'filename': $scope.files[fi].name,
													'mimetype': ($scope.files[fi].name.indexOf('.') > -1) ? getMimeByExt($scope.files[fi].name.substring($scope.files[fi].name.lastIndexOf('.')+1)) : null
												}); // FIXME other CEBlob fields
						break;
					}
				}
			};*/
			$scope.ext = null;
			$scope.$watch( function(){ return __ceInstance }, refreshExtension, true);
			function refreshExtension()
			{
				$scope.ext = null;
				( __ceInstance['options'] != null && __ceInstance['options']['mimetype'] != null)  ? $scope.ext = getExtByMimeType( __ceInstance['options']['mimetype'] ) : $scope.ext = null;
				if ($scope.ext == null)
				{
					if ( __ceInstance['input'] != null && __ceInstance['input']['mimetype'] != null )
					{
						$scope.ext = getExtByMimeType( __ceInstance['input']['mimetype'] );
					}
				}

			}
			$scope.saveAs = function(fileName)
			{
				if ($scope.ext == null)
				{
					throw "Can't save file with no mimetype set !";
				}
				// TODO create file ?
				__ceInstance.onSuccess({ 'url': $ceUtils.pathToUrl({'srv':$scope.srv, 'path':$scope.path, 'filename':fileName+"."+$scope.ext }) }); // FIXME other CEBlob fields
			};
		}])

	/**
	 * This controller is shared by the ceFile and ceFolder directives.
	 */
	.controller('CEFileEntryCtrl', ['$scope', '$element', '$unifileSrv', '$unifileStub', 'server.url.unescaped', '$q', '$ceUtils', function($scope, $element, $unifileSrv, $unifileStub, serverUrl, $q, $ceUtils)
		{
			function getFilePath() {
				var fp = $scope.path;

				if ($scope.file != null)
				{
					if (fp != '')
					{
						fp += '/';
					}
					fp += $scope.file.name;
				}
				return fp;
			}
			$scope.filePath = getFilePath();

			$scope.fileSrv = $scope.srv;

			$scope.renameOn = false;

			$scope.selectDirOn = (__ceInstance["mode"] === ONE_FOLDER_SEL_MODE);

			// can be dir, file or both
			$scope.isFile = false;
			$scope.isDir = false;

			/**
			 * TODO comment
			 */
			$scope.setLinkToParent = function()
			{
				$scope.$watch('path', function() {
					if ( $scope.path != undefined && $scope.path != '' && $scope.path != '/' )
					{
						var p = $scope.path;
						if (p.lastIndexOf('/') == p.length-1) p = p.substr(0, p.length-1);
						$scope.filePath = p.substr(0, p.lastIndexOf('/'));
					}
				});
			};

			/**
			 * Connect to service
			 */
			function connect(srvName)
			{
				if (!$unifileSrv.isConnected(srvName))
				{
					$q.when(srvName)
					.then( function(sn) {
						var deferred = $q.defer();
						$unifileStub.connect({service:sn},
							function (resp) {
								deferred.resolve(resp);
							}
						);
						return deferred.promise;
					})
					.then(function(cr) {

						//authorize(cr.authorize_url, srvName);
						$scope.authPopup.url = cr.authorize_url;
						$scope.authPopup.srvName = srvName;
						$scope.authPopup.show = true;
					});
				}
				else
				{
					console.warn("Already connected to "+srvName);
				}
			};
			/**
			 * TODO comment
			 */
			$scope.enterDir = function()
			{
				$scope.resetSelected();
				if (!$unifileSrv.isConnected($scope.fileSrv))
				{

					connect($scope.fileSrv);
				}
				else if ($scope.file != null && $scope.file.is_dir || $scope.file == null)
				{
					$unifileSrv.cd($scope.fileSrv, $scope.filePath);
				}
			};
			$scope.select = function()
			{

				console.log("select "+$scope.file.name),
				/*
				var lastSel = $scope.file["lastSelectionDate"];*/
				//$unifileSrv.togleSelect($scope.file);
				/*if (lastSel)
				{
					var diff = ($scope.file["lastSelectionDate"] - lastSel);
					if (diff < 2000 && diff > 500) // FIXME those values should be config constants
					{
						$scope.rename("");
					}
				}*/
				__ceInstance.onSuccess({
						'url': $ceUtils.pathToUrl({'srv':$scope.srv, 'path':$scope.path, 'filename':$scope.file.name}),
						'filename': $scope.file.name,
						'mimetype': (!$scope.file.isDir && $scope.file.name.indexOf('.') > -1) ? getMimeByExt($scope.file.name.substring($scope.file.name.lastIndexOf('.')+1)) : null
					}); // FIXME other CEBlob fields
			};

			/**
			 * TODO comment
			 */
			$scope.handleDragStart = function(e)
			{
				e.originalEvent.dataTransfer.effectAllowed = 'move';
				//e.originalEvent.dataTransfer.setData('text', $scope.filePath);
				e.originalEvent.dataTransfer.setData('text', '{ "srv": "'+$scope.fileSrv+'", "path": "'+$scope.path+'", "files": ['+JSON.stringify($scope.file)+'] }' );

				$element.addClass("ce-file-drag"); // FIXME make it a param in conf?
			};
			/**
			 * TODO comment
			 */
			$scope.handleDragEnd = function(e)
			{
				$element.removeClass("ce-file-drag"); // FIXME make it a param in conf?
			};

			/**
			 * TODO comment
			 */
			$scope.getClass = function()
			{
				var fic = [];
				if ($scope.file != null && $scope.file.isSelected === true)
				{
					fic.push("ce-file-selected");
				}
				if ($scope.file != null && !$scope.file.is_dir)
				{
					fic.push("is-dir-false");
				}
				else
				{
					fic.push("is-dir-true");
				}
				return fic.join(" ");
			};

			/**
			 * TODO comment
			 */
			$scope.handleDragEnter = function(e) // TODO manage styles
			{
				e.preventDefault();

				$element.addClass("ce-folder-over"); // FIXME make it a param in conf?
			};
			/**
			 * TODO comment
			 */
			$scope.handleDragLeave = function(e) // TODO manage styles
			{

				$element.removeClass("ce-folder-over"); // FIXME make it a param in conf?
			};
			/**
			 * TODO comment
			 */
			$scope.handleDragOver = function(e)
			{
				if ( e.preventDefault )
				{
					e.preventDefault(); // Necessary. Allows us to drop.
				}
				e.originalEvent.dataTransfer.dropEffect = 'move';  // See the section on the DataTransfer object.

				return false;
			};
			/**
			 * TODO comment
			 */
			$scope.handleDrop = function(e)
			{

				e.stopPropagation();
				e.preventDefault();

				if ( e.originalEvent.dataTransfer.files && e.originalEvent.dataTransfer.files.length > 0 ) // case files from desktop
				{


					$unifileSrv.upload( e.originalEvent.dataTransfer.files, $scope.filePath );
				}
				else // move case
				{

					var evData = JSON.parse(e.originalEvent.dataTransfer.getData('text'));

					for (var i in evData.files)
					{
						if ( evData.path != '' && $scope.filePath == evData.path+'/'+evData.files[i].name ||
							evData.path == '' && $scope.filePath == evData.files[i].name )
						{
							console.error("WARNING: cannot move a folder into itself!");
							return; // FIXME could it be cleaner ?
						}
					}

					$unifileSrv.mv(evData.srv, $scope.fileSrv, evData.path, $scope.filePath, evData.files);
				}
			};
			/**
			 * TODO comment
			 */
			$scope.download = function()
			{
				return serverUrl+$scope.fileSrv+'/exec/get/'+$scope.filePath; // FIXME make it a conf param
			};
			/**
			 * TODO comment
			 */
			$scope.rename = function(newName)
			{
				if (!$scope.renameOn)
				{

					$scope.renameOn = true;
				}
				else
				{

					if (!$unifileSrv.isCorrectFileName(newName))
					{
						console.error("WARNING: won't rename, incorrect file/folder name given: "+newName);
						// TODO show error somewhere in console or through a new alert service
					}
					else
					{
						var newPath = $scope.filePath.substr(0, $scope.filePath.lastIndexOf('/') + 1) + newName;

						// FIXME
						$unifileStub.mv({service: $scope.fileSrv, path: $scope.filePath + ':' + newPath}, function()
							{
								$scope.filePath = newPath;
								$scope.file.name = newName;
								$scope.renameOn = false;
							});
					}
				}
			};
			$scope.remove = function() {
				// console.log($scope.file);
				$unifileSrv.remove($scope.file);
			};
		}
	])

	.controller('CEConsoleCtrl', [ '$scope', '$element', function( $scope, $element )
	{
		function onLogEntry( event, msg, l )
		{
			event.stopPropagation();
			$element.append("<li>"+l+": "+msg+"</li>"); // FIXME see if we can use some kind of template here...
		}
		$scope.$on("log", onLogEntry);
	}]);

/* Directives */
angular.module('ceDirectives', [ 'ceConf', 'ceServices', 'ceCtrls' ])

	.directive('fileUploader', function()
	{
		return {
			restrict: 'C',
			transclude: true,
			template: '<div><input type="file" multiple /><button ng-click="upload()">Select your file(s) to upload</button></div>',
			replace: true,
			controller: function($scope, $unifileSrv)
			{
				$scope.push = function(e)
				{
					$unifileSrv.upload(e.target.files, $scope.path);
				}
			},
			link: function($scope, $element)
			{
				var fileInput = $element.find('input');

				$scope.upload = function() { fileInput.trigger('click'); };


				fileInput.bind('change', function(e) { $scope.$apply(function($scope){$scope.push(e);}); } );
			}
		};
	})

	// the rename item form
	// FIXME merge with ceMkdir ? Or should this be a directive at all ?
	.directive('ceRename', function()
	{
		return {
			restrict: 'C',
			template: '<form ng-submit=\"rename(newName)\"><input type=\"text\" ng-model=\"newName\" ng-init=\"newName=file.name\" /></form>',
			link: function($scope, $element)
			{
				var i = $element.find('input');
				i.bind('focusout', function(e) { $scope.$parent.$apply(function(scope){ scope.renameOn = false; }); } ); // maybe rootScope instead of parentScope would be safer here
				i.focus();
			}
		};
	})

	// the "new folder" button
	// FIXME merge with ceRename ? Or should this be a directive at all ?
	.directive('ceMkdir', function()
	{
		return {
			restrict: 'C',
			template: '<div class=\"is-dir-true \"><form ng-submit=\"doMkdir(mkdirName)\"><input type=\"text\" ng-model=\"mkdirName\" /></form></div>',
			link: function($scope, $element)
			{
				var i = $element.find('input');
				i.bind('focusout', function(e) { $scope.$parent.$apply(function(scope){ scope.mkdirOn = false; }); } ); // maybe rootScope instead of parentScope would be safer here
				i.focus();
			}
		};
	})

	// the "new folder" button
	.directive('ceMkdirBtn', function()
	{
		return {
			restrict: 'C',
			template: '<button ng-click="mkdir()"><i class="icon-add_folder"></i> New folder</button>',
			replace: 'true',
			controller: function($scope)
			{
				$scope.mkdir = function()
				{
					$scope.mkdirOn = true;
				}
			}
		};
	})

	// this is the CE browser log console
	.directive('ceConsole', function()
	{
		return {
			restrict: 'A',
			replace: true,
			template: '<ul class="ce-log-console"></ul>',
			controller: 'CEConsoleCtrl'
		};
	})

	// this directive implements the behavior of receiving a file/folder on drop
	.directive('ceItem', function()
	{
		return {
			restrict: 'C',
			controller: 'CEFileEntryCtrl'
		};
	})

	// this directive implements the behavior of receiving a file/folder on drop
	.directive('ceFolder', function()
	{
		return {
			priority: 1,
			restrict: 'C',
			link: function(scope, element, attrs)
			{
				scope.isDir = true;
				attrs.$set('dropzone', 'move');
				attrs.$set('draggable', 'false'); // necessary to avoid folders that aren't files to be draggable

				//element.bind('dblclick', scope.enterDir ); // not set with ng-click 'cause we need to be able to unbind it at some points (renaming, ...)
				//element.bind('dblclick', function(e) { scope.$apply(function(scope){scope.enterDir(e);}); } ); // not set with ng-click 'cause we need to be able to unbind it at some points (renaming, ...)
				element.bind('dragenter', function(e) { scope.$apply(function(scope){scope.handleDragEnter(e);}); } );
				element.bind('dragleave', function(e) { scope.$apply(function(scope){scope.handleDragLeave(e);}); } );
				element.bind('dragover', function(e) { scope.$apply(function(scope){scope.handleDragOver(e);}); } );
				element.bind('drop', function(e) { scope.$apply(function(scope){scope.handleDrop(e);}); } );
			}
		};
	})

	// this directive implements the behavior of mooving a file on drag
	.directive('ceFile', function()
	{
		return {
			restrict: 'C',
			link: function(scope, element, attrs)
			{
				scope.isFile = true;
				attrs.$set('draggable', 'true');

				//element.bind('click', scope.select );
				//element.bind('click', function(e) { scope.$apply(function(scope){scope.select(e);}); } );
				element.bind('dragstart', function(e) { scope.$apply(function(scope){scope.handleDragStart(e);}); } );
				element.bind('dragend', function(e) { scope.$apply(function(scope){scope.handleDragEnd(e);}); } );
			}
		};
	})
	/*
		// this directive implements the Connect button
		.directive('ceConnectBtn', function()
		{
			return {
				restrict: 'A',
				replace: true,
				template: '<div class="btn-group"> \
								<a class="btn dropdown-toggle" data-toggle="dropdown">Connect <span class="caret"></span></a> \
								<ul class="dropdown-menu"> \
									<li ng-repeat="srv in services"><a ng-class="srvLinkClass(srv)" ng-click="connect(srv)">{{srv.display_name}}</a></li> \
								</ul> \
							</div>',
				controller: 'CEConnectBtnCtrl'
			};
		})
	*/
	// the browser left pane directive
	.directive('ceLeftPane',  function()
	{
		return {
			restrict: 'C',
			replace: true,
			template: "<div> \
						<ul class=\"tree\"> \
							<li ng-repeat=\"srvIt in srvList\" ng-init=\"srv=srvIt.name; path='';\"> \
								<span class=\"ce-item ce-folder srvIt\" ng-click=\"enterDir()\"><img title=\"{{ srvIt.description }}\" ng-src=\"../{{ srvIt.image_small }}\" /> {{ srvIt.display_name }}</span> \
							</li> \
						</ul> \
					</div>",
			controller: 'CELeftPaneCtrl'
		};
	})

	// the browser right pane directive
	// FIXME: The download link will not dl but open in FF20 if not same origin thus the blank target
	.directive('ceRightPane',  function()
	{
		return {
			restrict: 'C',
			replace: true,
			template: "<div> \
						<div class='homeMsg' ng-if=\"!isConnected()\"> \
							Click on a service in the list on the left to connect it. \
						</div> \
						<div ng-if=\"isConnected()\"> \
							<div class='controls clearfix'> \
								<span ng-show=\"isCtrlBtnsVisible()\"> \
									<button class=\"ce-mkdir-btn\"></button> \
									<div ng-hide=\"hideSaveAsBtn()\" class=\"ce-saveas-btn\">Save As: {{ srv+\":\"+path+\"/\" }} <input type=\"text\" ng-model=\"saveAsName\"> .{{ext}} <button ng-click=\"saveAs(saveAsName)\">OK</button></div> \
								</span> \
								<span ng-if='showCheckedOption()' class='checkedOption'> \
									<button ng-click='removeAllChecked()' title='remove selected files'><i class='icon-suppr'></i></button> \
								</span> \
							</div> \
							<!-- <div ng-if='showBreadCrumbLink()' class='breadcrumLinkContent'> --> \
							<div class='breadcrumLinkContent'> \
								<div ng-init='setBreadCrumbLink()'> \
									<i class='icon-cloud'></i> <span ng-click='enterDirBreadCrumb(\"\")' class='breadcrumLink'>{{srv}}</span> \
									<span ng-repeat='link in breadCrumb'> \
										{{link.sep}} \
										<span ng-click='enterDirBreadCrumb(link.path)' class='breadcrumLink'>{{link.name}}</span>\
									</span> \
								</div> \
								<div class='title'><i class='icon-folder'></i> {{ currentDir }}</div> \
							</div> \
							<ul> \
								<li class='clearfix'> \
									<span class='titleCol fileName'> Name </span> \
									<span class='titleCol fileType'> Type </span> \
									<span class='titleCol lastUpdate'> Last update </span> \
								</li> \
								<li ng-if=\"showLinkToParent()\" ng-click=\"enterDir()\"><div ng-init=\"setLinkToParent()\" class=\"ce-item ce-folder is-dir-true\">..</div></li> \
								<li class=\"ce-item\" ng-repeat=\"file in files | orderBy:'is_dir':true\"> \
									<input type='checkbox' name='{{file.name}}' id='{{file.name}}' ng-model='check' ng-change='checkIt(file.name, file)' checklist-value='file.name' /> \
									<label for='{{file.name}}'> \
										<div ng-if=\"file.is_dir && !renameOn\" class='file'> \
											<div class=\"ce-folder ce-file clearfix\" ng-class=\"getClass()\" > \
												<span class='fileName' ng-click=\"enterDir()\">{{file.name}} </span>\
												<span class='fileType'>folder</span> \
												<span class='lastUpdate'>{{file.modified | customDate}}</span> \
											</div> \
										</div> \
										<div ng-if=\"!file.is_dir && !renameOn\" class='file'> \
											<div class=\"ce-file clearfix\" ng-class=\"getClass()\"> \
												<span class='fileName' ng-click=\"select()\">{{file.name}} </span> \
												<span class='fileType'>{{file.name | typeFile}}</span> \
												<span class='lastUpdate'>{{file.modified | customDate}}</span> \
											</div> \
										</div> \
										<div class=\"ce-rename\" ng-if=\"renameOn\" ng-class=\"getClass()\"></div> \
										<div class=\"ctrls\"><button ng-if=\"file.is_dir && selectDirOn\" class=\"select\" ng-click=\"select()\"></button><button class=\"rename\" type='button' ng-click=\"rename('')\"></button><button class=\"remove\" type='button' ng-click=\"remove()\"></button></div> \
									</label> \
								</li> \
								<li class=\"ce-new-item ce-mkdir\" ng-if=\"mkdirOn\"></li> \
							</ul> \
							<div class=\"ce-item ce-folder dropzone\" data-path=\"{{ filePath = path }}\"> \
								 <h2>Drop your file(s) here</h2> \
								 <!-- <div>or you can also...</div> --> \
								<div class=\"file-uploader\"></div> \
							</div> \
						</div> \
					</div>",
			//	<a ng-hide=\"file.is_dir\" ng-href=\"{{download()}}\" download=\"{{file.name}}\" target=\"blank\">download</a> \
			controller: 'CERightPaneCtrl'
		};
	})

	// this is the root directive, the one you should use in your projects
	.directive('ceBrowser',  function()
	{
		return {
			restrict: 'C',
			replace: true,
			template: "<div> \
						<div class=\"ceTitle\"> \
							<!-- Browse your cloud drives --> \
							<button class=\"close-btn\" type=\"button\" ng-click=\"abort()\"></button> \
							<button type=\"button\" ng-click=\"logout()\" ng-if=\"isConnected()\">({{ getDisplayName() }}) Logout</button> \
							<img class='logo' src='./assets/logo-cloudExplorer.png' alt='Cloud Explorer'/> \
						</div> \
						<div ng-if=\"isPopupBlocked()\" class=\"error-popup\">Popup Blocker is enabled! Please add this site to your exception list.</div> \
						<div ng-if=\"authPopup.show\" class=\"authPopup\"><div ng-click=\"authorize()\"><a href=\"#\" >CLICK HERE</a> to authorize Cloud Explorer to use your {{ authPopup.srvName }} account.</div></div> \
						<div class=\"content clearfix\"> \
							<div class=\"cloudList\"> \
								<div class=\"ce-left-pane\"></div> \
							</div> \
							<div class=\"fileList\"> \
								<div class=\"ce-right-pane\"></div> \
							</div> \
						</div> \
					</div>",
			controller: 'CEBrowserCtrl'
		};
	});
