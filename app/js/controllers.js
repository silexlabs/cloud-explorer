'use strict';

/* Controllers */

function CESidebar($scope, $location, ceFile) {
  $scope.services = []; 
  /**
   * list services
   */
  function listServices () {
      $scope.services = ceFile.listServices();
      console.log('listServices '+$scope.services);
      console.log($scope.services);
  }
  listServices();
}

/* Controllers */

/**
 * Not connected state
 */
function CEConnectionController($scope, $window, $routeParams, ceFile) {
  /**
   * connect
   */
  $scope.doConnect = function () {
    connect();
  }
  /**
   * connect
   */
  function connect() {
    console.log('connect ');
    var res = ceFile.connect({service:$routeParams.service}, function () {
      console.log('connect result: '+res.authorize_url);
      openAuthPopup(res.authorize_url);
    });
  }

  /**
   * open a popup for auth
   */
  function openAuthPopup (url) {
    var authPopup = $window.open(url,'authPopup','height=800,width=800');
    authPopup.owner = $window;
    if ($window.focus) {authPopup.focus()}
    if (authPopup) {
      console.log('authPopup opened ');
      if (confirm('Authorize the app in the popup window and click "ok"')){
          $window.location.hash = $routeParams.service+'/connected/';
      }
    }else{
      console.error('Popup could not be opened');
    }
  }
}

//CEConnectionController.$inject = ['$scope', 'ceFile'];

/**
 * Connected state
 */
function CEBrowseController($scope, $window, $routeParams, ceFile) {
  // user status
  $scope.isLoggedin = false;
  // current path 
  $scope.path = ''; 
  // current files list
  $scope.files = []; //ceFile.ls($routeParams.service, $routeParams.path, function(res) {
  /**
   * login
   */
  function login () {
      console.log('login ');
      var res = ceFile.login({service:$routeParams.service}, function (status){
        console.log('login result: ');
        console.log(status);
        if (res.success == true){
          console.log('user logged in');
          $scope.isLoggedin = true;
          ls();
        }
      },
      function (error){
        console.log('Error: could not login. Try connect first, then follow the auth URL and try login again.');
        $scope.isLoggedin = false;
        $window.location.hash = $routeParams.service+'/';
      });
  }
  /**
   * cd command
   */
  function cd (path) {
    console.log('cd '+path);
    if ($scope.isLoggedin){
      console.log('cd '+path+' in '+$scope.path);
      if (path.substr(0, 1)=='/'){
        $scope.path = path;
      }else{
        $scope.path += path;
      }
      if($scope.path.substr(-1) != '/'){
        $scope.path += '/';
      }
    }else{
      console.error('Not logged in');
      throw(Error('Not logged in'));
    }
  }
  /**
   * ls command
   */
  function ls() {
    console.log('ls '+$scope.path);
    if ($scope.isLoggedin){
      var res = ceFile.ls({service:$routeParams.service, path:$scope.path}, function (status) {
        console.log('ls result: '+res.length);
        console.log(res);
        $scope.files = res;
      });
    }else{
      console.error('Not logged in');
      throw(Error('Not logged in'));
    }
  }
  /**
   * change path callback
   */
  $scope.doSetPath = function(path) {
    console.log('doSetPath '+path);
    cd(path);
    ls();
  }
  /**
   * enter directory callback
   */
  $scope.doEnterDir = function(file) {
    console.log('doEnterDir '+file);
    if (file.is_dir == true){
      cd(file.title);
      ls();
    }
  }
  /**
   * refresh callback
   */
  $scope.doRefresh = function() {
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
}

//CEBrowseController.$inject = ['$scope', '$routeParams', 'ceFile'];

