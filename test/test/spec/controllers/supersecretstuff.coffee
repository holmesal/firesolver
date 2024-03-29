'use strict'

describe 'Controller: SupersecretstuffCtrl', ->

  # load the controller's module
  beforeEach module 'gameOfAppsApp'

  SupersecretstuffCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    SupersecretstuffCtrl = $controller 'SupersecretstuffCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
