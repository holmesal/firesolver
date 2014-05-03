'use strict'

angular.module('holmesal.firesolver', ['firebase'])
	.provider 'firesolver', ->

		firesolver = ($firebase, $q, $rootScope) ->

			firebaseURL = null

			get: (path, ultimatePath=null) ->
				# path points to a firebase location
				# TODO - ultimate path signals a two-step resolve, and points to the final location
				# TODO - allow passing in of a route, to be sent back in the rejection and used to allow post-login redirection
				deferredGet = $q.defer()

				# Check that firebase url has been set
				if opts.firebaseURL
					firebaseURL = opts.firebaseURL
				else
					if $rootScope.firebaseURL
						firebaseURL = $rootScope.firebaseURL
					else
						console.error "<firesolver> Firebase URL not set - use firesolverProvider.config() or set $rootScope.firebaseURL to do this"

				# console.log "firebaseURL is #{firebaseURL}"
				# console.log "path is #{path}"

				# Make sure paths are correct
				unless path[0] is '/'
					path = "/#{path}"
				# unless ultimatePath and ultimatePath[0] is '/'
				# 	path = "/#{ultimatePath}"

				# console.log "path is #{path}"

				fullPath = firebaseURL + path

				# console.log fullPath

				getRef = new Firebase fullPath

				getRef.on 'value', (snapshot) ->
					getItem = snapshot.val()

					# If there's a value here, continue
					if getItem
						deferredGet.resolve getItem
					else
						deferredGet.reject "<firesolver> No data found at #{fullPath}"

				# Errors result in a rejected promise
				, (err) ->
					deferredGet.reject "<firesolver> Error getting data from location #{fullPath}"

				# Return the promise
				deferredGet.promise

		# Options
		opts = {}

		return {
			config: (configOpts) ->
				opts = configOpts
			$get: firesolver
		}


		# provider
	# 	console.log 'config stage!'
	# .service 'firesolver', ->

	# 	console.log 'hey'
		
