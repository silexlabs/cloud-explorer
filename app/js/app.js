'use strict';

/* App Module */

angular.module('CEApp', ['ceFilters', 'ceFileService', 'ceControllers']).
	constant( 'server.url', 'http://unifile.herokuapp.com/v1.0/' ).
	config(['$routeProvider', function($routeProvider) {
		$routeProvider.
			when('/:service/', {templateUrl: 'partials/connection.html',   controller: 'CEConnectionCtrl'}).
			when('/:service/connected/', {templateUrl: 'partials/files-list.html', controller: 'CEBrowseCtrl'}).
			otherwise({redirectTo: '/dropbox/connected/'});
	}]).
	config(['$httpProvider', function($httpProvider) {
		delete $httpProvider.defaults.headers.common["X-Requested-With"];
		$httpProvider.defaults.useXDomain = true;
		$httpProvider.defaults.withCredentials = true;
	}]);
