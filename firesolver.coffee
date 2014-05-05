'use strict'

angular.module('holmesal.firesolver', ['firebase'])
.service 'Firesolver', ($rootScope, $firebase, $firebaseSimpleLogin, $q, $timeout) ->



	class Firesolver

		constructor: ->
			# First off, check the url
			unless $rootScope.firebaseURL
				console.error "<firesolver> Firebase URL not set - use firesolverProvider.config() or set $rootScope.firebaseURL to do this"

			# This flag identifies a null user on the $rootScope as a legitimately empty user
			@emptyUser = false

			# Set up the promises
			@reset()

			# Not using $firebaseSimpleLogin - I think the callback model is a better fit here, to provide concrete did login / not logged in stages
			@rootRef = new Firebase $rootScope.firebaseURL

			# Do the damn thing
			auth = new FirebaseSimpleLogin @rootRef, (err, authUser) =>
				if err
					console.error '<firesolver> There was an error getting the authUser from firebase'
					# console.error err
					# Reject the promise
					@deferredAuthUser.reject err
				else if authUser
					console.log '<firesolver> user is logged in!'
					# console.log authUser
					$rootScope.authUser = authUser
					# Resolve the promise
					# console.log 'resolving promise'
					@deferredAuthUser.resolve authUser
				else
					# Pretty sure this will be called when the user hits logout as well
					console.log '<firesolver> user is NOT logged in!'
					$rootScope.authUser = null
					$rootScope.user = null
					# Reject the promise - this will throw a routeChangeError
					# console.log 'rejecting promise!'
					@deferredAuthUser.reject 'User is NOT logged in!'

		reset: ->
			console.log '<firesolver> resetting promises'
			@deferredUser = $q.defer()
			@deferredAuthUser = $q.defer()

			# Register the deferred user
			@deferUser()

		deferUser: ->
			# After the auth user resolves, kick of this promise resolution
			@deferredAuthUser.promise.then (authUser) =>
				console.log '<firesolver> deferred auth user resolved successfully!'
				# Bind the firebase user to the root scope
				userRef = @rootRef.child('users').child(authUser.username)
				$rootScope.user = $firebase userRef
				# Watch it for updates
				$rootScope.$watch 'user', (user) =>
					# If the user exists, resolve the deferredUser promise
					if user
						console.log '<firesolver> resolving user promise!'
						@deferredUser.resolve user

			, (err) =>
				console.log '<firesolver> deferred auth user rejected!'
				# If the auth user promise is rejected, we should still resolve the user promise
				# This allows access to routes that only require the user promise, but won't allow access to routes that require both the authUser and the user
				# Resolve with a null value, because there is no user
				@deferredUser.resolve null
				# The user is actually empty
				@emptyUser = true

				# Reset the promises, so that subsequent route changes start with fresh promises
				# Note that these will be overridden by $rootScope values if those exist
				@reset()

		authenticate: ->
			# If the user has been authed previously, return an object, and the route will change instantly
			if $rootScope.authUser
				# console.log 'returning auth user!'
				return $rootScope.authUser
			# Otherwise, return a promise - the route will change when it resolves
			# Or it will redirect to landing if it rejects
			else
				# console.log 'returning promise!'
				return @deferredAuthUser.promise

		currentUser: ->
			# If the user already exists, return that.
			# Also return empty users that we've checked
			if $rootScope.user or @emptyUser
				console.log 'returning user'
				console.log $rootScope.user
				return $rootScope.user

			# Otherwise, try to get the user, which will return a promise
			else
				console.log 'returning user promise'
				return @deferredUser.promise

		get: (path) ->
			# path points to a firebase location
			# TODO - ultimate path signals a two-step resolve, and points to the final location
			# TODO - allow passing in of a route, to be sent back in the rejection and used to allow post-login redirection
			deferredGet = $q.defer()

			# checkURL()

			# console.log "firebaseURL is #{firebaseURL}"
			# console.log "path is #{path}"

			# Make sure paths are correct
			# unless path[0] is '/'
			# 	path = "/#{path}"
			# unless ultimatePath and ultimatePath[0] is '/'
			# 	path = "/#{ultimatePath}"

			# console.log "path is #{path}"

			# fullPath = firebaseURL + path

			# console.log fullPath

			getRef = @rootRef.child path

			getRef.on 'value', (snapshot) ->
				getItem = snapshot.val()

				# If there's a value here, continue
				if getItem
					deferredGet.resolve $firebase(getRef)
				else
					deferredGet.reject "<firesolver> No data found at #{path}"

			# Errors result in a rejected promise
			, (err) ->
				deferredGet.reject "<firesolver> Error getting data from location #{path}"

			# Return the promise
			deferredGet.promise

	return new Firesolver