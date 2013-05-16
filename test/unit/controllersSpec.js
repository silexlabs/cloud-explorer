'use strict';

/* jasmine specs for controllers go here */
describe('CE controllers', function() {

/*  beforeEach(function(){
    this.addMatchers({
      toEqualData: function(expected) {
        return angular.equals(this.actual, expected);
      }
    });
  });*/


  beforeEach(module('ceFileService'));




/*  describe('CEBrowseController', function(){
    var scope, $httpBackend, ctrl,
        xyzPhoneData = function() {
          return {
            name: 'phone xyz',
                images: ['image/url1.png', 'image/url2.png']
          }
        };


    beforeEach(inject(function(_$httpBackend_, $rootScope, $routeParams, $controller) {
      $httpBackend = _$httpBackend_;
      $httpBackend.expectGET('phones/xyz.json').respond(xyzPhoneData());

      $routeParams.phoneId = 'xyz';
      scope = $rootScope.$new();
      ctrl = $controller(PhoneDetailCtrl, {$scope: scope});
    }));


    it('should fetch phone detail', function() {
      expect(scope.phone).toEqualData({});
      $httpBackend.flush();

      expect(scope.phone).toEqualData(xyzPhoneData());
    });
  });*/


  describe('CEBrowseController', function(){
    var scope, ctrl, $httpBackend;

    beforeEach(inject(function(_$httpBackend_, $rootScope, $controller) {
      $httpBackend = _$httpBackend_;
      $httpBackend.expectGET(CEConfig.serverUrl).
          respond([
			  {
			    "name": "Photos",
			    "bytes": 0,
			    "modified": "Wed, 15 May 2013 15:59:51 +0000",
			    "is_dir": true
			  },
			  {
			    "name": "Premiers pas.pdf",
			    "bytes": 148857,
			    "modified": "Wed, 15 May 2013 15:59:51 +0000",
			    "is_dir": false
			  },
			  {
			    "name": "test.txt",
			    "bytes": 0,
			    "modified": "Thu, 16 May 2013 08:28:08 +0000",
			    "is_dir": false
			  },
			  {
			    "name": "toto",
			    "bytes": 0,
			    "modified": "Thu, 16 May 2013 09:42:38 +0000",
			    "is_dir": true
			  }
			]);

      scope = $rootScope.$new();
      ctrl = $controller(CEBrowseController, {$scope: scope});
    }));


    it('should create "files" model with 4 files fetched from xhr', function() {
      expect(scope.files).toEqual([]);

      

      $httpBackend.flush();

      expect(scope.phones).toEqualData(
          [
			  {
			    "name": "Photos",
			    "bytes": 0,
			    "modified": "Wed, 15 May 2013 15:59:51 +0000",
			    "is_dir": true
			  },
			  {
			    "name": "Premiers pas.pdf",
			    "bytes": 148857,
			    "modified": "Wed, 15 May 2013 15:59:51 +0000",
			    "is_dir": false
			  },
			  {
			    "name": "test.txt",
			    "bytes": 0,
			    "modified": "Thu, 16 May 2013 08:28:08 +0000",
			    "is_dir": false
			  },
			  {
			    "name": "toto",
			    "bytes": 0,
			    "modified": "Thu, 16 May 2013 09:42:38 +0000",
			    "is_dir": true
			  }
			]);
    });


/*    it('should set the default value of orderProp model', function() {
      expect(scope.orderProp).toBe('age');
    });*/
  });

});
