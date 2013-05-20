'use strict';

/* Config */
angular.module('ceConf', [])
	.constant( 'server.url', 'http://unifile.herokuapp.com/v1.0/' )
	.config(['$httpProvider', function($httpProvider)
	{
		delete $httpProvider.defaults.headers.common["X-Requested-With"];
		$httpProvider.defaults.useXDomain = true;
		$httpProvider.defaults.withCredentials = true;
	}]);

/* Services */
angular.module('ceFileService', ['ngResource'])
	.factory('ceFile', ['$resource', 'server.url', function($resource, serverUrl)
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
	}]);

/* Directives */
angular.module('ceDirectives', [ 'ceConf', 'ceFileService' ])
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
			controller: [ '$scope', '$location', '$window', 'ceFile' , 'server.url', function( $scope, $location, $window, ceFile, serverUrl )
			{
				function authorize( url )
				{
					var authPopup = $window.open( url, 'authPopup', 'height=800,width=900'); // FIXME parameterize size
					authPopup.owner = $window;
					if ($window.focus) { authPopup.focus() }
					if (authPopup)
					{
console.log('authPopup opened ');
						if ( confirm('Authorize the app in the popup window and click "ok"') )
						{
console.log('authPopup returned true ');
							return true;
						}
					}
					else
					{
						console.error('Popup could not be opened');
					}
console.log('authorize returned false ');
					return false;
				}
				/**
				 * Connect to service
				 * FIXME Do not open popup if already authorized/connected ?
				 */
				function connect( serviceName )
				{
console.log('connect ');
					var res = ceFile.connect({service:serviceName}, function () {
console.log('connect result: '+res.authorize_url);
						if ( authorize( res.authorize_url ) )
						{
console.log('authorized');
							if ( $scope.tree[ serviceName ] == null )
							{
								$scope.tree[ serviceName ] = [];
console.log('scope.tree['+serviceName+'] initialized');
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
console.log('login ');
					var res = ceFile.login({service:$scope.srv}, function (status)
						{
console.log('login result: ');
console.log(status);
							if (res.success == true)
							{
console.log('user logged in');
								$scope.isLoggedin = true;
								$scope.path = '';
								ls();
							}
						},
						function (error)
						{
							console.error('Could not login. Try connect first, then follow the auth URL and try login again.');
							$scope.isLoggedin = false;
							$window.location.hash = $scope.srv+'/';
						});
				}

				/**
				 * 
				 */
				function listServices()
				{
					$scope.services = ceFile.listServices();
console.log('listServices ' + $scope.services);
console.log($scope.services);
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

				// EXECUTING
console.log("EXECUTING ceBrowser directive controller...");
				listServices();

				/**
				 * cd command
				 */
				function cd (path, srv)
				{
console.log('cd '+path+'  srv='+srv);
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
console.log('path= '+$scope.path+'  srv='+srv+'  tree= ');
console.log( $scope.tree );
					}
					else
					{
						console.error('Not logged in');
						throw(Error('Not logged in'));
					}
				}
				/**
				 * Creates or updates the tree
				 */
				function appendToTree( tree, path, res )
				{
console.log("appendToTree path="+path);
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
/*console.log('ls ' + $scope.path+ '  scope.tree= '+ $scope.tree);*/
console.log( 'ls srvName=' + $scope.srv + '   path=' + $scope.path + '   scope.tree= ' );
console.log( $scope.tree );
					if ($scope.isLoggedin)
					{
						var res = ceFile.ls({service:$scope.srv, path:$scope.path}, function (status) {
console.log( 'ls result: ' + res.length + '  scope.tree= ' );
console.log( $scope.tree );
console.log( res );
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
console.log( "scope tree is now " );
console.log( $scope.tree );
						});
					}
					else
					{
						console.error('Not logged in');
						throw(Error('Not logged in'));
					}
				}
				/**
				 * enter directory callback
				 */
				$scope.doEnter = function(file, path, srv)
				{
console.log('doEnter file='+file+'  path='+path+'  srv='+srv);
					if (!path)
					{
console.log('doEnter no path set  path='+path);
						path = '';
					}
					if (!srv)
					{
						srv = $scope.srv;
					}
					if (file == '' && path == '' || file.is_dir == true)
					{
console.log('doEnter file is a dir');
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
				}
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
				}
				$scope.isRootPath = function()
				{
console.log('isRootPath '+$scope.path);
					if ( $scope.path == '' || $scope.path == '/' )
					{
console.log('isRootPath true');
						return true;
					}
console.log('isRootPath false');
					return false;
				}
				$scope.enterParentDir = function()
				{
console.log('isRootPath ');
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
				}
			}]
		}
	}]);