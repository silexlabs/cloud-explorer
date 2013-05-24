'use strict';

/**
 * Front-end component for the unifile node.js server ()
 * @author Thomas Fétiveau, http://www.tokom.fr/  &  Alexandre Hoyau, http://www.intermedia-paris.fr/
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */

/**
 * TODO
 *
 * console
 *
 * upload progress
 *
 * Delete, rename, move
 * drag 'n drop
 *
 * bootstrap styling
 */

/* Config */
angular.module('ceConf', [])
	.constant( 'server.url', 'http://127.0.0.1\\:5000/v1.0/' )
	.constant( 'console.level', 0 ) // 0: DEBUG, 1: INFO, 2: WARNING, 3: ERROR, 4: NOTHING
	.config(['$httpProvider', function($httpProvider)
	{
		delete $httpProvider.defaults.headers.common["X-Requested-With"];
		$httpProvider.defaults.useXDomain = true;
		$httpProvider.defaults.withCredentials = true;
	}]);

/* Controllers */
angular.module('ceCtrls', [])
	.controller('CEConsoleCtrl', [ '$scope', '$element', function( $scope, $element )
	{
		function onLogEntry( event, msg, l )
		{
			event.stopPropagation();
			$element.append("<li>"+l+": "+msg+"</li>"); // FIXME see if we can use some kind of template here...
		}
		$scope.$on("log", onLogEntry);
	}]);

/* Services */
angular.module('ceServices', ['ngResource', 'ceCtrls'])
	.factory('ceConsoleSrv', [ '$rootScope', 'console.level', function( $rootScope, level )
	{
		return { 
			"log": function( msg, l ) { if ( l >= level ) $rootScope.$emit("log", msg, l); }
		};
	}])
	.factory('ceFile', ['$resource', 'server.url', function( $resource, serverUrl )
	{
		//return $resource(CEConfig.serverUrl+':service/:method/:command/?:path/', {}, {  // workaround: "?" is to keep a "/" at the end of the URL
		return $resource( serverUrl + ':service/:method/:command/:path ', {},
			{  // *very ugly* FIXME added space to keep the '/' at the end of the url
				listServices: {method:'GET', params:{service:'services', method:'list'}, isArray:true},
				connect: {method:'GET', params:{method:'connect'}, isArray:false},
				login: {method:'GET', params:{method:'login'}, isArray:false},
				ls: {method:'GET', params:{method:'exec', command:'ls'}, isArray:true}
				//get: {method:'GET', params:{method:'exec', command:'get'}, isArray:true}
			});
	}])
	.service('$fileUpload', ['$http', function($http)
	{
		this.upload = function(uploadFiles, path)
		{
			//Not really sure why we have to use FormData().  Oh yeah, browsers suck.
			var formData = new FormData();
			for(var i in uploadFiles)
			{
				formData.append('data', uploadFiles[i], uploadFiles[i].name);
			}
console.log(formData);
			$http({
					method: 'POST',
					url: 'http://127.0.0.1:5000/v1.0/dropbox/exec/put/' + path + uploadFiles[0].name,
					data: formData,
					headers: {'Content-Type': undefined},
					transformRequest: angular.identity
				})
				.success(function(data, status, headers, config) {
					alert("file(s) successfully sent");
				});
		}
	}]);

