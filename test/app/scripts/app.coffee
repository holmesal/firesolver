'use strict'

angular
  .module('gameOfAppsApp', [
    'ngCookies',
    'ngResource',
    'ngSanitize',
    'ngRoute',
    'firebase',
    'holmesal.firesolver'
  ])
  .config ($routeProvider, firesolverProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
        resolve: 
          user: (firesolver) ->
            firesolver.get '/hello'
      .when '/superSecretStuff',
        templateUrl: 'views/supersecretstuff.html'
        controller: 'SupersecretstuffCtrl'
      .when '/:vanity',
        templateUrl: 'views/profile.html'
        controller: 'ProfileCtrl'
        resolve:
          user: (firesolver, $route) ->
            firesolver.get "vanity/#{$route.current.params.vanity}"
      .otherwise
        redirectTo: '/'

    # Configure the firebase resolver with your firebase URL
    firesolverProvider.config
      firebaseUrl: 'http://fireman.firebaseio.com'

  .run ($rootScope) ->
    # If a route resolve is rejected, it'll throw a route change error
    # This could mean that a user tried to access a route without being logged in, or there was an error communicating with firebase
    $rootScope.$on '$routeChangeError', (event, current, previous, rejection) ->
      console.error 'failed to change route'
      console.error rejection

