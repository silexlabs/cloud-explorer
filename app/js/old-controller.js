
function CEController($scope) {

  // file system service
  $scope.fs = new CEFileService($scope);
  // current path 
  $scope.path = '/'; 
  // login status
  $scope.isLoggedin = false;
  $scope.accountInfo = {};

  // current files list
  $scope.files = [
    {
      "bytes": 0,
      "modified": "Thu, 03 Jan 2013 14:24:53 +0000",
      "name": "test",
      "is_dir": true,
    },
    {
      "bytes": 10000,
      "modified": "Thu, 03 Jan 2013 14:24:53 +0000",
      "name": "test.jpg",
      "is_dir": false,
    }
  ];
 
  /**
   * connect
   */
  function connect (type) {
      console.log('connect '+type);
      $scope.fs.connect(type);
  }
  /**
   * login
   */
  function login () {
      console.log('login ');
      $scope.fs.login();
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
    if ($scope.isLoggedin){
      console.log('ls '+$scope.path);
      $scope.fs.ls($scope.path);
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
   * connect callback
   */
  $scope.doConnectDropbox = function() {
    connect('dropbox');
  }
  /**
   * connect callback
   */
  $scope.doConnectGDrive = function() {
    connect('gdrive');
  }
  /**
   * login callback
   */
  $scope.doLogin = function() {
    login();
  }
  /**
   * connection success
   */
  $scope.onStatus = function($scope, status, data) {
    console.log("onStatus "+status);
    switch (status){
      /**
       * listServices success
       */
      case 'listServices':
        console.log('listServices ');
        console.log(data);
        $scope.services = data;
        break;
      /**
       * connection success
       */
      case 'connect':
        console.log('connect '+data.authorize_url);
        console.log(data);
        openAuthPopup(data.authorize_url);
        break;
      /**
       * login success
       */
      case 'login':
        var isStatusOk = (data && data.status && data.status.success);
        console.log('login '+isStatusOk);
        console.log(data);
        $scope.isLoggedin = isStatusOk;
        break;
      /**
       * files list ready
       */
      case 'ls':
        console.log('ls ');
        console.log(data);
        $scope.files = data;
        break;
    }
    $scope.$digest();
  }
  /**
   * open a popup for auth
   */
  function openAuthPopup (url) {
    var authPopup = window.open(url,'authPopup','height=800,width=800');
    authPopup.owner = window;
    if (window.focus) {authPopup.focus()}
    if (authPopup) {
      console.log('authPopup opened ');
      if (confirm('Authorize the app in the popup window and click "ok"')){
        login();
      }
    }else{
      console.error('Popup could not be opened');
    }
  }
}
