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
 * forbid mkdir and rename with empty names !!! => create alert/error system or use console
 * fix server url constant
 * each time we have a new input text (rename or mkdir), set focus on input text
 * refresh after upload ! (or update model)
 * refresh after moove ! (or update model)
 * console messages + display
 * drag from CE to desktop
 * move between services [need fix in unifile]
 * upload progress
 * bootstrap styling
 * download link won't propose to save file in Firefox 20 if not same origin, we could force download from server side [unifile]
 * rename should happen on simple click
 * double click should enter/download
 * checkboxes before items should allow mass deleting, copying, moving ?
 */

/* Config */
angular.module('ceConf', [])

	.constant( 'server.url', 'http://127.0.0.1\\:5000/v1.0/' )

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

	.factory('$unifileSrv', ['$resource', 'server.url', function( $resource, serverUrl )
	{
		//return $resource(CEConfig.serverUrl+':service/:method/:command/?:path/', {}, {  // workaround: "?" is to keep a "/" at the end of the URL
		return $resource( serverUrl + ':service/:method/:command/:path ', {},
			{  // *very ugly* FIXME added space to keep the '/' at the end of the url
				listServices: {method:'GET', params:{service:'services', method:'list'}, isArray:true},
				connect: {method:'GET', params:{method:'connect'}, isArray:false},
				login: {method:'GET', params:{method:'login'}, isArray:false},
				ls: {method:'GET', params:{method:'exec', command:'ls'}, isArray:true},
				rm: {method:'GET', params:{method:'exec', command:'rm'}, isArray:false},
				mkdir: {method:'GET', params:{method:'exec', command:'mkdir'}, isArray:false},
				cp: {method:'GET', params:{method:'exec', command:'cp'}, isArray:false},
				mv: {method:'GET', params:{method:'exec', command:'mv'}, isArray:false},
				get: {method:'GET', params:{method:'exec', command:'get'}, isArray:true}
			});
	}])

	.service('$unifileUploadSrv', ['$http', '$ceConsoleSrv', function($http, $ceConsoleSrv)
	{
		this.upload = function(uploadFiles, path)
		{
			var formData = new FormData();
			for(var i in uploadFiles)
			{
				formData.append('data', uploadFiles[i], uploadFiles[i].name);
			}
//console.log(formData);
			$http({
					method: 'POST',
					url: 'http://127.0.0.1:5000/v1.0/dropbox/exec/put/'+path, // FIXME address as config value
					data: formData,
					headers: {'Content-Type': undefined},
					transformRequest: angular.identity
				})
				.success(function(data, status, headers, config) {
					$ceConsoleSrv.log("file(s) successfully sent", 0);
				});
		}
	}]);


