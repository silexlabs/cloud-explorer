/**
 * constructor
 */
function CEFileService($scope) {
  /**
   * callback for status events
   */
  this.scope = $scope;
}
/**
 * generic result handling method
 * @returns true if the current request is over with success
 * @returns false of the request is pending
 * @throws an error if the request is over but the status is not 200
 */
CEFileService.prototype.evalRequestStatus = function(xhReq) {
  if (xhReq.readyState == 4) {
      console.log("status is "+xhReq.status);
    if (xhReq.status == 200)  {
      console.log("statis is 200");
      return true
    }else{
      console.error('Error thrown by the server! '+xhReq.status);
      throw(Error({message:"Error thrown by the server!", code:xhReq.status}));
    }
  }else{
    // not ready, request pending
    return false
  }
}
/**
 * generic result handling method
 */
CEFileService.prototype.evalAPIResult = function(response) {
  console.log('evalAPIResult '+response);
  var responseObj = eval('responseObj='+response);
  if (responseObj && responseObj.status && responseObj.status.success && responseObj.status.success==false ){
    console.error('Error thrown by the server! '+responseObj.status);
    throw (new Error("Error thrown by the server!"));
  }
  if (responseObj.data)
    return responseObj.data;
  else
    return responseObj;
}
/**
 * query the server
 */
CEFileService.prototype.query = function(url, statusEvent) {
  var that = this;
  var xhReq = new XMLHttpRequest();
  xhReq.withCredentials = "true";
  xhReq.open("GET", url, true);
  xhReq.onreadystatechange = function() {
    if (that.evalRequestStatus(xhReq)){

      console.log("cookie: "+xhReq.getResponseHeader("Set-Cookie"));

      var response = xhReq.responseText;
      console.log('success '+response);
      that.scope.onStatus(that.scope, statusEvent, that.evalAPIResult(response));
    }
  };
  xhReq.send(null);
}
/**
 * list services
 */
CEFileService.prototype.listServices = function() {
  console.log('listServices ');
  var url = CEConfig.serverUrl + '/services/list/';
  this.query(url, 'listServices')
}
/**
 * connect service
 */
CEFileService.prototype.connect = function(type) {
  console.log('Connect '+type);
  var url = CEConfig.serverUrl + type + '/connect/';
  this.query(url, 'connect')
}
/**
 * login service
 */
CEFileService.prototype.login = function(type) {
  console.log('Login ');
  var url = CEConfig.serverUrl + type + '/login/';
  this.query(url, 'login')
};
/**
 * ls command
 */
CEFileService.prototype.ls = function(path, type) {
  console.log('ls '+path);
  var url = CEConfig.serverUrl + type + '/exec/ls'+path;
  this.query(url, 'ls')
};
