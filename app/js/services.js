'use strict';

/* Services *
angular.module('phonecatServices', ['ngResource']).
factory('Phone', function($resource){
return $resource('phones/:phoneId.json', {}, {
query: {method:'GET', params:{phoneId:'phones'}, isArray:true}
});
});
'use strict';

/* Services */

angular.module('ceFileService', ['ngResource']).
	factory('ceFile', ['$resource', 'server.url', function($resource, serverUrl)
		{
			//return $resource(CEConfig.serverUrl+':service/:method/:command/?:path/', {}, {  // workaround: "?" is to keep a "/" at the end of the URL
			return $resource( serverUrl + ':service/:method/:command/:path/ ', {},
				{  // *very ugly* FIXME added space to keep the '/' at the end of the url
					listServices: {method:'GET', params:{service:'services', method:'list'}, isArray:true},
					connect: {method:'GET', params:{method:'connect'}, isArray:false},
					login: {method:'GET', params:{method:'login'}, isArray:false},
					ls: {method:'GET', params:{method:'exec', command:'ls'}, isArray:true}
					//get: {method:'GET', params:{method:'exec', command:'get'}, isArray:true}
				});
		}]);

/* Services *

angular.module('ceFileService', ['ngResource']).
factory('ceFile', function($resource){
return $resource(CEConfig.serverUrl+':service/:method/:command/:path', {}, {
listServices: {method:'GET', params:{service:'services', method:'list', command:'', path:''}, isArray:true}
connect: {method:'GET', params:{method:'connect'}, isArray:false},
login: {method:'GET', params:{method:'login'}, isArray:false},
ls: {method:'GET', params:{method:'exec', command:'ls'}, isArray:false}
});
});
*/

/* Services *

.factory('ceState', function($resource){
var service = 'dropbox';
return {
getService: function(){return service;},
setService: function(x){
service=x;
}
};
});
*/