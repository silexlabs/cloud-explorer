  'use strict';

  /* Controllers */

angular.module('ceControllers', []).
	controller('CESidebarCtrl', [ '$scope', '$location', 'ceFile' , function( $scope, $location, ceFile )
	{
		$scope.services = []; 
		/**
		 * list services
		 */
		function listServices ()
		{
			$scope.services = ceFile.listServices();
console.log('listServices '+$scope.services);
console.log($scope.services);
		}
		listServices();
	}]).
	controller('CEConnectionCtrl', [ '$scope', '$window', '$routeParams', 'ceFile' , function( $scope, $window, $routeParams, ceFile )
	{
		/**
		 * connect
		 */
		$scope.doConnect = function () // ??? FIXME
		{
			connect();
		}
		/**
		 * connect
		 */
		function connect()
		{
console.log('connect ');
			var res = ceFile.connect({service:$routeParams.service}, function () {
console.log('connect result: '+res.authorize_url);
				openAuthPopup(res.authorize_url);
			});
		}
	    /**
		 * open a popup for auth
		 */
		function openAuthPopup (url)
		{
			var authPopup = $window.open(url,'authPopup','height=800,width=900');
			authPopup.owner = $window;
			if ($window.focus) { authPopup.focus() }
			if (authPopup)
			{
console.log('authPopup opened ');
				if (confirm('Authorize the app in the popup window and click "ok"'))
				{
					$window.location.hash = $routeParams.service+'/connected/';
				}
			}
			else
			{
				console.error('Popup could not be opened');
			}
		}

	}])
	.controller('CEBrowseCtrl', [ '$scope', '$window', '$routeParams', 'ceFile', 'server.url' , function( $scope, $window, $routeParams, ceFile, serverUrl )
	{
		// user status
		$scope.isLoggedin = false;
		// current path 
		$scope.path = ''; 
		// current files list
		$scope.files = [];
		// the entire tree structure
		$scope.tree = {};

		/**
		 * login
		 */
		function login()
		{
console.log('login ');
			var res = ceFile.login({service:$routeParams.service}, function (status)
			{
console.log('login result: ');
console.log(status);
				if (res.success == true)
				{
console.log('user logged in');
					$scope.isLoggedin = true;
					ls();
				}
			},
			function (error)
			{
				console.error('Could not login. Try connect first, then follow the auth URL and try login again.');
				$scope.isLoggedin = false;
				$window.location.hash = $routeParams.service+'/';
			});
		}
		/**
		 * cd command
		 */
		function cd (path)
		{
console.log('cd '+path);
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
console.log('path= '+$scope.path+'  tree= '+$scope.tree);
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
console.log('ls ' + $scope.path+ '  scope.tree= '+ $scope.tree);
			if ($scope.isLoggedin)
			{
				var res = ceFile.ls({service:$routeParams.service, path:$scope.path}, function (status) {
console.log('ls result: '+res.length+ '  scope.tree= '+ $scope.tree);
console.log(res);
					$scope.files = res;
					var path = $scope.path;
					if ( path.charAt(0) == '/' )
					{
						path = path.substring(1);
					}
					if ( path.endsWith('/') )
					{
						path = path.substr(0, path.length-1);
					}
					$scope.tree = appendToTree($scope.tree, path, res);
					console.log($scope.tree);
				});
			}
			else
			{
				console.error('Not logged in');
				throw(Error('Not logged in'));
			}
		}
		/**
		 * get command
		 */
/*		function get()
		{
console.log('get ' + $scope.path);
			if ($scope.isLoggedin)
			{
				var res = ceFile.get({service:$routeParams.service, path:$scope.path}, function (status) {

					});
			}
			else
			{
				console.error('Not logged in');
				throw(Error('Not logged in'));
			}
		}*/
		/**
		 * change path callback
		 */
		$scope.doSetPath = function(path)
		{
console.log('doSetPath '+path);
			cd(path);
			ls();
		}
		/**
		 * enter directory callback
		 */
		$scope.doEnter = function(file, path)
		{
console.log('doEnter file='+file+'  path='+path);
			if (!path)
			{
console.log('doEnter no path set  path='+path);
				path = '';
			}
			if (file.is_dir == true)
			{
console.log('doEnter file is a dir');
				cd(path);
				ls();
			}
			else
			{
				// get the file
				var filePopup = $window.open( serverUrl+$routeParams.service+'/exec/get/'+path, 'filePopup', 'height=800,width=800');
				filePopup.owner = $window;
				if ($window.focus) { filePopup.focus() }
			}
		}
		/**
		 * refresh callback
		 */
		$scope.doRefresh = function() // FIXME useful ?
		{
			ls();
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
		/**
		 * status events
		 *
		$scope.onStatus = function($scope, status, data) {
		console.log("onStatus "+status);
		switch (status){
		// listServices success
		case 'listServices':
		console.log('listServices ');
		console.log(data);
		$scope.services = data;
		break;
		// connection success
		case 'connect':
		console.log('connect '+data.authorize_url);
		console.log(data);
		openAuthPopup(data.authorize_url);
		break;
		// login success
		case 'login':
		var isStatusOk = (data && data.status && data.status.success);
		console.log('login '+isStatusOk);
		console.log(data);
		$scope.isLoggedin = isStatusOk;
		break;
		// files list ready
		case 'ls':
		console.log('ls ');
		console.log(data);
		$scope.files = data;
		break;
		}
		$scope.$digest();
		}
		/**/
		login();
	}]);
