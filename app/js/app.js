'use strict';

/* App Module */

angular.module('CEApp', ['ceFilters', 'ceFileService']).
  config(['$routeProvider', function($routeProvider) {
  $routeProvider.
      when('/:service/', {templateUrl: 'partials/connection.html',   controller: CEConnectionController}).
      when('/:service/connected/', {templateUrl: 'partials/files-list.html', controller: CEBrowseController}).
      otherwise({redirectTo: '/dropbox/connected/'});
}]).config(['$httpProvider', function($httpProvider) {
    delete $httpProvider.defaults.headers.common["X-Requested-With"];
	$httpProvider.defaults.useXDomain = true;
	$httpProvider.defaults.withCredentials = true;
}]);