/* Directives */
angular.module('ceDirectives', [ 'ceConf', 'ceServices', 'ceCtrls' ])
	.directive('fileUploader', function()
	{
		return {
			restrict: 'A',
			transclude: true,
			template: '<div><input type="file" multiple /><button ng-click="upload()">Upload</button><ul><li ng-repeat="uploadFile in uploadFiles">{{uploadFile.name}} - {{uploadFile.type}}</li></ul></div>',
			replace: true,
			controller: function($scope, $fileUpload)
			{
				$scope.notReady = true;
				$scope.upload = function() { console.log( "upload at "+$scope.path );
					$fileUpload.upload($scope.uploadFiles, $scope.path);
				};
			},
			link: function($scope, $element)
			{
				var fileInput = $element.find('input');
				fileInput.bind('change', function(e)
				{
console.log('change $scope.uploadFiles = '+$scope.uploadFiles);
					$scope.notReady = e.target.files.length == 0;
					$scope.uploadFiles = [];
					for(var i in e.target.files)
					{
	          			//Only push if the type is object for some stupid-ass reason browsers like to 
	          			//include functions and other junk
						if(typeof e.target.files[i] == 'object') $scope.uploadFiles.push(e.target.files[i]);
					}
console.log('end change $scope.uploadFiles = '+$scope.uploadFiles);
				});
			}
		};
	})
	.directive('ceConsole', function()
	{
		return {
			restrict: 'A',
			replace: true,
			template: '<ul class="ce-log-console"></ul>',
			controller: 'CEConsoleCtrl'
		};
	})
	.directive('ceBrowser', [ 'ceFile', function( ceFile )
	{
		return {
			restrict: 'A',
			replace: true,
			//transclude: false, // ?
			//scope: true, // ?
			templateUrl: 'partials/ce-browser.html',
			// The linking function will add behavior to the template
			link: function(scope, element, attrs, ceFile)
			{

			},
			controller: [ '$scope', '$location', '$window', 'ceFile' , 'server.url', 'ceConsoleSrv', function( $scope, $location, $window, ceFile, serverUrl, ceConsole )
			{
				function authorize( url )
				{
					var authPopup = $window.open( url, 'authPopup', 'height=800,width=900'); // FIXME parameterize size
					authPopup.owner = $window;
					if ($window.focus) { authPopup.focus() }
					if (authPopup)
					{
						ceConsole.log("Authorization popup opened", 0);
						if ( confirm('Authorize the app in the popup window and click "ok"') )
						{
							ceConsole.log("Authorization popup returned true", 0);
							return true;
						}
					}
					else
					{
						ceConsole.log("Authorization popup could not be opened", 0);
						console.error('Popup could not be opened');
					}
					ceConsole.log("Authorization refused", 0);
					return false;
				}
				/**
				 * Connect to service
				 * FIXME Do not open popup if already authorized/connected ?
				 */
				function connect( serviceName )
				{
					ceConsole.log("Connecting to "+serviceName, 0);
					var res = ceFile.connect({service:serviceName}, function ()
					{
						ceConsole.log("Connected. Auth url is: "+res.authorize_url, 0);

						if ( authorize( res.authorize_url ) )
						{
							ceConsole.log("Authorized", 0);

							if ( $scope.tree[ serviceName ] == null )
							{
								$scope.tree[ serviceName ] = [];
							}
							$scope.srv = serviceName;
							login();
						}
					});
				}
				/**
				 * login
				 */
				function login()
				{
					ceConsole.log("Logging in", 0);
					var res = ceFile.login({service:$scope.srv}, function (status)
						{
							ceConsole.log("Login status is: "+status, 0);

							if (res.success == true)
							{
								ceConsole.log("Login success", 0);

								$scope.isLoggedin = true;
								$scope.path = '';
								ls();
							}
						},
						function (obj) // FIXME
						{
							console.error('Could not login. Try connect first, then follow the auth URL and try login again.');
							console.error(obj.data); // FIXME
							console.error(obj.status); // FIXME
							$scope.isLoggedin = false; // FIXME
							//$window.location.hash = $scope.srv+'/';
						});
				}

				/**
				 * 
				 */
				function listServices()
				{
					ceConsole.log("Listing services...", 0);
					$scope.services = ceFile.listServices();
				}

				// INITIALIZING
				$scope.services = [];
				$scope.connect = connect; // TODO why do I have to do this assignment ?!!!

				// user status
				$scope.isLoggedin = false;
				// current path 
				$scope.path = ''; 
				// current srv 
				$scope.srv = null; 
				// current files list
				$scope.files = [];
				// the file tree structure
				$scope.tree = {};

				$scope.uploadCurrent = '';
				$scope.uploadMax = '';

				// Starting
				listServices();

				/**
				 * cd command
				 */
				function cd (path, srv)
				{
					ceConsole.log("Changing path "+path+" in "+srv, 0);

					if ($scope.isLoggedin)
					{
						if ( path.length > 1 && path.charAt(path.length - 1) != '/' )
						{
							path += '/';
						}
						//if (path.charAt(0) == '/')
						// {
						$scope.path = path; //.substr(1); //
						//}
						// else
						//{
						//   $scope.path += path;
						//}
						/*if($scope.path.substr(-1) != '/')
						{
						$scope.path += '/';
						}*/
						if ( $scope.tree[srv] )
						{
							$scope.srv = srv;
						}
//console.log('path= '+$scope.path+'  srv='+srv+'  tree= ');
//console.log( $scope.tree );
					}
					else
					{
						console.error('Not logged in');
						ceConsole.log("Not logged in", 3);
						throw(Error('Not logged in'));
					}
				}
				/**
				 * Creates or updates the tree
				 */
				function appendToTree( tree, path, res )
				{
//console.log("appendToTree path="+path);
					if ( path == '' )
					{
						return res;
					}
					var np;

					if (path.indexOf('/') != -1)
					{
						np = path.substring( 0, path.indexOf('/') );
						path = path.substring(path.indexOf('/') + 1);
					}
					else
					{
						np = path;
						path = '';
					}
					var ci = -1;

					for (ci = 0; ci < tree.length; ci++)
					{
						if (tree[ci].name == np && tree[ci].is_dir == true)
						{
							break;
						}
					}
					if (ci == tree.length || ci == -1)
					{
						throw(Error('No jump allowed yet : at ci='+ci));
					}
					tree[ci]['children'] = appendToTree( tree[ci]['children'], path, res );

					return tree;
				}
				/**
				 * ls command
				 */
				function ls()
				{
					ceConsole.log("Listing "+$scope.path+" for service "+$scope.srv, 0);
/*console.log('ls ' + $scope.path+ '  scope.tree= '+ $scope.tree);*/
/*console.log( 'ls srvName=' + $scope.srv + '   path=' + $scope.path + '   scope.tree= ' );
console.log( $scope.tree );*/
					if ($scope.isLoggedin)
					{
						var res = ceFile.ls({service:$scope.srv, path:$scope.path}, function (status)
						{
							ceConsole.log("Listing command returned "+status, 0);
/*console.log( 'ls result: ' + res.length + '  scope.tree= ' );
console.log( $scope.tree );
console.log( res );*/
							$scope.files = res;
							var path = $scope.path;
							
							while ( path.charAt(0) == '/' )
							{
								path = path.substring(1);
							}
							while ( path.endsWith('/') )
							{
								path = path.substr(0, path.length-1);
							}
							$scope.tree[ $scope.srv ] = appendToTree( $scope.tree[ $scope.srv ], path, res );
/*console.log( "scope tree is now " );
console.log( $scope.tree );*/
						});
					}
					else
					{
						console.error('Not logged in');
						ceConsole.log("Not logged in!", 3);
						throw(Error('Not logged in'));
					}
				}
				/**
				 * enter directory callback
				 */
				$scope.doEnter = function(file, path, srv)
				{
//console.log('doEnter file='+file+'  path='+path+'  srv='+srv);
					if (!path)
					{
//console.log('doEnter no path set  path='+path);
						path = '';
					}
					if (!srv)
					{
						srv = $scope.srv;
					}
					if (file == '' && path == '' || file.is_dir == true)
					{
//console.log('doEnter file is a dir');
						cd(path, srv);
						ls();
					}
					else
					{
						// get the file
						var filePopup = $window.open( serverUrl + $scope.srv+'/exec/get/'+path, 'filePopup', 'height=800,width=800');
						filePopup.owner = $window;
						if ($window.focus) { filePopup.focus() }
					}
				};
				/**
				 * get file item css class name
				 */
				$scope.fileClass = function(file) // FIXME why is that called 3 times per item ?
				{
//console.log('fileClass '+file.is_dir);
					if (file.is_dir == true)
					{
						return'is-dir-true';
					}
					else
					{
						return 'is-dir-false';
					}
				};
				$scope.isRootPath = function()
				{
//console.log('isRootPath '+$scope.path);
					if ( $scope.path == '' || $scope.path == '/' )
					{
//console.log('isRootPath true');
						return true;
					}
//console.log('isRootPath false');
					return false;
				};
				$scope.enterParentDir = function()
				{
//console.log('isRootPath ');
					if ($scope.path.endsWith('/'))
					{
						$scope.path = $scope.path.substr(0, $scope.path.length-1);
					}
					var lsi = $scope.path.lastIndexOf('/');
					if (lsi > 0)
					{
						cd('/' + $scope.path.substr(0, lsi));
					}
					else
					{
						cd('/');
					}
					ls();
				};
			}]
		}
	}]);