/* Controllers */
angular.module('ceCtrls', ['ceServices'])

	/**
	 * TODO comment
	 */
	.controller('CEPasteCtrl', ['$scope', '$unifileSrv', function($scope, $unifileSrv)
		{
			$scope.isClipboardEmpty = function()
			{
console.log("is $scope.clipboard empty? "+$scope.clipboard);
				return ($scope.clipboard === false);
			}
			$scope.paste = function()
			{
console.log("paste called with $scope.clipboard= "+$scope.clipboard);
				if ($scope.clipboard === false)
				{
					return;
				}
				var fn = $scope.clipboard.substr($scope.clipboard.lastIndexOf('/')+1);
console.log("copying file "+$scope.clipboard+" to "+$scope.path+fn);
				$unifileSrv.cp({service:$scope.srv, path:$scope.clipboard+':'+$scope.path+fn}, function(){
					console.log("copy done");
					$scope.clipboard = null;
					$scope.ls();
				});
			};
		}])

	/**
	 * This controller is shared by the ceFile and ceFolder directives.
	 */
	.controller('CEFileEntryCtrl', ['$scope', '$element', '$attrs', '$transclude', '$unifileUploadSrv', '$unifileSrv', function($scope, $element, $attrs, $transclude, $unifileUploadSrv, $unifileSrv)
		{
			$scope.filePath = $scope.path; console.log('$scope.filePath= '+$scope.filePath);
			$scope.fileSrv = $scope.srv; console.log('$scope.fileSrv= '+$scope.fileSrv);
			$scope.renameOn = false;
			// can be dir, file or both
			$scope.isFile = false;
			$scope.isDir = false;

			if ($scope.file != null)
			{
				$scope.filePath += $scope.file.name; console.log('finally $scope.filePath= '+$scope.filePath);
			}

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
			 * TODO comment
			 */
			$scope.isRootPath = function()
			{
//console.log('isRootPath '+$scope.path);
				if ( $scope.path == undefined || $scope.path == '' || $scope.path == '/' )
				{
//console.log('isRootPath true');
					return true;
				}
//console.log('isRootPath false');
				return false;
			};

			/**
			 * TODO comment
			 */
			$scope.enterDir = function()
			{
console.log("Entering within "+$scope.filePath);
				if ($scope.file != null && $scope.file.is_dir || $scope.file == null)
				{
					$scope.cd($scope.filePath, $scope.fileSrv);
					$scope.ls();
				}
				/*else TODO ?
				{
					// get the file
					var filePopup = $window.open( serverUrl + $scope.srv+'/exec/get/'+path, 'filePopup', 'height=800,width=800');
					filePopup.owner = $window;
					if ($window.focus) { filePopup.focus(); }
				}*/
			};

			/**
			 * TODO comment
			 */
			$scope.handleDragStart = function(e)
			{
console.log("ceFile => dragStart,  e.target= "+e.target+",  path= "+$scope.filePath);
				e.originalEvent.dataTransfer.effectAllowed = 'move';
				e.originalEvent.dataTransfer.setData('text', $scope.filePath);

				$element.addClass("ce-file-drag"); // FIXME make it a param in conf?
			};
			/**
			 * TODO comment
			 */
			$scope.handleDragEnd = function(e)
			{
//console.log( "ceFile => dragEnd  file= " + e.originalEvent.dataTransfer.getData('text') );
				$element.removeClass("ce-file-drag"); // FIXME make it a param in conf?
			};

			/**
			 * TODO comment
			 */
			$scope.getClass = function()
			{
				if ($scope.file != null && !$scope.file.is_dir)
				{
					return "is-dir-false";
				}
				return "is-dir-true";
			};

			/**
			 * TODO comment
			 */
			$scope.handleDragEnter = function(e) // TODO manage styles
			{
				e.preventDefault();
//console.log("e.target= "+e.target);
				$element.addClass("ce-folder-over"); // FIXME make it a param in conf?
			};
			/**
			 * TODO comment
			 */
			$scope.handleDragLeave = function(e) // TODO manage styles
			{
//console.log("e.target= "+e.target);
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
//console.log("drop ");
				e.stopPropagation();
				e.preventDefault();
				
				if ( e.originalEvent.dataTransfer.files && e.originalEvent.dataTransfer.files.length > 0 ) // case files from desktop
				{
//console.log("files from desktop case upload to: " + $scope.filePath);
					$unifileUploadSrv.upload( e.originalEvent.dataTransfer.files, $scope.filePath+'/' );
				}
				else // move case
				{
					var evPath = e.originalEvent.dataTransfer.getData('text');
					if ( $scope.filePath == evPath )
					{
						console.log("NOTICE: cannot move a folder into itself!");
					}
					else
					{
//console.log("move " + evPath + " to: " + $scope.filePath+'/'+evPath.substr(evPath.lastIndexOf('/')+1)); // NOTE: new path will probably need to be concatenated with file '/'+name
						$unifileSrv.mv({service:$scope.fileSrv, path:evPath+':'+$scope.filePath+'/'+evPath.substr(evPath.lastIndexOf('/')+1)});
					}
				}
			};
			/**
			 * TODO comment
			 */
			$scope.download = function()
			{
				return 'http://127.0.0.1:5000/v1.0/'+$scope.fileSrv+'/exec/get/'+$scope.filePath; // FIXME make it a conf param
			};
			/**
			 * TODO comment
			 */
			$scope.rename = function(newName)
			{
				if (!$scope.renameOn)
				{
					$element.unbind('click', $scope.enterDir);
					$element.unbind('dragenter', $scope.handleDragEnter);
					$element.unbind('dragleave', $scope.handleDragLeave);
					$element.unbind('dragover', $scope.handleDragOver);
					$element.unbind('drop', $scope.handleDrop);
					$element.unbind('dragstart', $scope.handleDragStart );
					$element.unbind('dragend', $scope.handleDragEnd );
					$scope.renameOn = true;
					//$element.children("input")[0].focus();
				}
				else
				{
					var newPath = $scope.filePath.substr(0, $scope.filePath.lastIndexOf('/') + 1) + newName;
//console.log("newName= " + newName);
//console.log("please rename to " + newPath);
					$unifileSrv.mv({service: $scope.fileSrv, path: $scope.filePath + ':' + newPath}, function()
						{
							$scope.filePath = newPath;
							$scope.file.name = newName;
							$scope.renameOn = false;
							if ($scope.isDir)
							{
								$element.bind('click', $scope.enterDir);
								$element.bind('dragenter', $scope.handleDragEnter);
								$element.bind('dragleave', $scope.handleDragLeave);
								$element.bind('dragover', $scope.handleDragOver);
								$element.bind('drop', $scope.handleDrop);
							}
							if ($scope.isFile)
							{
								$element.bind('dragstart', $scope.handleDragStart);
								$element.bind('dragend', $scope.handleDragEnd);
							}
						});
				}
			};
			/**
			 * TODO comment
			 */
			$scope.copy = function()
			{
				$scope.$parent.clipboard = $scope.filePath;
//console.log("$scope.$parent.clipboard now is "+$scope.$parent.clipboard);
			};
			/**
			 * TODO comment
			 * FIXME delete scope ?
			 */
			$scope.delete = function()
			{
//console.log("please delete "+$scope.fileSrv+"/"+$scope.filePath);
				$unifileSrv.rm({service:$scope.fileSrv, path:$scope.filePath}, function()
					{
						$scope.ls(); // FIXME we could also avoid doing a new request here and just delete the li
					});
			};
		}
	])

	// FIXME can surely be exploded in several specialized ctrls
	.controller('CEBrowserCtrl', [ '$scope', '$location', '$window', '$unifileSrv' , 'server.url', '$ceConsoleSrv', function( $scope, $location, $window, $unifileSrv, serverUrl, ceConsole )
		{
			// INITIALIZING
			$scope.services = [];
			$scope.connect = connect;

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

			$scope.mkdirOn = false;

			$scope.clipboard = false;

			/**
			 * TODO comment
			 */
			function authorize( url, serviceName )
			{
				var authPopup = $window.open( url, 'authPopup', 'height=600,width=600,dialog'); // FIXME parameterize size
				authPopup.owner = $window;
				if ($window.focus) { authPopup.focus() }
				if (authPopup)
				{
					ceConsole.log("Authorization popup opened", 0);
					
					// timer based solution until we find something better to listen to the child window events (close, url change...)
					var timer = setInterval(function() { if (authPopup.closed) { clearInterval(timer); ceConsole.log("Authorized", 0); if ( $scope.tree[ serviceName ] == null ) { $scope.tree[ serviceName ] = []; } $scope.srv = serviceName; login(); } }, 500);
				}
				else
				{
					ceConsole.log("Authorization popup could not be opened", 0);
					console.error('Popup could not be opened');
				}
			}
			/**
			 * Connect to service
			 * FIXME Do not open popup if already authorized/connected ?
			 */
			function connect( serviceName )
			{
				ceConsole.log("Connecting to "+serviceName, 0);
				var res = $unifileSrv.connect({service:serviceName}, function ()
				{
					ceConsole.log("Connected. Auth url is: "+res.authorize_url, 0);

					authorize( res.authorize_url, serviceName );
				});
			}
			/**
			 * login
			 */
			function login()
			{
				ceConsole.log("Logging in", 0);

				var res = $unifileSrv.login({service:$scope.srv}, function (status)
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
				$scope.services = $unifileSrv.listServices();
			}

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
			// share it to child ctrls
			$scope.cd = cd;

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
					var res = $unifileSrv.ls({service:$scope.srv, path:$scope.path}, function (status)
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
						while ( path.charAt(path.length-1) == '/' )
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
			// share it to child ctrls
			$scope.ls = ls;


			/**
			 * mkdir command
			 */
			$scope.doMkdir = function(mkdirName)
			{
				ceConsole.log("creating directory "+mkdirName+" in "+$scope.srv+":"+$scope.path, 1);
				$unifileSrv.mkdir({service:$scope.srv, path:$scope.path+mkdirName}, function () {
					$scope.mkdirOn = false;
					ceConsole.log("new "+mkdirName+" directory created.", 1);
					ls();
				});
			}
		}])

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
			restrict: 'A',
			transclude: true,
			template: '<div class="fileUploader"><input type="file" multiple /><button ng-click="upload()">Upload</button></div>',
			replace: true,
			controller: function($scope, $unifileUploadSrv)
			{
				$scope.notReady = true;

				$scope.push = function(e)
				{
console.log('change $scope.uploadFiles = '+$scope.uploadFiles);
					$scope.notReady = e.target.files.length == 0;
					$scope.uploadFiles = [];
					for(var i in e.target.files)
					{
						if(typeof e.target.files[i] == 'object') $scope.uploadFiles.push(e.target.files[i]);
					}
console.log('end change $scope.uploadFiles = '+$scope.uploadFiles);
					$unifileUploadSrv.upload($scope.uploadFiles, $scope.path);
				}
			},
			link: function($scope, $element)
			{
				var fileInput = $element.find('input');

				$scope.upload = function() { fileInput.trigger('click'); console.log( "browse called "); };

				fileInput.bind('change', $scope.push);
			}
		};
	})

	// the "new folder" button
	.directive('ceMkdirBtn', function()
	{
		return {
			restrict: 'A',
			template: '<button ng-click="mkdir()">New folder</button>',
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

	// the copy paste buttons
	.directive('cePasteBtn', function()
	{
		return {
			restrict: 'A',
			replace: true,
			template: '<button ng-hide="isClipboardEmpty()" ng-click="paste()">Paste</button>',
			controller: 'CEPasteCtrl'
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
	.directive('ceFolder', function()
	{
		return {
			priority: 1,
			restrict: 'A',
			link: function(scope, element, attrs)
			{
				scope.isDir = true;
				attrs.$set('dropzone', 'move');
				attrs.$set('draggable', 'false'); // necessary to avoid folders that aren't files to be draggable

				element.bind('click', scope.enterDir ); // not set with ng-click 'cause we need to be able to unbind it at some points (renaming, ...)
				element.bind('dragenter', scope.handleDragEnter );
				element.bind('dragleave', scope.handleDragLeave );
				element.bind('dragover', scope.handleDragOver );
				element.bind('drop', scope.handleDrop );
			},
			controller: 'CEFileEntryCtrl'
		};
	})

	// this directive implements the behavior of mooving a file on drag
	.directive('ceFile', function()
	{
		return {
			restrict: 'A',
			link: function(scope, element, attrs)
			{
				scope.isFile = true;
				attrs.$set('draggable', 'true');

				element.bind('dragstart', scope.handleDragStart );
				element.bind('dragend', scope.handleDragEnd );
			},
			controller: 'CEFileEntryCtrl'
		};
	})

	// this directive implements the Connect button
	.directive('ceConnectBtn', function()
	{
		return {
			restrict: 'A',
			template: '<div class="btn-group"><a class="btn dropdown-toggle" data-toggle="dropdown">Connect <span class="caret"></span></a><ul class="dropdown-menu"><li ng-repeat="service in services"><a ng-click="connect(service.name)">{{service.display_name}}</a></li></ul></div>'
		};
	})

	// this is the root directive that you should use in your projects
	.directive('ceBrowser',  function()
	{
		return {
			restrict: 'A',
			replace: true,
			//transclude: false, // ?
			//scope: true, // ?
			templateUrl: 'partials/ce-browser.html',
			controller: 'CEBrowserCtrl'
		};
	});